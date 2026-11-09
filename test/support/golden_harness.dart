// ROUTE 1 OF THE FLUTTER RENDERING-EVIDENCE BLOCKER — the shared golden harness.
// =================================================================================================
//
// `docs/PHASE-2.5-FLUTTER-RENDERING-EVIDENCE-BLOCKER-AR.md` §3 measured what this repository's
// verification actually lacks, and it is NOT "the Flutter app is unverified" — CI pins
// FLUTTER_VERSION 3.47.7, runs `flutter test` as a blocking 100% gate, and 26 of the test files
// pump real widgets and read resolved colours off the built tree. What was missing, measured:
// `matchesGoldenFile` appeared in ZERO files and there were ZERO baseline PNGs, so **nothing
// compared a rendered image**. The owner authorised route 1 — golden tests — on 2026-11-07.
//
// WHAT THIS FILE IS FOR. Four things have each cost this repository a wrong reading before, and a
// golden test gets all four wrong by default unless they are handled here, once:
//
//  1. THE THEME MUST COME FROM `ThemeController`, never `ThemeData(brightness: ...)`.
//     Flutter's own default `hintColor` is `black.withOpacity(0.6)`, so a bare-ThemeData test
//     renders something the app never paints. `dropdown_hint_contrast_test.dart:34-40` records that
//     exact mistake being made here, and `login_secondary_text_contrast_test.dart:35` records it
//     again. A GOLDEN built on a bare ThemeData would bake the wrong pixels into the baseline and
//     then defend them for ever, which is worse than no baseline at all.
//
//  2. `ThemeController.theme` HAS A PROCESS-GLOBAL SIDE EFFECT. It calls
//     `AppDarkTheme.darkColor()` / `AppLightTheme.lightThemeColor()`, which reassign the global
//     `AppColor` that the `pMedium14`-style text getters read. A file that builds the dark theme
//     and does not restore makes every later light case render dark values. `resetThemeColours()`
//     below exists for the `setUp` that prevents it.
//
//  3. THE SURFACE MUST BE PINNED. On the default 800x600 test window ScreenUtil scales every `.sp`
//     by 2.22 while a raw `fontSize:` stays put — so the same widget renders at two different
//     relative sizes depending on the window. For a contrast test that produced a measurement of
//     the wrong element; for a golden it would produce a baseline that is not the design size.
//
//  4. FONTS. This is the one that is specific to goldens, and it is the known fragility route 1
//     named: without an explicit load, the test engine paints with Ahem (a blank-box placeholder
//     font) and a baseline captured on one machine disagrees with the next. The app declares
//     **Tajawal** in `pubspec.yaml` in seven weights, every one of them a real file under
//     `assets/fonts/`. `loadAppFonts()` registers all seven from disk, so the text in a baseline is
//     the text the app paints, in Arabic as well as English — which matters here more than usual,
//     because half the four-combination evidence this project requires is Arabic.
//
// WHAT A GOLDEN PROVES, AND WHAT IT DOES NOT. It proves pixel-level paint, in both themes and both
// directions, for the screens that have one. It does NOT prove device behaviour — performance,
// system language switching, the keyboard, Crashlytics — and route 1 says so. Nothing in this file
// should be read as closing routes 2 or 3.
//
// NO BASELINE IS COMMITTED BY THE CHANGE THAT ADDS THIS FILE, deliberately. Route 1 step 2 is *"the
// images are reviewed by a human eye once, then committed"*. A baseline generated and committed by
// the same agent that wrote the test is not evidence of anything: it records whatever the code did,
// including a defect, and then asserts it for ever. So the golden cases SKIP THEMSELVES while their
// baseline is absent (`goldenReady` below) and begin comparing the moment a reviewed PNG lands.
// `flutter test` therefore stays green and the existing blocking gate is not narrowed by one flag.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/theme_light/light_theme.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/translations/translation_service.dart';

import 'source_tree.dart';

/// The design size every screen in this app is laid out against, and therefore the only size a
/// baseline may be captured at. Taken from the existing render tests rather than chosen here.
const Size kGoldenDesignSize = Size(360, 800);

/// Where baselines live, relative to the test file that references them.
const String kGoldenDir = 'goldens';

