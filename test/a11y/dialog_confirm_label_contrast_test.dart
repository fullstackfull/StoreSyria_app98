import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';

/// P2.5 a11y — the label on a destructive confirm button, measured on the fill it sits on.
/// =================================================================================================
///
/// FOUND BY PHOTOGRAPHING THE DIALOG, which had never been photographed: it is an overlay, and
/// `component_gallery_capture_test.dart:187` says in as many words that a static gallery cannot
/// hold one, so it captured the BUTTON and left the dialog alone. Driven and captured in four
/// combinations for the Phase 2.5 matrix, the confirm button's pixels came back `#FFFFFF` on
/// `#EF4444` — 3.76:1, against the 4.5:1 SC 1.4.3 asks of text this size.
///
/// The label is 14.sp at `FontWeight.w600`. WCAG's large-text allowance (3:1) needs 18.66px AND
/// bold, or 24px, so neither half applies and the bar is 4.5:1.
///
/// AND IT WAS NOT ONE CALL SITE. Twelve `AppDialog.showCustomDialog` call sites pass one of four
/// different reds as `confirmColor`, and white failed on three of the four:
///
///     AppColor.cRedText  #dc0303  light   5.18:1  ok
///     AppColor.cRedText  #FF6B6B  dark    2.78:1  FAIL   <- 7 call sites, in dark mode
///     Colors.red         #F44336          3.68:1  FAIL   <- 4 call sites
///     danger             #EF4444          3.76:1  FAIL   <- 1 call site
///
/// so "delete this customer", "delete this order", "delete this product" and the rest were all
/// under the minimum in at least one theme.
///
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
/// WHAT THIS FILE PINS, AND THE TWO WAYS IT REFUSES TO PASS VACUOUSLY
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
///
/// 1. THE SET OF REDS IS A RATCHET. `confirmColor:` is read out of `lib/` and compared with the
///    list measured here. A thirteenth call site passing an unmeasured colour FAILS this test
///    rather than slipping through — the figures above are only true of the colours they name.
///
/// 2. EACH CASE ASSERTS THE OLD VALUE WAS REALLY FAILING. A rule that returned white everywhere
///    would still satisfy "the label contrasts" on `#dc0303`, which passed all along. So each red
///    that was below the minimum is asserted to have been below it, and the repair asserted
///    separately.
///
/// And the rule is checked as WIRED, not just as arithmetic: a real `AppButton` is pumped and the
/// foreground its `ElevatedButton` resolves is compared with `AppButton.labelFor`. A static helper
/// nothing calls would otherwise pass every case in this file.
void main() {
  const double textMinimum = 4.5;

  /// The four reds the twelve call sites pass. `AppColor.cRedText` is theme-MUTATED — the light
  /// and dark theme classes both declare it — so it contributes two values, not one.
  const Map<String, int> confirmReds = <String, int>{
    'AppColor.cRedText (light)': 0xFFDC0303,
    'AppColor.cRedText (dark)': 0xFFFF6B6B,
    'Colors.red': 0xFFF44336,
    'danger / #EF4444': 0xFFEF4444,
  };

  /// The ones white was failing on. `#dc0303` is deliberately absent: it passed, and a case that
  /// claimed otherwise would be measuring nothing.
  const List<String> wasFailing = <String>[
    'AppColor.cRedText (dark)',
    'Colors.red',
    'danger / #EF4444',
  ];

  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  double contrast(Color a, Color b) {
    final double la = luminance(a) + 0.05;
    final double lb = luminance(b) + 0.05;
    return la > lb ? la / lb : lb / la;
  }

  test('every colour a call site passes as confirmColor is one this file measures', () {
    // THE RATCHET. Not a style check: the figures in this file are claims about specific
    // colours, and an unmeasured thirteenth would make them a claim about nothing.
    final Set<String> seen = <String>{};

    for (final FileSystemEntity entity
        in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      for (final RegExpMatch m
          in RegExp(r'confirmColor:\s*([^,\n]+)').allMatches(entity.readAsStringSync())) {
        seen.add(m.group(1)!.trim());
      }
    }

    expect(seen, isNotEmpty,
        reason: 'no confirmColor is passed anywhere any more, so this file measures nothing');

    const Set<String> measured = <String>{'danger', 'AppColor.cRedText', 'Colors.red'};

    expect(seen.difference(measured), isEmpty,
        reason: 'a call site passes a confirm colour this test has never measured: '
            '${seen.difference(measured)}. Measure it and add it to `confirmReds`, or the '
            'contrast figures here do not cover the whole dialog.');
  });

  test('AppColor.cRedText really does differ between the two themes', () {
    // The premise for counting `cRedText` twice. If the two theme classes ever converge, one of
    // the two rows above stops describing anything.
    final String source = File('lib/utils/colors.dart').readAsStringSync();

    for (final int colour in <int>[0xFFDC0303, 0xFFFF6B6B]) {
      final String hex = colour.toRadixString(16).substring(2).toLowerCase();

      expect(source.toLowerCase().contains('0xff$hex'), isTrue,
          reason: '#$hex is no longer a cRedText value, so the per-theme measurement is stale');
    }
  });

  confirmReds.forEach((String name, int value) {
    final Color fill = Color(value);

    test('the confirm label can be read on $name', () {
      final Color label = AppButton.labelFor(fill);
      final double now = contrast(label, fill);

      expect(now, greaterThanOrEqualTo(textMinimum),
          reason: 'the confirm label resolves to '
              '#${(label.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()} '
              'on $name, which is $now:1. This is the button that destroys a customer, an order '
              'or a product, at 14.sp w600 — not large text, so the bar is $textMinimum.');
    });

    if (wasFailing.contains(name)) {
      test('white really was failing on $name', () {
        // THE OTHER DIRECTION. Without this, a rule that always returned white would still pass
        // the case above on the one red that was fine, and these three would be measuring a
        // repair that had not happened.
        expect(contrast(Colors.white, fill), lessThan(textMinimum),
            reason: 'white on $name is not below the minimum, so this red was never one of the '
                'failures this file exists for');

        expect(AppButton.labelFor(fill), isNot(Colors.white),
            reason: 'the rule still hands $name a white label');
      });
    }
  });

  test('the navy primary keeps its white label', () {
    // A filled button that was already right must not be "fixed". Everything in this app that is
    // not a destructive confirm is this colour.
    expect(AppButton.labelFor(AppColor.themeNavyBlueColor), Colors.white,
        reason: 'the rule flipped the primary button to dark ink, so it is not choosing by '
            'contrast — it is choosing by something else');
  });

  testWidgets('a real AppButton uses the rule', (tester) async {
    // THE WIRING. `labelFor` could be correct and uncalled.
    const Color fill = Color(0xFFEF4444);

    // `ScreenUtilInit`, because AppButton sizes itself with `48.h` and ScreenUtil throws a
    // LateError if it has never been initialised. Pumped bare, this case failed on the harness
    // rather than on the rule.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppButton(text: 'Delete', onPressed: () {}, backgroundColor: fill),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final ElevatedButton button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final Color? resolved = button.style?.foregroundColor?.resolve(<WidgetState>{});

    expect(resolved, AppButton.labelFor(fill),
        reason: 'the button resolved $resolved, which is not what `labelFor` returns, so the '
            'rule is not the one the widget actually draws with');
  });

  testWidgets('an explicit textColor from the caller still wins', (tester) async {
    // The rule decides the DEFAULT. A caller that has asked for a specific ink must still get it,
    // or this change would silently overrule twelve screens' deliberate choices.
    const Color fill = Color(0xFFEF4444);
    const Color chosen = Color(0xFF00FF00);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppButton(
                text: 'Delete',
                onPressed: () {},
                backgroundColor: fill,
                textColor: chosen,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final ElevatedButton button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(button.style?.foregroundColor?.resolve(<WidgetState>{}), chosen,
        reason: 'the contrast rule overrode an explicit textColor');
  });
}
