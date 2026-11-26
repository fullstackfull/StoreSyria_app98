// P06-WS8-A11Y-02 — `CommonButton`'s label on its own fill, and the fade that hid its spinner.
// =================================================================================================
//
// WHERE THIS CAME FROM. `5b3c6bb` captured the shared controls as pixel surfaces and recorded, from
// looking at them, that "CommonButton's white label on the dark primary fill is 2.09:1, and the
// repair ALREADY EXISTS in this codebase and this component does not use it". It fixed nothing.
// Every figure below was re-measured here rather than carried over, and one of them came out
// different from the note — see the spinner section.
//
// ── 1. THE LABEL ────────────────────────────────────────────────────────────────────────────────
//
// `CommonButton` defaulted its label to `AppColor.cWhite` and its fill to
// `AppColor.themeNavyBlueColor`. That fill is NOT a constant: `light_theme.dart:26` sets it to
// `LightThemeColor.cPrimary` (`StoreSyriaBrand.blue`, `#335DA8`) and `dark_theme.dart:28` to
// `DarkThemeColor.cPrimary` (`StoreSyriaBrand.cyanOnDark`, `#2AC3E5`). So the same white label
// sits on a deep blue in one theme and a BRIGHT CYAN in the other:
//
//     white #FFFFFF on #335DA8   6.42:1   light — fine
//     white #FFFFFF on #2AC3E5   2.09:1   dark  — SC 1.4.3 asks 4.5:1 for 14sp w700
//
// AND THE REPAIR WAS ALREADY IN THE REPOSITORY. `AppButton.labelFor()` (`app_dialog.dart:421`)
// takes whichever of white and the app's near-black ink contrasts better with the fill, and its
// own docstring explains why it cannot make anything worse: a label that already passes keeps
// what it had. Measured on these two fills, that is exactly what happens:
//
//     labelFor(#335DA8) -> white    6.42:1  (ink would be 2.82:1, so white wins and nothing moves)
//     labelFor(#2AC3E5) -> #14161B  8.65:1  (white is 2.09:1, so the ink wins and the defect goes)
//
// ── 2. WHY THE DEFAULT ALONE WOULD HAVE BEEN A FIX THAT FIXED NOTHING ───────────────────────────
//
// **Both live call sites passed `textColor:` explicitly** — `Colors.white` in
// `exchange_currency_widget.dart:505` and `AppColor.cWhite` in `email_setting_screen.dart:151` —
// and an explicit colour from the caller wins over the default, by design. So a change to the
// default would have gone green in a widget test while the merchant kept seeing 2.09:1 on the
// "save" button of the rate sheet and on "Send Test Mail". That is this project's recurring trap:
// a test that passes for the wrong reason. The third test below is the guard against it, and it
// asserts the CALL SITES, not the widget.
//
// Dropping those two arguments is safe by construction rather than by inspection: `labelFor`
// returns white whenever white is the better of the two, so in light mode both buttons keep the
// exact colour they had.
//
// ── 3. THE LOADING FADE, WHICH IS A SEPARATE DEFECT ─────────────────────────────────────────────
//
// `AnimatedOpacity` wrapped the whole button and faded it to **0.7 while loading**. Opacity
// composites fill AND spinner toward the PAGE behind them, so the distance between the two
// shrinks by 30 % and the spinner dissolves into its own button. Measured, dark theme, spinner and
// fill each composited over `DarkThemeColor.cBackGround` `#0F1A2E`:
//
//     opacity 1.0   fill #2AC3E5   spinner #FFFFFF   2.09:1
//     opacity 0.7   fill #2290AE   spinner #B7BAC0   1.90:1   ← what shipped
//     opacity 0.5   fill #1C6E8A   spinner #878C96   1.71:1
//
// (`5b3c6bb` recorded 1.70:1. The 1.71 row above is the 0.5 DISABLED opacity, not the 0.7 loading
// one, so that note appears to have measured the wrong state's fade. The defect is real either
// way; the figure is corrected here rather than repeated.)
//
// **The disabled fade stays and is deliberately exempt** — a disabled control is meant to read as
// unavailable, `disabled_button_affordance_test.dart` pins it to the 0.38–0.5 band, and that
// file's own header already says `isLoading` is not the same thing. Loading is not a disabled
// state: it is the signal that a save is in flight, and it is the one moment the merchant is
// watching the button. So the fade is removed from the loading branch only.
//
// After both repairs, every combination clears its bar: the spinner is the resolved label colour,
// at full strength, 6.42:1 light and 8.65:1 dark.
//
// ── 4. THE BARS ─────────────────────────────────────────────────────────────────────────────────
//
// The label is `pBold14` at `fontSize: 14` — 14 logical pixels ≈ 10.5 pt, far below WCAG's
// 18.66 px-bold large-text threshold, so SC 1.4.3 asks **4.5:1**. The spinner carries no text; it
// is a graphic that conveys state, so SC 1.4.11 asks **3:1** of it.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_button.dart';

