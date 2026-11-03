// P2.5-A-06 -- the dropdown hint, measured where it is PAINTED rather than where it is declared.
//
// THIS FILE EXISTS BECAUSE ITS FIRST VERSION WAS WRONG, and the way it was wrong is the single
// most expensive mistake available in this codebase.
//
// The audit reported `flutter-dropdown-hint-white-on-white`, and the reading that supports it is
// easy to make and hard to doubt:
//
//   common_drop_down_widget.dart:22  fieldBg   = ... : AppColor.cWhite        // #FFFFFF
//   common_drop_down_widget.dart:26  hintColor = ... : AppColor.cHintFont     // #FFFFFF
//   common_drop_down_widget.dart:75  hintStyle: pMedium12.copyWith(color: hintColor)
//
// White on white, 1.00:1, on three merchant forms. Two independent agents reached that conclusion,
// a third produced it as a live example in an unrelated adjudication, and the first version of this
// test "reproduced" it by reading `decoration.hintStyle.color` against `decoration.fillColor`.
//
// ALL OF THAT MEASURED A VALUE THE ENGINE THROWS AWAY. DropdownButtonFormField does not paint
// InputDecoration.hintText at all. The SDK converts it into a DropdownButton.hint widget --
// `Text(effectiveDecoration.hintText!)`, constructed with NO style (dropdown.dart:1883-1886) --
// and then blanks the decoration's own hint under its own comment, "Clear the decoration hintText
// because DropdownButton has its own hint logic" (:1898-1899). The visible hint is painted at
// :1604-1605 from `Theme.of(context).hintColor`.
//
// MEASURED, not argued. Pumping the real widget and reading the rendered Text:
//
//   Text.style.color   = null                     <- hintStyle never reaches it
//   RESOLVED color     = Theme.of(context).hintColor
//
// and this app sets that at theme_controller.dart:92 (`hintColor: secondaryText`) to
// LightThemeColor.cFont #66728C in light and DarkThemeColor.cSecondaryText #A9B8D0 in dark.
//
// SO THE FINDING IS REFUTED: the white glyph is never drawn, in either theme, at any call site.
//
// WHAT THIS FILE NOW TESTS IS THE THING THAT SHIPS. It builds the app's OWN ThemeData through
// ThemeController -- not a bare `ThemeData(brightness: ...)`, which is what made the first probe
// report a default black-at-60% and nearly produced a second wrong conclusion -- renders the
// dropdown, finds the hint the merchant actually sees, and measures its RESOLVED colour against
// the field it sits on. That protects against a real regression: a change to
// theme_controller.dart:92 would make every dropdown hint in the app illegible, and nothing else
// in the suite would notice.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/config/theme_light/dark_theme.dart';
import 'package:store_go_app/config/theme_light/light_theme.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_drop_down_widget.dart';

const String kHint = 'Select a category';

double _lum(Color c) {
  double ch(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * ch((c.r * 255.0).round()) +
      0.7152 * ch((c.g * 255.0).round()) +
      0.0722 * ch((c.b * 255.0).round());
}

/// Contrast of [fg] over [bg], compositing [fg]'s alpha first — the hint may be translucent.
double contrast(Color fg, Color bg) {
  final a = fg.a;
  final flat = Color.fromARGB(255,
      ((fg.r * a + bg.r * (1 - a)) * 255.0).round(),
      ((fg.g * a + bg.g * (1 - a)) * 255.0).round(),
      ((fg.b * a + bg.b * (1 - a)) * 255.0).round());
  final l1 = _lum(flat), l2 = _lum(bg);
  final hi = math.max(l1, l2), lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

String hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// Build the app's OWN theme, the way main.dart does, rather than a bare ThemeData.
ThemeData appTheme({required bool dark}) {
  final c = ThemeController();
  c.isDark.value = dark;
  return c.theme;
}

/// Pump the shared dropdown under the real theme and return (rendered hint colour, field fill).
Future<({Color hint, Color fill})> pumpAndRead(WidgetTester tester, {required bool dark}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        theme: appTheme(dark: dark),
        home: Scaffold(
          body: commonDropdownButtonWidget<String>(
            labelText: '',
            hint: kHint,
            list: const ['Textiles', 'Soaps'],
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final element = find.text(kHint).evaluate().single;
  final text = element.widget as Text;
  final resolved = DefaultTextStyle.of(element).style.merge(text.style);

  final field = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>));

  return (hint: resolved.color!, fill: field.decoration.fillColor!);
}

void main() {
  setUp(() => AppLightTheme.lightThemeColor());

  group('the hint a merchant actually sees', () {
    testWidgets('clears AA on the light field', (tester) async {
      AppLightTheme.lightThemeColor();
      final r = await pumpAndRead(tester, dark: false);
      final ratio = contrast(r.hint, r.fill);

      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'the RENDERED dropdown hint is ${hex(r.hint)} on ${hex(r.fill)} = '
              '${ratio.toStringAsFixed(2)}:1. On add_new_product_screen.dart:366 the label is '
              'empty, so this hint is that control\'s only text.');
    });

    testWidgets('clears AA on the dark field', (tester) async {
      AppDarkTheme.darkColor();
      final r = await pumpAndRead(tester, dark: true);
      final ratio = contrast(r.hint, r.fill);

      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'the rendered dark hint is ${hex(r.hint)} on ${hex(r.fill)} = '
              '${ratio.toStringAsFixed(2)}:1');

      AppLightTheme.lightThemeColor();
    });

    /// WHERE THE COLOUR COMES FROM. If someone "fixes" a future failure by styling the hint at the
    /// call site, this still passes — which is right, it is the ratio that matters — but if they
    /// change theme_controller.dart:92 they break every dropdown hint in the app at once, and the
    /// two tests above are the only thing that would notice. This names the single point.
    testWidgets('it comes from the theme hintColor, not from the decoration', (tester) async {
      AppLightTheme.lightThemeColor();
      final r = await pumpAndRead(tester, dark: false);

      expect(r.hint, LightThemeColor.cFont,
          reason: 'the rendered hint no longer tracks theme_controller.dart:92 '
              '(`hintColor: secondaryText`)');
    });
  });

  /// THE REFUTATION, PINNED, so the finding does not come back a third time.
  ///
  /// `hintStyle` is handed to DropdownButtonFormField and discarded: the SDK rebuilds the hint as
  /// an unstyled Text and blanks the decoration's own hintText. Anyone measuring
  /// `decoration.hintStyle.color` against `decoration.fillColor` is measuring a value no merchant
  /// can see — which is exactly how three separate readings concluded this control was painting
  /// white on white.
  testWidgets('hintStyle is discarded by the SDK, which is why the audit was wrong', (tester) async {
    AppLightTheme.lightThemeColor();
    await pumpAndRead(tester, dark: false);

    final text = find.text(kHint).evaluate().single.widget as Text;
    expect(text.style?.color, isNull,
        reason: 'the hint Text now carries a style of its own, so InputDecoration.hintStyle may '
            'have started mattering again — re-read dropdown.dart before trusting this file');
  });

  /// And the dead value itself. `AppColor.cHintFont` is white, is reassigned by NEITHER theme
  /// function, and after P2.5-A-06 has no consumer at all. It is kept only so the next person who
  /// reaches for a "hint font" finds the warning rather than the colour.
  test('cHintFont is white and reassigned by neither theme', () {
    AppLightTheme.lightThemeColor();
    expect(hex(AppColor.cHintFont), '#FFFFFF');

    AppDarkTheme.darkColor();
    expect(hex(AppColor.cHintFont), '#FFFFFF');

    AppLightTheme.lightThemeColor();
  });
}
