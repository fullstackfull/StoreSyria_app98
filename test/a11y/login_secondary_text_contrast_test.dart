// P2.5-A-11 -- the three muted lines on the login card, measured where they are PAINTED.
//
// The login card carried the literal `Colors.grey` (#9E9E9E) three times:
//
//   login_widget.dart:99          "please login to continue to your store!"   15.sp w500
//   login_widget.dart:191         "or continue with"                          13.sp w400
//   powered_by_lynomia.dart:20    "Powered by Lynomia"                        14.sp w400
//
// The card beneath them is OPAQUE -- `Get.isDarkMode ? Color(0xff2d3446) : Colors.white`
// (login_widget.dart:61-64) -- so the background image at :43-50 cannot show through and the
// measurement is unambiguous: #9E9E9E on #FFFFFF is 2.68:1 against the 4.5:1 WCAG 1.4.3 asks.
// None of the three reaches the large-text exemption. This is the first screen a merchant sees.
//
// THE REPAIR READS THE APP'S OWN SECONDARY-TEXT COLOURS rather than naming a grey --
// LightThemeColor.cFont (#66728C) and DarkThemeColor.cSecondaryText (#A9B8D0) -- which is the
// idiom the two already-shipped siblings use and say they use: error_empty_state.dart:81-93
// (P2.5-A-04) and common_drop_down_widget.dart:39 (P2.5-A-06).
//
// DELIBERATELY NOT `Theme.of(context).hintColor`. It resolves to the SAME two values
// (theme_controller.dart:92 feeds it from `secondaryText`), so it would pass this test -- but it
// re-couples body prose to the channel that dropdown_hint_contrast_test.dart:152-159 pins as the
// dropdown HINT colour. A future change made for form-field legibility would then silently move
// login prose with nothing to notice. Also not `AppColor.cFont`: a mutable process-global
// reassigned on every theme switch (light_theme.dart:21, dark_theme.dart:23), readable stale.
//
// THE DARK BRANCH WAS ALREADY PASSING at 4.63:1 and moves to 6.18:1. That is a deliberate
// restyle of a conformant branch, recorded as such -- not a dark-mode defect.
//
// STILL NOT UNIFIED, deliberately, and the ledger must not claim otherwise: the same card paints
// field hints in #687386 (app_txt_field.dart:109, 4.79:1 -- passing) and the password eye icon in
// Colors.white70/#687386 at :140. Those pass, so changing them would be a restyle, not a repair.
//
// TWO HARNESS TRAPS THIS FILE AVOIDS, both already paid for once in this repo:
//
//  1. THE THEME MUST COME FROM ThemeController, never `ThemeData(brightness: ...)`. Flutter's
//     default hintColor is `black.withOpacity(0.6)` in light (theme_data.dart:487), which
//     composites to ~#666666 = 5.74:1 on white -- so a bare-ThemeData test PASSES while the app
//     paints something else entirely. dropdown_hint_contrast_test.dart:34-40 records that exact
//     mistake being made here before.
//  2. `ThemeController.theme` HAS A SIDE EFFECT: it calls AppDarkTheme.darkColor() /
//     AppLightTheme.lightThemeColor() (theme_controller.dart:23, :40), which reassign the
//     process-global AppColor that `pMedium14`/`pRegular12`/`pSemiBold27` read as getters. A test
//     that builds the dark theme and does not restore makes every later light assertion in the
//     file measure dark values. Hence setUp() + an explicit restore.
//
// The background is read OUT OF THE BUILT TREE (the real Card's `color`), not assumed, so the
// test cannot drift from the widget if the card is ever restyled.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/theme_light/light_theme.dart';
import 'package:store_go_app/core/controller/auth/auth_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/screen/auth/login_widget.dart';