import '../support/golden_harness.dart';
import '../support/source_tree.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

/// [fg] at [opacity] over [bg] — what the eye receives once `AnimatedOpacity` has composited it.
Color _over(Color fg, Color bg, double opacity) => Color.fromARGB(
      255,
      ((fg.r * opacity + bg.r * (1 - opacity)) * 255.0).round(),
      ((fg.g * opacity + bg.g * (1 - opacity)) * 255.0).round(),
      ((fg.b * opacity + bg.b * (1 - opacity)) * 255.0).round(),
    );

double _contrast(Color a, Color b) {
  final la = _lum(a) + 0.05, lb = _lum(b) + 0.05;

  return la > lb ? la / lb : lb / la;
}

String _hex(Color c) => '#'
    '${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}';

/// `goldenHost` rather than a bare `MaterialApp`: `AppColor.themeNavyBlueColor` is a PROCESS-GLOBAL
/// that `ThemeController.theme` reassigns per theme, so a host that does not build the app's own
/// theme measures whichever value the previous test happened to leave behind. That is trap 2 in
/// `golden_harness.dart`, and it is the whole reason this widget's two fills differ at all.
Future<void> _pumpButton(WidgetTester tester, {required bool dark, bool loading = false}) async {
  pinGoldenSurface(tester);

  await tester.pumpWidget(goldenHost(
    dark: dark,
    direction: TextDirection.ltr,
    child: Builder(
      builder: (context) => CommonButton(
        title: 'save',
        isLoading: loading,
        onPressed: () {},
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 300));
}

/// The button's own fill, read off the painted `BoxDecoration` rather than off `AppColor`.
Color _fill(WidgetTester tester) {
  final boxes = tester
      .widgetList<Container>(find.descendant(
        of: find.byType(CommonButton),
        matching: find.byType(Container),
      ))
      .where((c) => c.decoration is BoxDecoration && (c.decoration! as BoxDecoration).color != null)
      .toList();

  expect(boxes, isNotEmpty, reason: 'the button paints no decorated Container');

  return (boxes.first.decoration! as BoxDecoration).color!;
}

double _opacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.descendant(
      of: find.byType(CommonButton),
      matching: find.byType(AnimatedOpacity),
    ))
    .opacity;

/// The page the button is composited over when `AnimatedOpacity` is below 1.
Color _page(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(CommonButton))).scaffoldBackgroundColor;

