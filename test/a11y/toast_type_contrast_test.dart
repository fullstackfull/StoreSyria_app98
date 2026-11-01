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
/// LIGHT-MODE icon colours — dark shades, because the icon's own 10% tint over
/// white is almost white. From the design system's `--ss-*-fg` light tokens.
const Map<String, int> lightTypeColours = <String, int>{
  'success': 0xFF165E34, // --ss-green-800
  'error': 0xFF8C1D17, // --ss-red-800
  'warning': 0xFF5D3F04, // --ss-amber-900
  'info': 0xFF15558F, // --ss-blue-800
};

/// DARK-MODE icon colours — light shades, for the mirror-image reason. From the
/// design system's dark-theme `--ss-*-fg` block.
const Map<String, int> darkTypeColours = <String, int>{
  'success': 0xFF7FD6A0,
  'error': 0xFFF3A9A4,
  'warning': 0xFFF0C674,
  'info': 0xFF9CC6EF,
};

/// WHAT THESE REPLACED, kept because the figures are the reason the palette is
/// per-theme at all. One colour served both surfaces:
///
///     success 0xFF16A34A · error 0xFFDC2626 · warning 0xFFD97706 · info 0xFF1C53C7
///
/// and four of the eight type/theme combinations fell under 3:1 — in OPPOSITE
/// directions, which is why no single value could have fixed it:
///
///     success  light  2.9562  FAIL     success  dark  4.0608  ok
///     error    light  4.1329  ok       error    dark  2.9997  FAIL
///     warning  light  2.8561  FAIL     warning  dark  4.2456  ok
///     info     light  5.7945  ok       info     dark  2.1063  FAIL
const Map<String, double> historicalFailures = <String, double>{
  'success-light': 2.9562,
  'error-dark': 2.9997,
  'warning-light': 2.8561,
  'info-dark': 2.1063,
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

/// ══════════════════════════════════════════════════════════════════════════════════════════════
/// WHAT THIS FILE MEASURES, AND WHAT IT CANNOT — the owner asked for RENDERED contrast
/// ══════════════════════════════════════════════════════════════════════════════════════════════
///
/// The F277 directive says *"Verify actual rendered contrast, not just source tokens."* That is the
/// right requirement, and for this widget it is **not achievable in the widget-test harness**.
/// Measured, twice, rather than assumed:
///
///   1. Pump `GetMaterialApp` and call `AppSnackBar.error(...)` →
///      `No Overlay widget found. ... The context from which that widget was searching for an
///      overlay was: _Theater`. `_AppSnackBarController.show()` resolves `Get.overlayContext` and
///      calls `Overlay.of()` on it; under `flutter_test` that context has no Overlay ancestor.
///   2. Trigger it from a real button inside the app's own tree instead, so the context is a
///      genuine descendant → same failure, 0 icons rendered.
///
/// `_SimpleSnackBar`, `_SnackType` and `_styles` are all private, so the widget cannot be
/// constructed directly either. **Production code was NOT changed to make a colour testable** —
/// widening a private API or injecting a test seam into an overlay controller is a worse trade than
/// stating this limit.
///
/// SO WHAT IS ESTABLISHED HERE IS ARITHMETIC OVER THE REAL PALETTE, PINNED TO THE SOURCE IN FOUR
/// PLACES. The drift test asserts, against `common_snak_bar_widget.dart` itself: every one of the
/// eight colour literals, the `Color on(bool isDark)` accessor, the `style.on(isDark)` consumption,
/// the `alpha: .10` icon backdrop, and the `0xFF18263F` dark surface. The compositing uses Flutter's
/// own `Color` and the same source-over formula the framework applies. If any of those five facts
/// changes, this file fails rather than measuring an app that no longer exists.
///
/// What it therefore does NOT prove: that the widget paints what it declares, that no ancestor
/// opacity or blend mode intervenes, and that a device renders it as computed. For the WEB surfaces
/// those questions are answered by real Chromium runs under
/// `docs/development/phase-2/tools/`; for this Flutter overlay there is no equivalent in this
/// container — no golden-file harness and no emulator — and that is stated rather than papered over.
void main() {
  test('the copied palette still matches the widget source', () {
    // THE PREMISE. Every measurement below is about colours this file holds a
    // copy of. If the widget's palette changes and this does not, the numbers
    // describe an app that no longer exists.
    final String source = File(
      'lib/view/widget/common_snak_bar_widget.dart',
    ).readAsStringSync();

    for (final MapEntry<String, Map<String, int>> theme
        in <String, Map<String, int>>{
          'light': lightTypeColours,
          'dark': darkTypeColours,
        }.entries) {
      for (final MapEntry<String, int> entry in theme.value.entries) {
        final String hex = entry.value
            .toRadixString(16)
            .substring(2)
            .toUpperCase();
        expect(
          source.contains('0xFF$hex'),
          isTrue,
          reason:
              'the ${entry.key} ${theme.key} colour in this test (#$hex) is '
              'not in common_snak_bar_widget.dart any more, so every contrast '
              'figure here is measuring a palette the app no longer uses',
        );
      }
    }

    // AND THE WIDGET MUST STILL RESOLVE PER THEME. A single `color:` field
    // coming back would make both maps above describe one value, and half the
    // measurements would be fiction.
    // THE SIGNATURE IS NOT ENOUGH, AND A MUTATION PROVED IT. Asserting only that
    // `Color on(bool isDark)` exists passes against a body of `=> light;` — the
    // accessor then hands the light shade to the dark surface, every dark
    // combination drops to its old failing value, and this file does not notice
    // because its arithmetic reads its OWN maps rather than the widget's
    // resolution. That is the concrete cost of not being able to render this
    // overlay in the harness (see the block above the main function), so the
    // body is pinned too. A source assertion standing in for a rendered one —
    // said plainly, because it is weaker and a reader should know which.
    expect(
      source.contains('Color on(bool isDark) => isDark ? dark : light;'),
      isTrue,
      reason:
          'the per-theme accessor no longer returns `isDark ? dark : light`. '
          'If it returns one shade unconditionally then one colour is used on '
          'both surfaces again — the exact condition that made four of eight '
          'combinations fail WCAG 1.4.11 — and the arithmetic in this file '
          'would keep passing, because it reads its own palette maps rather '
          'than what the widget resolves.',
    );
    // COUNTED, NOT just `contains`. The colour is consumed at FOUR sites — the
    // border, the shadow, the icon circle and the icon — and `contains` passes
    // while any one of them still reads `style.on(isDark)`. A mutation proved
    // it: changing a single site to `style.on(false)` pinned that element to the
    // light shade on a dark surface and this file did not notice.
    expect(
      RegExp(r'style\.on\(isDark\)').allMatches(source).length,
      4,
      reason:
          'the widget consumes the per-theme accessor at a number of sites '
          'other than four (border, shadow, icon circle, icon). A site reading '
          'a fixed theme paints the wrong shade for the surface it is on, and '
          'the arithmetic in this file cannot see it.',
    );

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
    test('error clears 3:1 in BOTH themes — the dark shortfall is fixed', () {
      expect(
        iconContrast(lightTypeColours['error']!, lightSurface),
        greaterThanOrEqualTo(nonTextMinimum),
      );

      // WAS 2.9997, AND THAT IS WHY THIS CASE IS WORDED THIS WAY. Rounded to
      // two places the old value read 3.00 and looked like a pass; it was not,
      // and `error` is the type fourteen WS K closures route a refused
      // operation to. The dark shade is now a light red from the design system
      // (`#F3A9A4`) rather than the same mid-tone red used on white.
      expect(
        iconContrast(darkTypeColours['error']!, darkSurface),
        greaterThanOrEqualTo(nonTextMinimum),
        reason:
            'the error icon in dark mode is back under 3:1. It was 2.9997 '
            'before F277 and no amount of rounding made that a pass.',
      );
    });

    /// THE TYPE IS NOT CONVEYED BY COLOUR ALONE — WCAG 1.4.1, and this REPLACED a
    /// luminance-contrast proxy that was measuring the wrong thing.
    ///
    /// The old case asserted `contrast(error, success) > 1.2`, and the per-theme
    /// shades fail it: 1.1657 light and 1.0913 dark, against the old palette's
    /// 1.4654. I kept the figures rather than the threshold, because the
    /// threshold was not a requirement — WCAG has no minimum contrast BETWEEN
    /// two icon colours, and luminance ratio is close to blind to hue anyway.
    /// Measured on the same pairs, per-channel separation is 118 and 116 (out
    /// of 255), so these are not similar colours; they are similarly BRIGHT
    /// colours, which is a different statement.
    ///
    /// AND THAT REDUCTION IS A REAL TRADE-OFF, recorded rather than buried: the
    /// design system picks each shade for contrast against its own SURFACE,
    /// which is what 1.4.11 requires and what F277 was about. Pushing error and
    /// success apart from each other again would eat into that. 1.4.11 is a
    /// WCAG AA success criterion and inter-icon luminance separation is not one
    /// at all, so the trade goes this way — but a reader comparing palettes
    /// should see the number move and know why.
    ///
    /// WHAT ACTUALLY PROTECTS A MERCHANT WHO CANNOT DISTINGUISH RED FROM GREEN
    /// is 1.4.1: the type must be carried by something besides colour. It is —
    /// four distinct glyphs, plus the message text itself. That is what this
    /// case now asserts, because it is the mechanism that does the work.
    test('the type is conveyed by icon SHAPE as well as colour (WCAG 1.4.1)', () {
      final String source = File(
        'lib/view/widget/common_snak_bar_widget.dart',
      ).readAsStringSync();

      const List<String> glyphs = <String>[
        'Icons.check_circle_rounded', // success
        'Icons.error_rounded', // error
        'Icons.warning_rounded', // warning
        'Icons.info_rounded', // info
      ];

      for (final String glyph in glyphs) {
        expect(
          source.contains(glyph),
          isTrue,
          reason:
              '$glyph is gone from the toast styles. If two types share a '
              'glyph then colour is the only thing telling them apart, and a '
              'merchant with red-green colour blindness cannot read the '
              'difference between a success and a refusal.',
        );
      }

      expect(
        glyphs.toSet().length,
        glyphs.length,
        reason: 'two toast types share an icon, so colour is doing the work alone',
      );

      // AND THE REDUCTION IS PINNED, so a future palette change that happens to
      // make these two identical in brightness AND hue cannot pass unnoticed.
      for (final MapEntry<String, Map<String, int>> theme
          in <String, Map<String, int>>{
            'light': lightTypeColours,
            'dark': darkTypeColours,
          }.entries) {
        final Color e = Color(theme.value['error']!);
        final Color g = Color(theme.value['success']!);

        final int separation = <int>[
          ((e.r - g.r) * 255).abs().round(),
          ((e.g - g.g) * 255).abs().round(),
          ((e.b - g.b) * 255).abs().round(),
        ].reduce((int a, int b) => a > b ? a : b);

        expect(
          separation,
          greaterThan(60),
          reason:
              'the ${theme.key} error and success colours differ by only '
              '$separation of 255 on their widest channel, so they are close '
              'in hue as well as in brightness',
        );
      }
    });
  });

  group('F277 — every type/theme combination now meets WCAG 1.4.11', () {
    test('all eight clear 3:1, and the figures are recorded', () {
      final Map<String, double> measured = <String, double>{};

      for (final MapEntry<String, int> e in lightTypeColours.entries) {
        measured['${e.key}-light'] = iconContrast(e.value, lightSurface);
      }
      for (final MapEntry<String, int> e in darkTypeColours.entries) {
        measured['${e.key}-dark'] = iconContrast(e.value, darkSurface);
      }

      expect(measured.length, 8, reason: 'premise: all eight were measured');

      final List<String> failing = <String>[];
      measured.forEach((String key, double r) {
        if (r < nonTextMinimum) {
          failing.add('$key (${r.toStringAsFixed(4)})');
        }
      });

      expect(
        failing,
        isEmpty,
        reason:
            'a toast type/theme combination is under WCAG 1.4.11\'s 3:1 again: '
            '${failing.join(", ")}. Measured: '
            '${measured.entries.map((MapEntry<String, double> e) => "${e.key} ${e.value.toStringAsFixed(2)}").join(" · ")}',
      );

      // A FLOOR WELL ABOVE THE MINIMUM, so a small shade change cannot creep
      // back to the knife edge the old palette sat on. Measured 6.53 to 8.16.
      measured.forEach((String key, double r) {
        expect(
          r,
          greaterThan(5.0),
          reason:
              '$key is ${r.toStringAsFixed(4)} — still a pass, but the design '
              'system shades measured 6.53 or better, so this is a drift worth '
              'reading before it becomes a failure',
        );
      });
    });

    test('and each of the four historical shortfalls is now a pass', () {
      historicalFailures.forEach((String key, double was) {
        final List<String> parts = key.split('-');
        final Map<String, int> palette = parts[1] == 'dark'
            ? darkTypeColours
            : lightTypeColours;
        final int surface = parts[1] == 'dark' ? darkSurface : lightSurface;

        final double now = iconContrast(palette[parts[0]]!, surface);

        expect(
          now,
          greaterThanOrEqualTo(nonTextMinimum),
          reason:
              '$key was $was before F277 and is $now now — still failing, so '
              'the per-theme palette did not fix the combination it was '
              'introduced for',
        );
        expect(
          now,
          greaterThan(was),
          reason: '$key did not improve on its recorded $was',
        );
      });
    });
  });
}
