// WS K. The toast a merchant now sees when the server refuses — measured, not assumed.
//
// `success_toast_requires_status_check_test` proves the right TYPE is passed:
// 14 closures that showed a green success for a refused operation now check the
// body first. What it cannot say is whether the merchant can SEE the difference,
// and that is the half this file measures.
//
// WHAT IS MEASURED, and getting the backdrop right is most of the work. The type
// colour paints the ICON (`common_snak_bar_widget.dart:355`), and that icon sits
// on a circle of ITS OWN COLOUR at 10% alpha (`:350`), composited over the toast
// surface — white in light mode, `#18263F` in dark (`:295`). So the contrast
// question is icon-vs-its-own-tint, not icon-vs-surface. Measuring against the
// plain surface gives numbers that are close enough to look right and are wrong:
// success light reads 3.30 against white and 2.96 against the real backdrop,
// which is the difference between passing and failing.
//
// WCAG 2.1 SC 1.4.11 Non-text Contrast asks 3:1 for an icon that conveys
// meaning, which these do — the icon is what distinguishes a refusal from a
// confirmation at a glance. Body text is NOT at issue: the title uses
// `titleColor` (`:297`), not the type colour.
//
// THE RESULT, and FOUR of the eight combinations fail:
//
//     success  light  2.9562  FAIL     success  dark  4.0608  ok
//     error    light  4.1329  ok       error    dark  2.9997  FAIL
//     warning  light  2.8561  FAIL     warning  dark  4.2456  ok
//     info     light  5.7945  ok       info     dark  2.1063  FAIL
//
// `error` DARK IS ONE OF THEM, AND I NEARLY REPORTED THE OPPOSITE. Rounded to two
// places it reads 3.00 and looks like a pass; it is 2.9997, and this test caught
// it on its first run after I had already written "error passes in both themes"
// into the docblock. Three thousandths below a threshold is still below it, and
// `error` is the type every one of those 14 WS K closures now routes a refusal
// to — so the honest statement is that the path the change feeds is marginally
// under the non-text minimum in dark mode, not that it is clear.
//
// WHAT THE CHANGE DID AND DID NOT DO. All four shortfalls are PRE-EXISTING: the
// palette is untouched by WS K. What the change did was route MORE traffic to a
// toast that was already marginal. It did not make any ratio worse, and it is
// not the thing to fix here — four shortfalls in one four-colour palette is a
// PALETTE decision, not four independent bugs, and the fix means changing colour
// values in a component every screen uses. Recorded as F277 for whoever owns it.
//
// SO THIS IS A RATCHET, NOT A FAILING TEST. It pins the current measurement in
// both directions: the four that pass cannot regress, and the four that fail
// cannot get worse without saying so — and when somebody fixes one, this test
// tells them to come here and record it.
//
// NO SCREENSHOT EVIDENCE IS PRODUCIBLE FOR THIS REPOSITORY IN THIS CONTAINER,
// and that is stated rather than worked around: there is no golden-file harness
// and no emulator here. The Laravel side's merchant UI changes are captured with
// real browser screenshots; the Flutter side's are not, and claiming otherwise
// would be the thing the project's own rules forbid.

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The type colours, read from `common_snak_bar_widget.dart`'s `_styles` map.
///
/// Copied rather than imported because `_styles` and `_SnackStyle` are private.
/// A drift test below pins the copy against the source, so a palette change
/// cannot leave this file measuring colours the app no longer uses.
const Map<String, int> typeColours = <String, int>{
  'success': 0xFF16A34A,
  'error': 0xFFDC2626,
  'warning': 0xFFD97706,
  'info': 0xFF1C53C7,
};

const int lightSurface = 0xFFFFFFFF;
const int darkSurface = 0xFF18263F;

/// The alpha of the circle the icon sits on (`common_snak_bar_widget.dart:350`).
const double iconBackdropAlpha = 0.10;

/// WCAG 2.1 SC 1.4.11, non-text contrast.
const double nonTextMinimum = 3.0;

double _channel(int v) {
  final double s = v / 255.0;
  return s <= 0.03928
      ? s / 12.92
      : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) =>
    0.2126 * _channel((c.r * 255).round()) +
    0.7152 * _channel((c.g * 255).round()) +
    0.0722 * _channel((c.b * 255).round());

double contrast(Color a, Color b) {
  final double la = _luminance(a) + 0.05;
  final double lb = _luminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}

/// `fg` at [alpha] over `bg`, the way Flutter composites a simple alpha fill.
Color composite(Color fg, Color bg, double alpha) => Color.fromARGB(
  255,
  (alpha * (fg.r * 255) + (1 - alpha) * (bg.r * 255)).round(),
  (alpha * (fg.g * 255) + (1 - alpha) * (bg.g * 255)).round(),
  (alpha * (fg.b * 255) + (1 - alpha) * (bg.b * 255)).round(),
);