void main() {
  setUpAll(loadAppFonts);
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  for (final dark in <bool>[false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('the label reaches 4.5:1 on the button it sits on — $theme', (tester) async {
      await _pumpButton(tester, dark: dark);

      final fill = _fill(tester);
      final label = tester.widget<Text>(find.text('save')).style!.color!;
      final opacity = _opacity(tester);
      final page = _page(tester);

      final ratio = _contrast(_over(label, page, opacity), _over(fill, page, opacity));

      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'the label ${_hex(label)} measures ${ratio.toStringAsFixed(2)}:1 on the fill '
              '${_hex(fill)} in $theme mode. The repair already exists in this codebase: '
              'AppButton.labelFor() picks whichever of white and the near-black ink reads better, '
              'and it cannot make a passing label worse');
    });

    testWidgets('the loading spinner reaches 3:1 on the button it spins in — $theme',
        (tester) async {
      await _pumpButton(tester, dark: dark, loading: true);

      final fill = _fill(tester);
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final spinner = indicator.valueColor!.value!;
      final opacity = _opacity(tester);
      final page = _page(tester);

      final ratio = _contrast(_over(spinner, page, opacity), _over(fill, page, opacity));

      expect(ratio, greaterThanOrEqualTo(3.0),
          reason: 'the spinner ${_hex(spinner)} measures ${ratio.toStringAsFixed(2)}:1 inside its '
              'own button in $theme mode, at opacity $opacity. A spinner is a graphic that conveys '
              'state, so SC 1.4.11 asks 3:1. If the opacity above is below 1, the fade is the '
              'cause: it composites fill and spinner toward the page together, and loading is not '
              'a disabled state — it is the one moment the merchant is watching the button');
    });

    testWidgets('loading is not drawn as disabled — $theme', (tester) async {
      await _pumpButton(tester, dark: dark, loading: true);

      expect(_opacity(tester), 1.0,
          reason: 'a loading button is faded like a disabled one. The disabled fade is deliberate '
              'and stays (disabled_button_affordance_test.dart pins it to 0.38-0.5); this is the '
              'in-flight state, which must stay at full strength so its spinner can be seen');
    });
  }

  test('no call site hard-codes a white label onto a CommonButton', () {
    // THE GUARD AGAINST A FIX THAT FIXES NOTHING. The widget's DEFAULT is what the tests above
    // measure, and an explicit `textColor:` from a caller overrides it — by design, and correctly.
    // Both live call sites passed white, so the default could have been repaired while every
    // merchant kept seeing 2.09:1. White is the exact value `labelFor` exists to override when it
    // fails, so passing it by hand re-introduces the defect one call site at a time.
    //
    // The invocation's own text is extracted by matching brackets from `CommonButton(`, not by a
    // fixed window: a window would silently read into the NEXT widget and report a colour that
    // belongs to something else.
    final whites = RegExp(
      r'textColor\s*:\s*(Colors\.white|AppColor\.cWhite|AppColor\.cWhiteFont|'
      r'Color\(\s*0x[fF]{2}[fF]{6}\s*\))',
    );

    final offenders = <String>[];

    for (final file in libDartFiles()) {
      if (file.path.endsWith('common_button.dart')) continue;

      final source = codeOnly(file.readAsStringSync());

      for (final match in RegExp(r'(?<![A-Za-z0-9_])CommonButton\(').allMatches(source)) {
        var depth = 0;
        var end = match.end - 1;

        for (var i = match.end - 1; i < source.length; i++) {
          if (source[i] == '(') depth++;
          if (source[i] == ')') {
            depth--;
            if (depth == 0) {
              end = i;
              break;
            }
          }
        }

        final invocation = source.substring(match.end, end);

        if (whites.hasMatch(invocation)) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
          offenders.add('${relative(file)}:$line');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'these CommonButton call sites pass a white label explicitly, which overrides '
            'AppButton.labelFor() and pins 2.09:1 on the dark theme\'s bright cyan primary. '
            'Remove the argument and let the button choose: labelFor returns white whenever white '
            'is the better of the two, so nothing changes in light mode. '
            '${offenders.join(', ')}');
  });

  test('premise: labelFor really would change the dark fill and really would not change the light',
      () {
    // Without this, the three widget tests above could all pass because somebody pinned a colour
    // by hand, and the claim that the repair "cannot make anything worse" would be untested.
    expect(AppButton.labelFor(const Color(0xFF2AC3E5)), const Color(0xFF14161B),
        reason: 'labelFor no longer darkens the dark theme\'s primary fill');
    expect(AppButton.labelFor(const Color(0xFF335DA8)), Colors.white,
        reason: 'labelFor now darkens the LIGHT theme\'s primary fill too, which would change a '
            'label that was already passing at 6.42:1');
  });
}
