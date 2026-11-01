// What a FORCED logout destroys, and what it must not.
//
// network.dart maps any 401 to Prefs.clear() + Get.offAll(login)
// (network.dart:317-329, 485-511), and the server returns 403 rather than 401
// for an authorization denial precisely so that a denied action cannot log a
// merchant out. status_code_classification_test.dart already pins that
// distinction at the status-code level: 401 calls the forced-logout action,
// and no other code does.
//
// This file covers the OTHER half of the audit -- not "what triggers a
// logout" but "what a logout takes with it". Prefs.clear() was
// `getStorage.erase()`, and the container it erases holds two keys that are
// not session state:
//
//   * `language`, whose getter defaults to 'ar' (prefer.dart:115-117), so an
//     English-speaking merchant came back to an Arabic UI after any session
//     expiry;
//   * `onboarding_completed`, which welcome_screen.dart:68-73 tests BEFORE
//     the token, so an expired session replayed the onboarding tour instead
//     of showing the login screen.
//
// Both are reached by a mere session expiry -- no bad input, no attacker, no
// unusual device. The tests below execute the real Prefs and the real
// OnboardingController getter that welcome_screen reads.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/prefer.dart';

import '../support/source_tree.dart';

void main() {
  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    storageDir = Directory.systemTemp.createTempSync('store_go_logout_test');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();
  });

  tearDownAll(() {
    // See nested_api_read_test.dart: this delete can lose a race with GetStorage's
    // background flush and fail with errno 39 even with recursive: true.
    try {
      if (storageDir.existsSync()) storageDir.deleteSync(recursive: true);
    } catch (_) {
      // Intentionally ignored.
    }
  });

  setUp(() async {
    await Prefs.clear();
    await Prefs.remove(Prefs.LANGUAGE);
    await Prefs.remove(Prefs.onboardingKey);
  });

  group('a forced logout destroys the session', () {
    test('the token, user id and store id are gone', () async {
      Prefs.setToken('1|abcdefGHIJKL0123456789');
      Prefs.setUserID('7');
      Prefs.setStoreID('99');

      await Prefs.clear();

      expect(Prefs.getToken(), '');
      expect(Prefs.getUserID(), '');
      expect(Prefs.getStoreID(), '');
    });

    test('the device identifiers are gone too', () async {
      Prefs.setFcmToken('fcm-abc');
      Prefs.setDeviceId('dev-abc');

      await Prefs.clear();

      expect(Prefs.getFcmToken(), '');
      expect(Prefs.getDeviceId(), '');
    });

    test('a key nobody allowlisted is erased by default', () async {
      // The allowlist has to be the safe direction: a key added to Prefs next
      // year must be erased unless someone thought about it. If this ever
      // fails, clear() has become a denylist.
      Prefs.setString('some_future_cached_thing', 'merchant-scoped');

      await Prefs.clear();

      expect(Prefs.getString('some_future_cached_thing'), '');
    });

    test('the next request built afterwards carries no credential', () async {
      Prefs.setToken('1|abcdefGHIJKL0123456789');
      expect(NetworkHttps.authHeaders()['authorization'], isNotNull);

      await Prefs.clear();

      expect(
        NetworkHttps.authHeaders().containsKey('authorization'),
        isFalse,
        reason: 'A cleared session must not keep presenting the old token.',
      );
    });
  });

  group('a forced logout keeps what is not session state', () {
    test('the chosen language survives', () async {
      Prefs.setLanguage('en');
      Prefs.setToken('1|abcdefGHIJKL0123456789');

      await Prefs.clear();

      expect(
        Prefs.getLanguage(),
        'en',
        reason: 'A session expiry must not silently switch the UI language.',
      );
      expect(Prefs.getToken(), '');
    });

    test('a language that was never chosen still defaults to ar', () async {
      // The preserve step must not invent a value: an untouched install keeps
      // the documented default.
      await Prefs.clear();

      expect(Prefs.getLanguage(), 'ar');
    });

    test('completed onboarding is not replayed', () async {
      Prefs.setBool(Prefs.onboardingKey, true);
      Prefs.setToken('1|abcdefGHIJKL0123456789');

      await Prefs.clear();

      expect(Prefs.getBool(Prefs.onboardingKey), isTrue);
    });

    test(
      'the getter welcome_screen actually reads still says completed',
      () async {
        // welcome_screen.dart:61 asks OnboardingController, not Prefs, so the
        // assertion goes through the same getter the routing decision uses.
        // With this false, welcome_screen routes to '/onboarding' and the
        // merchant never reaches the login screen.
        final onboarding = OnboardingController();
        onboarding.completeOnboarding();

        expect(onboarding.isOnboardingCompleted, isTrue);

        await Prefs.clear();

        expect(
          onboarding.isOnboardingCompleted,
          isTrue,
          reason: 'A session expiry must land on /login, not /onboarding.',
        );
      },
    );

    test('an install that never finished onboarding still has not', () async {
      final onboarding = OnboardingController();

      await Prefs.clear();

      expect(onboarding.isOnboardingCompleted, isFalse);
    });
  });

  group('the clear path has no bypass', () {
    test('only Prefs erases the storage container', () {
      // A controller holding its own `GetStorage()` handle would get the
      // SAME default container, so an erase() anywhere else would wipe the
      // allowlist too and nothing would point at it.
      //
      // store_setting_controller.dart:17 used to be exactly that case and was
      // cited here. It is not any more: its currency cache went through its
      // own handle AND outside the store-change reset, which is what let one
      // store's currency format render another store's prices for 24 hours.
      // It now persists through CacheService -- see
      // store_change_cache_isolation_test.dart, which asserts that Prefs and
      // CacheService are the only writers to the container.
      final offenders = <String>[];

      for (final file in libDartFiles()) {
        final path = relative(file);
        if (path == 'lib/utils/prefer.dart') continue;

        final lines = codeOnly(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('.erase()')) {
            offenders.add('$path:${i + 1}:${lines[i].trim()}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Clear the session through Prefs.clear(), which keeps the '
            'language and the onboarding flag.\n${offenders.join('\n')}',
      );
    });

    test('every forced-logout call sits in a 401 branch', () {
      // A 403 reaching handleUnauthorized would log the merchant out for a
      // denied action, which is the whole reason the server answers 403 and
      // not 401. Two call sites outside the network layer hand-roll their
      // status handling (profile_controller and category_controller use
      // http.MultipartRequest directly), so this is checked structurally
      // rather than assumed.
      final callSites = <String>[];
      final bad = <String>[];

      for (final file in libDartFiles()) {
        final path = relative(file);
        if (path == 'lib/network/network.dart') continue;

        final lines = codeOnly(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains('handleUnauthorized(')) continue;

          callSites.add('$path:${i + 1}');

          // Walk back to the nearest enclosing condition.
          var guard = '';
          for (var j = i; j >= 0 && j > i - 12; j--) {
            if (lines[j].contains('if (') || lines[j].contains('if(')) {
              guard = lines[j];
              break;
            }
          }

          if (!guard.contains('401')) {
            bad.add('$path:${i + 1} guarded by: ${guard.trim()}');
          }
        }
      }

      expect(
        callSites,
        isNotEmpty,
        reason: 'The hand-rolled multipart call sites must still share the '
            'one forced-logout path. If this is empty, either they stopped '
            'handling 401 at all or this test has gone vacuous.',
      );

      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });

  // ===========================================================================
  // THE FCM TOKEN: what the forced logout did NOT destroy
  // ===========================================================================
  //
  // There are two ways a merchant's session ends and, until this was fixed,
  // they tore down different amounts of it:
  //
  //   deliberate  AuthController._clearLocalSession() -- FCM token DESTROYED on
  //               Firebase, NotificationController emptied, Prefs cleared.
  //   forced      NetworkHttps.handleUnauthorized() -- Prefs.clear() and
  //               navigate. That was all.
  //
  // `Prefs.clear()` forgets the token LOCALLY. The registration on Firebase
  // survives it, `getToken()` returns the same token, and `device_id` is
  // derived from the hardware -- so after a forced logout the device kept
  // receiving the PREVIOUS merchant's order notifications, and the next
  // merchant to sign in on that device got them. `clearFcmToken()`'s own
  // comment says destroying the token is what prevents exactly that; the
  // forced path simply never called it.
  //
  // WHY THIS IS TWO TESTS AND NOT ONE. A unit test has no Firebase, so it
  // cannot observe `deleteToken()`. Asserting only that the hook FIRES proves
  // nothing about what the hook does -- that is the shape of F227 on the
  // Laravel side, where a census credited an imported trait that the
  // controller never called. So:
  //
  //   1. behavioural -- a 401 really reaches the shared teardown;
  //   2. source      -- the teardown's DEFAULT really routes through
  //                     FcmTokenService, the one owner of deleteToken().
  //
  // Neither alone is evidence. Together they are.
  //
  // AND TOGETHER THEY ARE STILL NOT AN END-TO-END RESULT. State this plainly
  // rather than let the green tick imply more than it earned: these tests
  // establish that the forced-logout path calls the teardown and that the
  // teardown calls `clearFcmToken()`. They do NOT establish that
  // `FirebaseMessaging.deleteToken()` reached Firebase, that the registration
  // was actually revoked, or that a push addressed to the previous merchant
  // stops being delivered to the device. No test in this repository can: there
  // is no Firebase in a unit test, `deleteToken()` is swallowed by its own
  // try/catch (fcm_token_service.dart:198-204) precisely so a Firebase failure
  // cannot strand the local clear, and the server half -- `ApiController`
  // deactivating the StoreDevice row only within `user_id` -- is a separate
  // backend concern.
  //
  // What would settle it is a manual check on a real device, or a staged pair
  // of accounts against a real Firebase project. Until then the honest claim
  // is "the forced logout now does what the deliberate logout always did",
  // not "the previous merchant's pushes are proven to stop".
  group('a forced logout destroys the push registration', () {
    setUp(() {
      // `handleUnauthorized()` ends in `Get.offAll(() => NormalLoginWidget())`,
      // which throws without a GetMaterialApp. testMode makes GetX record the
      // navigation instead of performing it, which is all this test needs —
      // the subject is the TEARDOWN, not the navigation.
      Get.testMode = true;
    });

    tearDown(() {
      NetworkHttps.clearSession = NetworkHttps.defaultClearSession;
      Get.testMode = false;
    });

    test('the 401 path goes through the shared teardown, not a bare clear',
        () async {
      var fired = 0;
      NetworkHttps.clearSession = () async {
        fired += 1;
        await Prefs.clear();
      };

      await NetworkHttps.handleUnauthorized();

      expect(
        fired,
        1,
        reason: 'handleUnauthorized() is clearing the session some other way, '
            'so whatever the shared teardown does -- destroying the FCM token '
            'included -- does not happen on a forced logout.',
      );
    });

    test('and the shared teardown is what the deliberate logout uses too',
        () {
      // One definition, two callers. The Laravel half of this project has been
      // bitten twice by the same shape: two paths answering one question,
      // written separately, drifting, with nothing comparing them.
      final auth = File(
        '${packageRoot().path}/lib/core/controller/auth/auth_controller.dart',
      ).readAsStringSync();

      expect(
        codeOnly(auth),
        contains('NetworkHttps.clearSession()'),
        reason: 'AuthController has gone back to its own teardown. The next '
            'thing added to one path will be missing from the other.',
      );
      expect(
        codeOnly(auth),
        isNot(contains('clearFcmToken')),
        reason: 'Two places now destroy the FCM token. That is the drift this '
            'shared teardown exists to prevent.',
      );
    });

    test('the default teardown destroys the token through its one owner', () {
      // codeOnly(), so a comment mentioning clearFcmToken cannot satisfy this.
      // This repository has twice had a source assertion pass against its own
      // docblock.
      final network = codeOnly(File(
        '${packageRoot().path}/lib/network/network.dart',
      ).readAsStringSync());

      expect(
        network,
        contains('FcmTokenService().clearFcmToken()'),
        reason: 'The forced logout no longer destroys the FCM token, so the '
            'device keeps receiving the previous merchant\'s notifications.',
      );
      expect(
        network,
        contains('clearNotificationData()'),
        reason: 'The forced logout leaves the previous merchant\'s '
            'notifications on screen.',
      );

      // And the clear must come BEFORE Prefs.clear(): clearFcmToken() reads
      // nothing from Prefs today, but a teardown that wipes storage first and
      // then asks a service to clean up after itself is one refactor away from
      // silently doing nothing.
      final fcmAt = network.indexOf('clearFcmToken()');
      final prefsAt = network.indexOf('await Prefs.clear()');
      expect(fcmAt, greaterThan(-1));
      expect(prefsAt, greaterThan(-1));
      expect(
        fcmAt,
        lessThan(prefsAt),
        reason: 'The FCM clear must run before local storage is wiped.',
      );
    });
  });
}
