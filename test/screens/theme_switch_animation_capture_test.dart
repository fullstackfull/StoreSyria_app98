import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/theme_switch_overlay.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-COMP — the theme-switch reveal, driven through the real toggle.
/// =================================================================================================
///
/// `ThemeSwitchOverlay` photographs the screen the instant before the theme changes, then clips
/// that frozen image with a circle that grows from a point near the top of the screen, so the new
/// theme appears to spread out from under it. `ThemeController.changeTheme` (:174) is the only
/// caller, and `store_go.dart:75` is the only place the overlay is installed.
///
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
/// WHY THIS FILE BUILDS ITS OWN ROOT INSTEAD OF CALLING `pumpScreen`
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
///
/// `pumpScreen` hands `GetMaterialApp` a FIXED `theme: appTheme(dark: combination.dark)`, which is
/// right for every other capture in this project and useless here: this component exists to show
/// one theme replacing another, and a root whose theme cannot change has nothing to reveal. The
/// reveal would run over an identical image and photograph as a no-op.
///
/// So the root here is `store_go.dart:28-77` rebuilt line for line — `GetBuilder<ThemeController>`
/// outside `ScreenUtilInit`, `theme:` AND `darkTheme:` both `themeController.theme` (they really
/// are the same object in production; the controller's getter already resolves per `isDark`, which
/// is why `themeMode` is cosmetic), and `builder:` installing the overlay over the navigator.
/// Nothing here is a stand-in for a production wiring: it IS the production wiring.
///
/// It still installs `kCaptureBoundaryKey`, so `captureScreen` photographs the whole view exactly
/// as it does everywhere else, overlay included.
///
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
/// THE FAILURE THIS GUARDS, WHICH IS A SILENT ONE
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
///
/// `_capture()` wraps the whole photograph in `try { … } catch (_) { _clear(); }` — by design, so
/// that a theme change never fails because its animation could not start. The cost is that a
/// BROKEN animation and a working one are indistinguishable from the outside: both end with the
/// new theme on screen. So each case asserts the old frame really was captured (a `RawImage` in
/// the tree, which only `_oldFrame != null` produces) rather than only that the pump survived.
///
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
/// WHAT THE SCREEN UNDERNEATH IS
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
///
/// Real app widgets — `simpleAppBar` and `AppButton` — rather than coloured boxes, because the
/// thing being judged is whether the reveal reads against this app's chrome. It is a composed
/// fixture and not a shipped screen, and it is composed only of shipped widgets.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);

  /// `store_go.dart:28-77`, rebuilt.
  Widget appRoot(ThemeController themeController, TextDirection direction) {
    return RepaintBoundary(
      key: kCaptureBoundaryKey,
      child: GetBuilder<ThemeController>(
        init: themeController,
        builder: (_) => ScreenUtilInit(
          designSize: kGoldenDesignSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeController.theme,
            darkTheme: themeController.theme,
            themeMode:
                themeController.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            locale: direction == TextDirection.rtl
                ? const Locale('ar', 'AE')
                : const Locale('en', 'US'),
            fallbackLocale: const Locale('en', 'US'),
            localizationsDelegates: TranslationService.localizationsDelegates,
            supportedLocales: TranslationService.supportedLocales,
            builder: (context, child) =>
                ThemeSwitchOverlay(child: child ?? const SizedBox.shrink()),
            // A `Builder`, because `simpleAppBar` resolves `Theme.of(Get.context!)` and
            // `Get.context` is still null while `GetMaterialApp`'s own arguments are being
            // evaluated. Deferring the screen by one build is what the app does anyway -- every
            // real screen is reached through a route, never constructed as a constructor
            // argument.
            home: Builder(
              builder: (_) => Scaffold(
              appBar: simpleAppBar(
                isBack: true,
                title: 'settings'.tr,
                label: null,
                onNewLabelTap: () {},
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppButton(text: 'save'.tr, onPressed: () {}),
                    const SizedBox(height: 12),
                    AppButton(text: 'cancel'.tr, onPressed: () {}, outlined: true),
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final combination in kFourCombinations) {
    testWidgets('the theme-switch reveal runs in ${combination.name}', (tester) async {
      pinGoldenSurface(tester);

      if (Get.isRegistered<ThemeController>()) Get.delete<ThemeController>();

      final ThemeController themeController = Get.put(ThemeController());

      // START IN THE OPPOSITE THEME. The capture is of a TRANSITION, so the frozen frame has to
      // be the other one -- starting in the destination theme would reveal an identical image and
      // the case would pass while photographing nothing.
      themeController.isDark.value = !combination.dark;

      await tester.pumpWidget(appRoot(themeController, combination.direction));
      await pumpFrames(tester, frames: 12);

      // THE REAL TOGGLE. `changeTheme` is what the settings switch calls: it photographs the
      // screen, then flips `isDark`, then `update()`s the GetBuilder above.
      themeController.changeTheme(combination.dark);

      // Mid-reveal. The controller runs 650 ms on `Curves.easeInOutCubic`, so ~260 ms is far
      // enough in for the circle to be unmistakable and far enough out that it has not finished.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 260));

      expect(tester.takeException(), isNull,
          reason: 'the theme switch threw in ${combination.name}');

      // THE FROZEN FRAME REALLY EXISTS. `_capture()` swallows its own failure by design, so
      // without this the case would pass against an animation that never started.
      expect(find.byType(RawImage), findsOneWidget,
          reason: 'no old frame is on screen in ${combination.name}, so `_capture()` fell into '
              'its catch and the theme changed with no animation at all. That failure is silent '
              'in production: both paths end with the new theme showing.');

      expect(find.byType(ClipPath), findsWidgets,
          reason: 'the old frame is not being clipped, so there is no reveal circle');

      final captured = await captureScreen(
          tester, captureName('flutter-component-theme-switch', combination));

      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the theme-switch capture is suspiciously small');
      }

      // AND IT CLEANS ITSELF UP. `_controller.addStatusListener` calls `_clear()` on completion
      // and `_clear()` disposes the image; an old frame left on screen would be a frozen app.
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(RawImage), findsNothing,
          reason: 'the frozen frame is still on screen after the animation finished, so the app '
              'is showing a screenshot the merchant cannot interact with');

      Get.delete<ThemeController>();
    });
  }

  test('the reveal is centred, so it does not mirror with direction', () {
    /// A DIRECTION FACT, PINNED. `_RevealClipper.getClip` puts the circle's centre at
    /// `Offset(size.width / 2, size.height * 0.12)` and the `Stack` above it is pinned to
    /// `TextDirection.ltr`. Both are deliberate for a full-bleed overlay — a reveal that started
    /// from a physical corner would spread from the WRONG corner in one of the two directions,
    /// and that is precisely the defect this project keeps finding in directional layouts.
    ///
    /// Asserted off the source because the clipper IS the geometry, and it is private: the four
    /// captures above show that the result is the same in both directions, and this says why,
    /// rather than leaving a reader to infer a rule from two images.
    final String code =
        File('lib/view/widget/theme_switch_overlay.dart').readAsStringSync();

    expect(code.contains('size.width / 2'), isTrue,
        reason: 'the reveal centre is no longer horizontally centred, so it now depends on a '
            'physical side and will spread from the wrong one in one of the two directions');

    expect(code.contains('textDirection: TextDirection.ltr'), isTrue,
        reason: 'the overlay Stack no longer pins its direction; a full-bleed Stack that inherits '
            'direction can flip its children between the two directions');
  });
}
