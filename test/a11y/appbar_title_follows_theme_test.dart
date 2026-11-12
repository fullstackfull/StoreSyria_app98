import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/config/theme_light/light_theme.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/theme_switch_overlay.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5 — does the shared app bar follow a theme change, or keep the colour it was born with?
/// =================================================================================================
///
/// FOUND IN A CAPTURE OF THE THEME-SWITCH REVEAL. The animation was photographed in all four
/// combinations; in the two frames whose DESTINATION is the light theme, the app bar's title band
/// came back as 7,770 pixels of pure `#FFFFFF` while the back control beside it rendered normally.
/// In the two dark-destination frames the title was there in `#2AC3E5`.
///
/// `simpleAppBar` resolves its title colour as
///
///     final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
///     final textColor = isDark ? AppColor.cWhite : AppColor.themeNavyBlueColor;
///
/// so a title that stays on the DARK branch after a switch to light is `AppColor.cWhite` on a
/// white bar — 1.00:1, invisible, on every one of the 28 screens this app bar serves. The back
/// control survives because its colour is not conditioned on `isDark` at all.
///
/// WHAT THIS FILE ASSERTS, AND WHY IT READS THE WIDGET RATHER THAN THE PIXELS. A pixel count
/// cannot tell "white glyph on white" from "no glyph", and the two have different causes. The
/// resolved `TextStyle.color` on the title `Text` says exactly which branch ran.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);

  /// `store_go.dart:28-77`: the GetBuilder that rebuilds the whole app when the theme changes.
  Widget appRoot(ThemeController themeController) {
    return GetBuilder<ThemeController>(
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
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          localizationsDelegates: TranslationService.localizationsDelegates,
          supportedLocales: TranslationService.supportedLocales,
          builder: (context, child) =>
              ThemeSwitchOverlay(child: child ?? const SizedBox.shrink()),
          home: Builder(
            builder: (_) => Scaffold(
              appBar: simpleAppBar(
                isBack: true,
                title: 'Settings',
                label: null,
                onNewLabelTap: () {},
              ),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }

  /// WCAG 2.1 contrast, because `isNot(background)` is not the question.
  ///
  /// The first draft of this file asserted only that the title colour differed from the bar. That
  /// catches white-on-white and misses navy-on-navy: the light branch is
  /// `AppColor.themeNavyBlueColor`, and left on a DARK bar it is a different colour and still
  /// unreadable. Both directions of the switch can fail, so both are measured the same way.
  double contrast(Color a, Color b) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

    double luminance(Color c) =>
        0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

    final double la = luminance(a) + 0.05;
    final double lb = luminance(b) + 0.05;

    return la > lb ? la / lb : lb / la;
  }

  /// SC 1.4.3. The title is `pMedium18`, well under the large-text threshold.
  const double textMinimum = 4.5;

  Color titleColour(WidgetTester tester) {
    final Text title = tester.widget<Text>(find.text('Settings'));
    return title.style!.color!;
  }

  /// The surface the title is drawn on, so the assertion is about legibility and not about a
  /// particular hex. `simpleAppBar` paints no fill of its own, so this is the scaffold's.
  Color barBackground(WidgetTester tester) {
    return Theme.of(tester.element(find.text('Settings'))).scaffoldBackgroundColor;
  }

  testWidgets('premise: the two branches really are different colours', (tester) async {
    // Without this, every case below could be measuring one colour twice.
    AppLightTheme.lightThemeColor();
    final Color lightBranch = AppColor.themeNavyBlueColor;
    final Color darkBranch = AppColor.cWhite;

    expect(lightBranch, isNot(darkBranch),
        reason: 'the title has one colour in both themes, so this file measures nothing');

    resetThemeColours();
  });

  testWidgets('steady-state light: the title is the light colour', (tester) async {
    pinGoldenSurface(tester);

    if (Get.isRegistered<ThemeController>()) Get.delete<ThemeController>();
    final ThemeController controller = Get.put(ThemeController());
    controller.isDark.value = false;

    await tester.pumpWidget(appRoot(controller));
    await pumpFrames(tester, frames: 12);

    expect(contrast(titleColour(tester), barBackground(tester)),
        greaterThanOrEqualTo(textMinimum),
        reason: 'the app bar title is unreadable on the bar it sits on, in a screen that was '
            'never switched: ${contrast(titleColour(tester), barBackground(tester))}:1');

    Get.delete<ThemeController>();
  });

  testWidgets('after switching dark -> light, the title follows', (tester) async {
    pinGoldenSurface(tester);

    if (Get.isRegistered<ThemeController>()) Get.delete<ThemeController>();
    final ThemeController controller = Get.put(ThemeController());
    controller.isDark.value = true;

    await tester.pumpWidget(appRoot(controller));
    await pumpFrames(tester, frames: 12);

    final Color before = titleColour(tester);

    // The real toggle.
    controller.changeTheme(false);

    // Past the 650 ms reveal, so this is the settled screen and not a transition frame.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await pumpFrames(tester, frames: 8);

    final Color after = titleColour(tester);
    final Color background = barBackground(tester);

    expect(after, isNot(before),
        reason: 'the app bar title is still the colour it had in the dark theme. '
            '`simpleAppBar` resolves `Theme.of(Get.context!)` — a context that is NOT the '
            'widget\'s own — so it registers no dependency on the Theme and the subtree is never '
            'marked dirty when the theme changes.');

    expect(contrast(after, background), greaterThanOrEqualTo(textMinimum),
        reason: 'after switching to the light theme the app bar title is $after on a $background '
            'bar — ${contrast(after, background)}:1, so the title is unreadable on every one of '
            'the 28 screens that use this app bar until something else rebuilds them.');

    Get.delete<ThemeController>();
  });

  testWidgets('and back again, light -> dark', (tester) async {
    pinGoldenSurface(tester);

    if (Get.isRegistered<ThemeController>()) Get.delete<ThemeController>();
    final ThemeController controller = Get.put(ThemeController());
    controller.isDark.value = false;

    await tester.pumpWidget(appRoot(controller));
    await pumpFrames(tester, frames: 12);

    controller.changeTheme(true);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await pumpFrames(tester, frames: 8);

    final Color after = titleColour(tester);
    final Color background = barBackground(tester);

    expect(contrast(after, background), greaterThanOrEqualTo(textMinimum),
        reason: 'after switching to the dark theme the app bar title is $after on a $background '
            'bar — ${contrast(after, background)}:1. THIS IS THE DIRECTION AN `isNot` CHECK '
            'MISSES: the light branch is navy, and navy left on a dark bar is a different colour '
            'and still unreadable.');

    Get.delete<ThemeController>();
  });
}