double iconContrast(int colour, int surface) {
  final Color c = Color(colour);
  final Color backdrop = composite(c, Color(surface), iconBackdropAlpha);
  return contrast(c, backdrop);
}

void main() {
  test('the copied palette still matches the widget source', () {
    // THE PREMISE. Every measurement below is about colours this file holds a
    // copy of. If the widget's palette changes and this does not, the numbers
    // describe an app that no longer exists.
    final String source = File(
      'lib/view/widget/common_snak_bar_widget.dart',
    ).readAsStringSync();

    for (final MapEntry<String, int> entry in typeColours.entries) {
      final String hex = entry.value
          .toRadixString(16)
          .substring(2)
          .toUpperCase();
      expect(
        source.contains('0xFF$hex'),
        isTrue,
        reason:
            'the ${entry.key} colour in this test (#$hex) is not in '
            'common_snak_bar_widget.dart any more, so every contrast figure '
            'here is measuring a palette the app no longer uses',
      );
    }

    expect(
      source.contains('alpha: .10'),
      isTrue,
      reason:
          'the icon backdrop alpha changed, so the composited backdrop '
          'these measurements use is wrong',
    );
    expect(
      source.contains('0xFF18263F'),
      isTrue,
      reason: 'the dark toast surface changed',
    );
  });

  group('the refusal a merchant sees is legible', () {
    test('error is clear in light mode and MARGINAL in dark — stated, not '
        'rounded away', () {
      expect(
        iconContrast(typeColours['error']!, lightSurface),
        greaterThanOrEqualTo(nonTextMinimum),
      );

      // 2.9997. Pinned as a range rather than asserted to pass, because
      // rounding it to 3.00 and calling it clear is exactly the move this file
      // exists to prevent. The lower bound stops a regression; the upper bound
      // makes a palette fix fail loudly so it gets recorded here.
      expect(
        iconContrast(typeColours['error']!, darkSurface),
        inInclusiveRange(2.95, 3.00),
        reason:
            'the error icon in dark mode has moved off its recorded '
            '2.9997. Above 3.0 it now MEETS WCAG 1.4.11 — move it to the '
            'passing set and say so. Below 2.95 it got worse, and this is the '
            'toast fourteen WS K closures route a refused operation to.',
      );
    });

    test('and error is visually distinct from success, not merely a different '
        'word', () {
      expect(
        contrast(Color(typeColours['error']!), Color(typeColours['success']!)),
        greaterThan(1.2),
        reason: 'the error and success colours are too close to tell apart',
      );
    });
  });

  group('F277 — the four pre-existing shortfalls, pinned so they cannot '
      'quietly get worse', () {
    // Measured values at the time of writing. Each is asserted as a RANGE: the
    // lower bound stops a regression, the upper bound makes a fix fail loudly
    // so whoever lands it updates this list rather than leaving it stale.
    const Map<String, List<double>> known = <String, List<double>>{
      'success-light': <double>[2.90, 3.00],
      'error-dark': <double>[2.95, 3.00],
      'warning-light': <double>[2.80, 2.95],
      'info-dark': <double>[2.05, 2.20],
    };

    test('they are still exactly these four, at these values', () {
      final Map<String, double> measured = <String, double>{
        'success-light': iconContrast(typeColours['success']!, lightSurface),
        'error-dark': iconContrast(typeColours['error']!, darkSurface),
        'warning-light': iconContrast(typeColours['warning']!, lightSurface),
        'info-dark': iconContrast(typeColours['info']!, darkSurface),
      };

      known.forEach((String key, List<double> bounds) {
        expect(
          measured[key],
          inInclusiveRange(bounds[0], bounds[1]),
          reason:
              '$key now measures ${measured[key]!.toStringAsFixed(2)}, '
              'outside the recorded ${bounds[0]}–${bounds[1]}. If it IMPROVED '
              'past 3.0 the shortfall is fixed — remove it from this list and '
              'add it to the passing set. If it got WORSE, that is a '
              'regression.',
        );
      });
    });

    test('and no FIFTH combination has joined them', () {
      final List<String> failing = <String>[];

      for (final MapEntry<String, int> entry in typeColours.entries) {
        for (final MapEntry<String, int> surface in <String, int>{
          'light': lightSurface,
          'dark': darkSurface,
        }.entries) {
          final double r = iconContrast(entry.value, surface.value);
          if (r < nonTextMinimum) {
            failing.add(
              '${entry.key}-${surface.key} '
              '(${r.toStringAsFixed(2)})',
            );
          }
        }
      }

      failing.sort();
      final List<String> expected = known.keys.toList()..sort();

      expect(
        failing.map((String f) => f.split(' ').first).toList(),
        expected,
        reason:
            'the set of toast types failing WCAG 1.4.11 has changed. '
            'Measured: ${failing.join(", ")}',
      );
    });
  });
}