double _lum(Color c) {
  double ch(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * ch((c.r * 255.0).round()) +
      0.7152 * ch((c.g * 255.0).round()) +
      0.0722 * ch((c.b * 255.0).round());
}

double contrast(Color fg, Color bg) {
  final a = fg.a;
  final flat = Color.fromARGB(
    255,
    ((fg.r * a + bg.r * (1 - a)) * 255.0).round(),
    ((fg.g * a + bg.g * (1 - a)) * 255.0).round(),
    ((fg.b * a + bg.b * (1 - a)) * 255.0).round(),
  );
  final l1 = _lum(flat), l2 = _lum(bg);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

String hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// The app's OWN ThemeData, built the way `store_go.dart:42/:68` builds it.
ThemeData appTheme({required bool dark}) {
  final c = ThemeController();
  c.isDark.value = dark;
  return c.theme;
}

Future<void> pumpLogin(WidgetTester tester, {required bool dark}) async {
  // Pin the surface to the design size. Without this the default 800x600 window makes ScreenUtil
  // scale every `.sp` by 2.22 while a raw `fontSize:` stays put, which is how the first draft of
  // `loginTitle` came to measure the submit button instead of the heading.
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        theme: appTheme(dark: dark),
        home: NormalLoginWidget(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

/// The colour the engine will actually paint for [finder]: the widget's own style merged
/// onto the inherited DefaultTextStyle, which is what `Text` itself does.
Color resolvedColour(WidgetTester tester, Finder finder) {
  final element = tester.element(finder);
  final text = tester.widget<Text>(finder);
  final inherited = DefaultTextStyle.of(element).style;
  final merged = text.style == null ? inherited : inherited.merge(text.style);
  final colour = merged.color;
  expect(colour, isNotNull,
      reason: 'premise: this Text resolves to a concrete colour, so a ratio is measurable');
  return colour!;
}

/// The login TITLE, told apart from the submit button. `"login".tr` is on this screen twice --
/// login_widget.dart:87 is the heading, :155 is the `AppButton` label -- so a bare `find.text`
/// throws "Too many elements".
///
/// SIZE IS NOT A SAFE DISCRIMINATOR HERE, and the first draft of this helper got it wrong.
/// `pSemiBold27` declares a RAW `fontSize: 27` (text_style.dart:202) while the button label is
/// expressed in `.sp`, so ScreenUtil scales one and not the other: on the default 800x600 test
/// window the 360-wide design scales `.sp` by 2.22 and the BUTTON renders larger than the
/// heading. Picking "the biggest" therefore selected the button -- whose white-on-primary label
/// measures 1.00:1 against the white card, which is what the failure said. The viewport is now
/// pinned to the design size as well, but the title is identified by its own declared style,
/// which cannot be confused by a scale factor.
Finder loginTitle(WidgetTester tester) {
  final all = find.text('login'.tr);
  expect(tester.widgetList<Text>(all).length, greaterThan(1),
      reason: 'premise: the login key really is on both the heading and the button');

  final title = find.byWidgetPredicate(
    (w) => w is Text && w.data == 'login'.tr && w.style?.fontSize == 27,
    description: 'the 27pt login heading (pSemiBold27), not the AppButton label',
  );
  expect(title, findsOneWidget,
      reason: 'premise: exactly one of the two login-key Texts carries pSemiBold27');
  return title;
}

/// The opaque surface these three lines sit on, read from the real Card.
Color cardColour(WidgetTester tester) {
  final card = tester.widget<Card>(find.byType(Card).first);
  expect(card.color, isNotNull, reason: 'premise: the login Card paints an explicit colour');
  return card.color!;
}

const _subheading = 'please login to continue to your store!';
const _divider = 'or continue with';
const _poweredBy = 'Powered by Lynomia';

void main() {
  setUp(() {
    Get.reset();
    Get.put(AuthController()); // login_widget.dart:21 resolves it in a field initialiser
    AppLightTheme.lightThemeColor();
  });

  tearDown(() {
    Get.reset();
    AppLightTheme.lightThemeColor(); // undo the global AppColor mutation, whatever ran
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('every muted line on the login card clears 4.5:1 in $mode mode', (tester) async {
      await pumpLogin(tester, dark: dark);

      final bg = cardColour(tester);

      for (final key in [_subheading, _divider, _poweredBy]) {
        final finder = find.text(key.tr);
        expect(finder, findsOneWidget, reason: 'premise: "$key" is on the login card');

        final fg = resolvedColour(tester, finder);
        final r = contrast(fg, bg);

        expect(r, greaterThanOrEqualTo(4.5),
            reason: '"$key" is ${hex(fg)} on ${hex(bg)} = ${r.toStringAsFixed(2)}:1 '
                'in $mode mode; WCAG 1.4.3 asks 4.5:1 and none of these three '
                'reaches the large-text exemption');
      }
    });

    // The repair must not flatten the card into one muted value. The title is the only thing
    // establishing hierarchy here, and an over-reaching fix (pushing the secondary colour onto
    // the whole card) would drop it from ~14:1 to 4.83:1 while still passing the test above.
    testWidgets('the login title stays far darker than the prose in $mode mode', (tester) async {
      await pumpLogin(tester, dark: dark);

      final bg = cardColour(tester);
      final title = resolvedColour(tester, loginTitle(tester));
      final prose = resolvedColour(tester, find.text(_subheading.tr));

      final rTitle = contrast(title, bg), rProse = contrast(prose, bg);

      expect(rTitle, greaterThanOrEqualTo(7.0),
          reason: 'the title is ${hex(title)} = ${rTitle.toStringAsFixed(2)}:1; it was '
              '13.94:1 light / 11.35:1 dark before the repair and must not have been '
              'dragged down to the prose colour');
      expect(rTitle, greaterThan(rProse),
          reason: 'title ${rTitle.toStringAsFixed(2)}:1 vs prose ${rProse.toStringAsFixed(2)}:1 '
              '-- the visual hierarchy is gone');
    });
  }

  // NEGATIVE CONTROL 1. The grey being replaced really was below threshold on the light card,
  // and really was ABOVE it on the dark one -- so "fixed dark too" is a restyle, not a repair.
  test('the premise: Colors.grey failed on the light card and passed on the dark one', () {
    const grey = Color(0xFF9E9E9E);
    final light = contrast(grey, const Color(0xFFFFFFFF));
    final dark = contrast(grey, const Color(0xFF2D3446));

    expect(light, lessThan(4.5), reason: 'light measured ${light.toStringAsFixed(2)}:1');
    expect(light, closeTo(2.68, 0.01));
    expect(dark, greaterThanOrEqualTo(4.5),
        reason: 'dark measured ${dark.toStringAsFixed(2)}:1 -- it was already conformant, so the '
            'dark change is a deliberate restyle and the ledger must say so');
    expect(dark, closeTo(4.63, 0.01));
  });

  // NEGATIVE CONTROL 2. The replacement values are the app's own tokens, pinned by arithmetic so
  // a future token move cannot quietly drop one under AA while the widget tests still pass.
  test('the replacement tokens are the ones the shipped siblings use, and they clear AA', () {
    expect(LightThemeColor.cFont, const Color(0xFF66728C));
    expect(DarkThemeColor.cSecondaryText, const Color(0xFFA9B8D0));

    final light = contrast(LightThemeColor.cFont, const Color(0xFFFFFFFF));
    final dark = contrast(DarkThemeColor.cSecondaryText, const Color(0xFF2D3446));

    expect(light, closeTo(4.83, 0.01), reason: 'measured ${light.toStringAsFixed(4)}:1');
    expect(dark, closeTo(6.18, 0.01), reason: 'measured ${dark.toStringAsFixed(4)}:1');
    // The light margin over AA is 0.33. Stated here so nobody reads 4.83 as comfortable.
    expect(light, greaterThanOrEqualTo(4.5));
  });

  // NEGATIVE CONTROL 3. The repair must not have taken the field hints or the eye icon with it:
  // both PASS already, so touching them would be a restyle outside this repair's authority.
  test('the field-hint colour the card also paints is left alone, and still passes', () {
    final r = contrast(const Color(0xFF687386), const Color(0xFFFFFFFF));
    expect(r, greaterThanOrEqualTo(4.5),
        reason: 'app_txt_field.dart:109 paints #687386 = ${r.toStringAsFixed(2)}:1; it is '
            'conformant, so it is deliberately NOT unified by this repair');
  });
}
