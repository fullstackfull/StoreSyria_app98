/// A SCREEN-LEVEL TEST HARNESS — pump a real merchant screen, with the network under control and
/// without ever hanging.
/// =================================================================================================
///
/// WHAT WAS IN THE WAY, AND WHAT EACH PIECE HERE ANSWERS.
///
/// `test/ui/setting_gate_rendering_test.dart` recorded the blocker: screens "fire
/// `getTopOrderData()`, `_fetchInitialData()` and `getDeliveryBoysData()` themselves, in
/// `initState` and a post-frame callback — an `onInit` override touches none of them, the calls
/// reach the network, and their failure toasts leave GetX timers pending so `pumpAndSettle` hangs
/// for reasons unrelated to any gate." Only `SettingScreen` could be pumped, and only because it
/// builds through `GetBuilder<ThemeController>(init: ThemeController())` and constructs its own.
///
/// Four things were MEASURED before this file was written, and each one decided a design choice.
///
/// 1. THE NETWORK SEAM IS `runWithClient`, AND IT COSTS NO PRODUCTION CHANGE.
///    `lib/network/network.dart` calls the top-level `http.get` / `http.post`, which resolve their
///    `Client` from a zone value. `package:http` warns that "Flutter does not guarantee that
///    callbacks are executed in a particular Zone", so this was measured rather than assumed: a
///    `MockClient` installed with `runWithClient` DOES receive a request started from a
///    `WidgetsBinding.instance.addPostFrameCallback` inside `initState` —
///    `hits=1 [GET /api/admin/customerlist]`. That is the whole fetch path the blocker names.
///
///    The alternative was swapping each controller's repository field. It is NOT universal: of 23
///    repository fields across the controllers, **8 are `final`** — `OrderController`'s three among
///    them — so that seam would have needed production edits to reach the screens that matter most.
///    This one reaches every controller through one mechanism, and changes no shipped code.
///
/// 2. `pumpAndSettle` CANNOT WORK HERE, AND THE REASON IS NOT GETX TIMERS.
///    The loading state is a shimmer, and `lib/view/new_widgets/shimmer.dart:76` is
///    `_controller.repeat(min: -0.5, max: 1.5, period: ...)` — an animation that never ends. While
///    a screen is loading the tree therefore never reaches quiescence, so `pumpAndSettle` has
///    nothing to settle to. Every helper below pumps a BOUNDED number of frames and returns.
///
/// 3. THE FAILURE PATH DOES NOT LEAVE A PENDING TIMER, measured on a 500. The toast is
///    `Get.snackbar` with `duration: 4s` and a 350ms animation (`app_snackbar.dart:52-80`), and it
///    drains cleanly when the fake clock is advanced past it — which is what [drainToasts] does.
///    Nothing about production toast behaviour is changed; the test waits the clock out.
///
/// 4. A SCREEN NEEDS `StoreChangeService` REGISTERED. Six controllers call
///    `StoreChangeService.instance.register(...)` in `onInit`, and `main.dart:55` is the only place
///    it is put. Without it the first pump throws `"StoreChangeService" not found` — which is what
///    the first probe did.
///
/// WHAT THIS HARNESS DELIBERATELY DOES NOT DO. It does not stub a controller, override `onInit` or
/// inject a fake repository, because each of those tests something other than the screen. It puts
/// the REAL controller in front of a controlled network and renders what the merchant sees.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';
import 'package:store_go_app/core/permissions/merchant_permissions.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/translations/translation_service.dart';

import 'golden_harness.dart';

// =================================================================================================
//  ONE-TIME SETUP
// =================================================================================================

Directory? _storageDir;

/// Call once from `setUpAll`. Idempotent.
///
/// GetStorage writes through `path_provider`, which has no implementation in a test binding, so the
/// channel is answered with a throwaway directory — the same shape `permission_store_switch_test`
/// and `setting_gate_rendering_test` already use.
Future<void> initScreenHarness() async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  _storageDir ??= Directory.systemTemp.createTempSync('ss_screen_harness');

  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => _storageDir!.path,
  );

  await GetStorage.init();
  app.getStorage = GetStorage();

  Get.addTranslations({'en': en, 'ar': ar});

  await loadAppFonts();
}

/// Call from `tearDownAll`.
void disposeScreenHarness() {
  try {
    _storageDir?.deleteSync(recursive: true);
  } catch (_) {
    // A locked temp directory must not fail a suite that has already passed.
  }

  _storageDir = null;
}