/// The seven real Tajawal faces the app declares in `pubspec.yaml`, with the weights it declares
/// them under. Kept as data so `golden_infrastructure_test.dart` can assert this list still matches
/// the manifest — a font added to the app and not to this list would silently stop appearing in
/// baselines, and the only symptom would be a diff nobody can explain.
const Map<String, int> kAppFontFaces = <String, int>{
  'assets/fonts/Tajawal-ExtraLight.ttf': 200,
  'assets/fonts/Tajawal-Light.ttf': 300,
  'assets/fonts/Tajawal-Regular.ttf': 400,
  'assets/fonts/Tajawal-Medium.ttf': 500,
  'assets/fonts/Tajawal-Bold.ttf': 700,
  'assets/fonts/Tajawal-ExtraBold.ttf': 800,
  'assets/fonts/Tajawal-Black.ttf': 900,
};

const String kAppFontFamily = 'Tajawal';

bool _fontsLoaded = false;

/// Registers EVERY font the app bundles with the test engine, read from the asset manifest.
///
/// WHY THE MANIFEST AND NOT THE EXPLICIT LIST ABOVE. The first version of this function loaded
/// `kAppFontFaces` from disk, which covers Tajawal — and the captured baselines came back with the
/// customer card's three info-row icons drawn as EMPTY SQUARES. They are
/// `Icons.email_outlined`, `Icons.shopping_bag_outlined` and `Icons.phone_outlined`
/// (`customer_widget.dart:99`, `:109`, `:119`), and `flutter test` does not load MaterialIcons
/// unless something asks it to. Every one of the eight images would have baked a missing glyph in
/// and then defended it for ever — the precise failure mode route 1 names, found by LOOKING at the
/// pictures rather than by trusting that a capture which exits 0 is a capture that is correct.
///
/// `FontManifest.json` is what the tool generates from `pubspec.yaml`, and it includes MaterialIcons
/// whenever `uses-material-design: true`. Loading from it therefore stays in step with the manifest
/// by construction, and needs no path into the SDK — which `test/support/no_hardcoded_host_paths_test.dart`
/// exists to forbid, after a hard-coded `/root/.pub-cache` path went red on the runner.
///
/// `kAppFontFaces` is kept, as the cross-check in `golden_infrastructure_test.dart`: the manifest
/// is generated, so it cannot catch a font that was deleted from `pubspec.yaml` on purpose, and a
/// list somebody has to edit by hand is what makes that deletion visible in a diff.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  TestWidgetsFlutterBinding.ensureInitialized();

  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;

  if (manifest.isEmpty) {
    throw StateError(
      'FontManifest.json is empty, so a baseline would be painted entirely in the fallback font. '
      'Run `flutter pub get` and check pubspec.yaml still declares its fonts.',
    );
  }

  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }

  _fontsLoaded = true;
}

/// Restores the process-global `AppColor` to its LIGHT values.
///
/// Call from `setUp` in every golden file. See trap 2 in this file's header: `ThemeController.theme`
/// mutates global colour state, so a dark case leaves the globals dark for whatever runs next.
void resetThemeColours() => AppLightTheme.lightThemeColor();

/// The app's OWN `ThemeData`, built exactly the way `store_go.dart:42/:68` builds it.
///
/// Do not replace this with `ThemeData(brightness: ...)`. See trap 1.
ThemeData appTheme({required bool dark}) {
  final controller = ThemeController();
  controller.isDark.value = dark;
  return controller.theme;
}

/// Pins the test surface to the design size, so ScreenUtil's `.sp` scale factor is 1:1 with the
/// layout the screens were designed against. See trap 3.
void pinGoldenSurface(WidgetTester tester) {
  tester.view.physicalSize = kGoldenDesignSize;
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);
}