/// Call from `tearDown`.
///
/// THREE THINGS SURVIVE A TEST AND EACH ONE PRODUCES A FALSE READING.
///
///   `Get` — a controller, and its already-loaded data, leaks into the next test.
///
///   `MerchantPermissions` — a staff permission set persists and silently gates a screen the next
///   test expects to be whole.
///
///   **GET STORAGE — and this is the one that cost two red tests before it was understood.**
///   `CacheService` (`cahe.dart:16`) writes every successful page to GetStorage under `cache_*`,
///   and controllers read it back on mount. `Get.reset()` does not touch it, so a test that stubs
///   a 500 still showed the PREVIOUS test's customers: the screen rendered data the stub never
///   served. Measured — the two tests failed together and passed in isolation, which is the
///   signature of exactly this.
///
/// Clearing it is a TEST-side reset of test-side state; no production caching behaviour changes.
void resetScreenHarness() {
  MerchantPermissions.forget();
  Get.reset();
  resetThemeColours();

  final storage = app.getStorage;

  if (storage != null) {
    for (final key in storage.getKeys<Iterable<dynamic>>().toList()) {
      if (key is String && key.startsWith('cache_')) {
        storage.remove(key);
      }
    }
  }
}

// =================================================================================================
//  THE API STUB
// =================================================================================================

String _encodeBody(Object body) => body is String ? body : jsonEncode(body);

/// What the app's HTTP calls answer with, declared per test.
///
/// Matching is by PATH FRAGMENT rather than by full URL, because `lib/utils/base_api.dart` builds
/// each endpoint by string concatenation with query parameters appended (`?store_id=`,
/// `&delivered_status=`), so the full URL of a call is an implementation detail of the screen under
/// test. The fragment is the endpoint name, which is the stable part.
class ApiStub {
  ApiStub({this.fallbackStatus = 200, Object? fallbackBody})
      : _fallbackBody =
            fallbackBody ?? <String, Object?>{'status': 1, 'data': <String, Object?>{}};

  final int fallbackStatus;
  final Object _fallbackBody;

  final List<_StubRule> _rules = <_StubRule>[];

  /// Every request the screen made, as `METHOD /path`, in order.
  ///
  /// Recording them is not decoration: a screen that fetches nothing and a screen whose fetch was
  /// never intercepted look identical on screen. This is how a test tells them apart, and every
  /// test below asserts on it before asserting on pixels.
  final List<String> calls = <String>[];

  /// Answer any request whose path contains [pathFragment] with [body].
  ///
  /// Rules match in the order they were added, so a narrower rule goes first.
  ApiStub on(String pathFragment, Object body, {int status = 200}) {
    _rules.add(_StubRule(pathFragment, body, status));

    return this;
  }

  /// True when at least one request's path contained [pathFragment].
  bool sawRequestFor(String pathFragment) => calls.any((call) => call.contains(pathFragment));

  http.Client client() => MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');

        for (final rule in _rules) {
          if (request.url.path.contains(rule.pathFragment) ||
              request.url.toString().contains(rule.pathFragment)) {
            return http.Response(
              _encodeBody(rule.body),
              rule.status,
              headers: const {'content-type': 'application/json; charset=utf-8'},
            );
          }
        }

        return http.Response(
          _encodeBody(_fallbackBody),
          fallbackStatus,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      });
}

class _StubRule {
  const _StubRule(this.pathFragment, this.body, this.status);

  final String pathFragment;
  final Object body;
  final int status;
}

// =================================================================================================
//  PUMPING — bounded and deterministic, never `pumpAndSettle`
// =================================================================================================

/// Pump [frames] frames of [step] each. Deterministic, and it ALWAYS returns.
///
/// This is the REPLACEMENT for `pumpAndSettle`, not a wrapper around it. See note 2 at the top of
/// this file: a loading screen schedules frames for ever, so "settled" is not a state this
/// application reaches while it is fetching.
Future<void> pumpFrames(
  WidgetTester tester, {
  int frames = 12,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

/// Pump until [condition] holds, or FAIL with a readable message at the cap.
///
/// Turning a hang into a failure is the whole point: a screen whose data never arrives should fail
/// a test naming what it was waiting for, not hold the suite open.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  String? reason,
  int maxFrames = 60,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxFrames; i++) {
    if (condition()) return;

    await tester.pump(step);
  }

  if (condition()) return;

  fail(
    'pumpUntil gave up after $maxFrames frames of ${step.inMilliseconds}ms '
    '(${maxFrames * step.inMilliseconds}ms of fake time)'
    '${reason == null ? '' : ': $reason'}. '
    'This is a BOUNDED failure on purpose — pumpAndSettle would not have returned at all, '
    'because the loading shimmer repeats for ever.',
  );
}