/// Hosts [child] in the app's real shell for one of the four combinations.
///
/// `GetMaterialApp` rather than `MaterialApp`, because the screens use `.tr` and GetX navigation and
/// a bare MaterialApp throws on the first of them.
///
/// **AND IT MUST BE GIVEN THE APP'S OWN `translations`, `fallbackLocale` AND LOCALISATION
/// DELEGATES — the first version of this harness gave it none, and that was a blocker.**
///
/// `store_go.dart:44-46` wires `translations: TranslationService()`,
/// `locale: TranslationService.currentLocale` and
/// `fallbackLocale: TranslationService.fallbackLocale`. Without them GetX's `.tr` returns **the key
/// unchanged**, so `'active'.tr` renders the literal string `active`. The first capture shows
/// exactly that on the customer card's status pill.
///
/// The consequence is worst in the half that matters most here: **every Arabic baseline would have
/// frozen an English key in place of the Arabic label**, and checking Arabic text rendering is
/// most of what an RTL baseline is for. A reviewer looking at those images would have been
/// approving the wrong picture.
///
/// `localizationsDelegates` and `supportedLocales` come with them for the reason
/// `TranslationService` records at `:16-27`: without `GlobalWidgetsLocalizations`, MaterialApp
/// falls back to `DefaultWidgetsLocalizations`, whose `textDirection` is **always LTR** — so
/// Material's own built-ins would render unmirrored inside a baseline the test calls RTL.
///
/// Found by an adversarial review of the change that added this file.
Widget goldenHost({
  required Widget child,
  required bool dark,
  required TextDirection direction,
}) {
  return ScreenUtilInit(
    designSize: kGoldenDesignSize,
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(dark: dark),
      translations: TranslationService(),
      fallbackLocale: TranslationService.fallbackLocale,
      localizationsDelegates: TranslationService.localizationsDelegates,
      supportedLocales: TranslationService.supportedLocales,
      // The app's own locale objects, not bare language codes: TranslationService.locales are
      // `ar_AE` and `en_US`, and GetX matches its translation map on the full locale.
      locale: direction == TextDirection.rtl
          ? const Locale('ar', 'AE')
          : const Locale('en', 'US'),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: child),
      ),
    ),
  );
}

/// The four combinations every surface in this project must be checked in — Arabic (RTL) and
/// English (LTR), light and dark. Named so a baseline's filename says which one it is.
const List<GoldenCombination> kFourCombinations = <GoldenCombination>[
  GoldenCombination('light-ltr', dark: false, direction: TextDirection.ltr),
  GoldenCombination('light-rtl', dark: false, direction: TextDirection.rtl),
  GoldenCombination('dark-ltr', dark: true, direction: TextDirection.ltr),
  GoldenCombination('dark-rtl', dark: true, direction: TextDirection.rtl),
];

class GoldenCombination {
  const GoldenCombination(this.name, {required this.dark, required this.direction});

  final String name;
  final bool dark;
  final TextDirection direction;
}

/// The baseline path for [surface] in [combination], relative to the test file.
String goldenPath(String surface, GoldenCombination combination) =>
    '$kGoldenDir/$surface.${combination.name}.png';

/// Whether this golden case can run.
///
/// TRUE when `--update-goldens` is in effect — that is the capture run, whose whole purpose is to
/// create the file, so it must not skip for the file's absence. Otherwise TRUE only if a baseline
/// has actually been committed.
///
/// This is what keeps the existing blocking `flutter test` gate green without excluding a tag from
/// it: an uncaptured case reports as a SKIP with a reason that says what to do, rather than as a
/// failure that somebody would then be tempted to silence.
bool goldenReady(String surface, GoldenCombination combination) {
  if (autoUpdateGoldenFiles) return true;
  return File('${packageRoot().path}/test/golden/${goldenPath(surface, combination)}')
      .existsSync();
}

/// The reason attached to a skipped golden case, so the skip explains itself in the test output.
String goldenSkipReason(String surface, GoldenCombination combination) =>
    'No reviewed baseline for $surface (${combination.name}). Route 1 step 1: run the '
    '"goldens (capture for human review)" workflow_dispatch job, which runs '
    '`flutter test --update-goldens --tags golden` and uploads the PNGs as an artifact. '
    'Route 1 step 2: a human reviews them once and commits them to '
    'test/golden/$kGoldenDir/. This case starts comparing pixels the moment that file lands. '
    'It is NOT committed by the agent that wrote the test, because a baseline generated and '
    'committed by the same author records whatever the code did, including a defect, and then '
    'asserts it for ever.';