/// Advance the fake clock past the snackbar so a toast cannot outlive the test.
///
/// `app_snackbar.dart` uses `duration: 4s` with a 350ms animation. Measured on the real failure
/// path (a 500 answer): advancing 10s of fake time drains it with no pending-timer complaint.
/// Nothing about production toast behaviour changes — the test waits the clock out.
Future<void> drainToasts(WidgetTester tester) =>
    pumpFrames(tester, frames: 20, step: const Duration(milliseconds: 500));

// =================================================================================================
//  THE PUMP ITSELF
// =================================================================================================

/// Mount [screen] in the app's real shell, in [combination], with [api] answering the network.
///
/// [register] runs INSIDE the client zone and before the first pump: put the controllers the screen
/// does `Get.find` for there. `StoreChangeService` is registered already.
///
/// **WRITE [register] WITH A BLOCK BODY, NEVER AN ARROW.** `register: () => Get.put(Foo())` is a
/// silent trap: the parameter's type is `void Function()`, so Dart infers the generic of
/// `S Get.put<S>(S)` from that `void` CONTEXT and registers the instance under `void`. The screen's
/// own `Get.find<Foo>()` then throws `"Foo" not found`, which reads like a missing registration
/// rather than a mis-typed one. MEASURED:
///
///     arrow  isRegistered<Foo>=false  isRegistered<void>=true
///     block  isRegistered<Foo>=true   isRegistered<void>=false
///
/// This cost an hour the first time. [pumpScreen] now detects it and fails by name instead.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required ApiStub api,
  GoldenCombination combination = const GoldenCombination(
    'light-ltr',
    dark: false,
    direction: TextDirection.ltr,
  ),
  void Function()? register,
  int frames = 12,
  Duration step = const Duration(milliseconds: 50),
}) async {
  pinGoldenSurface(tester);

  await http.runWithClient(() async {
    // `permanent: true` matches main.dart:55. Six controllers call
    // `StoreChangeService.instance.register(...)` in onInit and throw without it.
    if (!Get.isRegistered<StoreChangeService>()) {
      Get.put(StoreChangeService(), permanent: true);
    }

    register?.call();

    // THE ARROW TRAP, TURNED INTO A NAMED FAILURE. Nothing in this application ever registers a
    // dependency under `void`, so its presence means exactly one thing. See the note on
    // [register] above.
    if (Get.isRegistered<void>()) {
      fail(
        'A dependency is registered under the type `void`, which means `register:` was written '
        'as an ARROW — `register: () => Get.put(Foo())`. The parameter is `void Function()`, so '
        'Dart inferred `Get.put<void>` from that context and the screen\'s own `Get.find<Foo>()` '
        'will throw `"Foo" not found`. Use a block body instead: '
        '`register: () { Get.put(Foo()); }`.',
      );
    }

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: kGoldenDesignSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme(dark: combination.dark),
          locale: combination.direction == TextDirection.rtl
              ? const Locale('ar', 'AE')
              : const Locale('en', 'US'),
          translations: _HarnessTranslations(),
          fallbackLocale: const Locale('en', 'US'),
          // The app's OWN delegates and locales. Without `GlobalWidgetsLocalizations`, MaterialApp
          // falls back to `DefaultWidgetsLocalizations`, whose `textDirection` is ALWAYS ltr — so
          // Material's built-ins would render unmirrored inside a tree the test calls RTL.
          // `golden_harness.dart` records the same trap.
          localizationsDelegates: TranslationService.localizationsDelegates,
          supportedLocales: TranslationService.supportedLocales,
          home: Directionality(textDirection: combination.direction, child: screen),
        ),
      ),
    );

    await pumpFrames(tester, frames: frames, step: step);
  }, api.client);
}

/// The app's own two translation maps, as a `Translations`.
///
/// `TranslationService` is not reused directly because it reads the STORED locale, and a screen
/// test must render the combination it was asked for rather than whatever the last test left in
/// storage.
class _HarnessTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': en, 'ar_AE': ar};
}
