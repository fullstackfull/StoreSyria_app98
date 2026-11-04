// P2.5-A-09 -- the active/inactive status pill on five merchant surfaces.
//
// WHAT WAS WRONG. `statusPill` derived ONE colour and spent it three ways: the
// fill at 9% alpha, the dot opaque, and the label opaque. So the label and the
// dot were painted in the same saturated hue as their own tint. Measured on the
// real hosts (all five light hosts are white):
//
//   #00B894 label on the composited #E8F9F5  ->  2.33:1   (needs 4.5:1)
//   #FF5C5C label on the composited #FFF0F0  ->  2.74:1   (needs 4.5:1)
//
// Two failures: WCAG 1.4.3 for the label and 1.4.11 for the 5dp dot, which is
// the only non-text carrier of the same information.
//
// WHAT THE FIRST DRAFT OF THE REPAIR GOT WRONG, and why this file asserts the
// fill is UNCHANGED. The draft also replaced the 9% tint with the web design
// system's opaque pastel fills. Measured, that was unearned and actively
// harmful:
//
//   * Foreground-only already clears everything with >2.6x margin (the eight
//     assertions below), so the fill change bought no compliance at all.
//   * Against Flutter's navy card #18263F the opaque active fill #102A1B
//     measures 1.03:1 -- the chip shape disappears -- and the inactive fill
//     turns DARKER than the card it sits on, punching a hole in it. The web can
//     carry those values because its dark card is the neutral #262b33; this
//     app's is a navy at a different luminance. Mirroring the web transplants
//     safely for the two FOREGROUNDS and not for the two FILLS.
//   * The house decision for this exact defect class is already recorded at
//     order_status_badge.dart:40-44: "THE HUE IS KEPT AND ONLY THE TEXT DARKENS
//     -- the tinted backgrounds are what make a status column scannable".
//
// So assertion (d) pins the tint, and a later "tidy-up" to an opaque fill fails
// loudly rather than quietly regressing dark mode.
//
// AND WHY THERE IS NO `isDark` PARAMETER. The draft added `required bool isDark`
// and edited all five call sites. `Builder` gives the widget the ambient Theme
// from the real element tree instead: it works under the plain `MaterialApp`
// that test/rtl/customer_card_direction_test.dart pumps (where `Get.isDarkMode`
// does not), it honours a local `Theme` override, it touches zero call sites,
// and it keeps the signature byte-identical -- which is the backward-compatible
// repair the owner's decision asks for and which
// optional_params_are_optional_test.dart:17-21 records. Assertion (b) is what
// proves the dark branch is genuinely reached through it.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';

// Copied from test/a11y/empty_state_contrast_test.dart:34-59, as that file's
// siblings do. Its existence is also the answer to "a translucent fill cannot
// be measured honestly": it can, by compositing it first.
double _lum(Color c) {
  double ch(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * ch((c.r * 255.0).round()) +
      0.7152 * ch((c.g * 255.0).round()) +
      0.0722 * ch((c.b * 255.0).round());
}

/// [fg] composited onto [bg] -- what a merchant's eye actually receives.
Color flatten(Color fg, Color bg) {
  final a = fg.a;
  return Color.fromARGB(
    255,
    ((fg.r * a + bg.r * (1 - a)) * 255.0).round(),
    ((fg.g * a + bg.g * (1 - a)) * 255.0).round(),
    ((fg.b * a + bg.b * (1 - a)) * 255.0).round(),
  );
}

double contrast(Color fg, Color bg) {
  final flat = flatten(fg, bg);
  final l1 = _lum(flat), l2 = _lum(bg);
  final hi = math.max(l1, l2), lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

// The values the widget must paint. Declared here rather than imported, so this
// file asserts the RENDERED property and a change to the widget fails it.
const _tintActive = Color(0xFF00B894);
const _tintInactive = Color(0xFFFF5C5C);
const _fgActiveLight = Color(0xFF165E34); // --ss-green-800
const _fgInactiveLight = Color(0xFF8C1D17); // --ss-red-800
const _fgActiveDark = Color(0xFF7FD6A0); // dark --ss-success-fg
const _fgInactiveDark = Color(0xFFF3A9A4); // dark --ss-danger-fg

/// The three real hosts the pill is placed on, read from the call sites.
const _white = Color(0xFFFFFFFF);
const _pickerDark = Color(0xFF0F1A2E);

Future<void> _pumpPill(
  WidgetTester tester, {
  required bool dark,
  bool isActive = true,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      // A PLAIN MaterialApp on purpose, not GetMaterialApp: this is the harness
      // test/rtl/customer_card_direction_test.dart uses, and the one where
      // Get.isDarkMode would have read the wrong thing.
      builder: (_, __) => MaterialApp(
        home: Theme(
          data: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            body: Center(
              child: statusPill(label: 'active', isActive: isActive),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Color _labelColour(WidgetTester tester) =>
    tester.widget<Text>(find.text('active')).style!.color!;

Color _dotColour(WidgetTester tester) {
  final dots = tester
      .widgetList<Container>(find.byType(Container))
      .where((c) =>
          c.decoration is BoxDecoration &&
          (c.decoration! as BoxDecoration).shape == BoxShape.circle)
      .toList();
  expect(dots, hasLength(1), reason: 'Expected exactly one circular dot.');
  return (dots.single.decoration! as BoxDecoration).color!;
}

BoxDecoration _fillDecoration(WidgetTester tester) {
  final fills = tester
      .widgetList<Container>(find.byType(Container))
      .where((c) =>
          c.decoration is BoxDecoration &&
          (c.decoration! as BoxDecoration).borderRadius != null)
      .toList();
  expect(fills, hasLength(1), reason: 'Expected exactly one rounded fill.');
  return fills.single.decoration! as BoxDecoration;
}

final GlobalKey _boundary = GlobalKey();

/// Rasterises the pill over [host] and counts opaque pixels by colour.
///
/// The assertions above read `Text.style.color` and a `BoxDecoration` -- which
/// are DECLARATIONS. This repository has been bitten three times in one week by
/// a test that read a declaration and reported it as what ships. So this one
/// goes through Skia: it is the only thing here that proves no ancestor opacity,
/// blend mode or theme override intervenes between the declaration and the
/// merchant's eye.
///
/// Pattern copied from test/brand/brand_is_painted_test.dart, including the
/// `runAsync` -- `toImage()` completes only when the REAL event loop turns, and
/// awaiting it inside the fake one hangs until the test times out.
Future<Map<String, int>> _paintCounts(
  WidgetTester tester, {
  required bool dark,
  required Color host,
  bool isActive = true,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        home: Theme(
          data: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: host,
            body: Center(
              // The HOST goes INSIDE the boundary. The pill's fill is 9%
              // translucent, so if the host is left outside, the fill
              // rasterises at alpha ~23 and the opaque-pixel filter below drops
              // it -- which is how the first run of this test reported zero
              // fill pixels. Compositing has to happen inside the thing being
              // photographed.
              child: RepaintBoundary(
                key: _boundary,
                child: ColoredBox(
                  color: host,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: statusPill(label: 'active', isActive: isActive),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  final Uint8List bytes = (await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData data =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final out = data.buffer.asUint8List();
    image.dispose();
    return out;
  }))!;

  final counts = <String, int>{};
  for (var i = 0; i + 3 < bytes.length; i += 4) {
    if (bytes[i + 3] < 200) continue;
    final key = '#'
        '${bytes[i].toRadixString(16).padLeft(2, '0')}'
        '${bytes[i + 1].toRadixString(16).padLeft(2, '0')}'
        '${bytes[i + 2].toRadixString(16).padLeft(2, '0')}';
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

void main() {
  // (a) THE EIGHT MEASURED RATIOS, with the 9% fill composited onto each real
  //     host first. The expected values are pinned, not just the threshold, so
  //     a drift that still clears 4.5:1 is still reported.
  group('measured contrast on the real hosts', () {
    final cases = <String, (Color, Color, Color, double)>{
      'light active': (_fgActiveLight, _tintActive, _white, 7.19),
      'light inactive': (_fgInactiveLight, _tintInactive, _white, 8.24),
      'dark active on the navy card':
          (_fgActiveDark, _tintActive, DarkThemeColor.cCardBackground, 7.53),
      'dark inactive on the navy card':
          // 7.18, not the 7.38 predicted when this repair was planned: five of
          // the six predicted ratios were exact and this one was 0.2 out. The
          // number here is what the repo's own compositing helper computes.
          (_fgInactiveDark, _tintInactive, DarkThemeColor.cCardBackground, 7.18),
      'dark active on the picker sheet':
          (_fgActiveDark, _tintActive, _pickerDark, 8.74),
      'dark inactive on the picker sheet':
          (_fgInactiveDark, _tintInactive, _pickerDark, 8.28),
    };

    cases.forEach((name, c) {
      final (fg, tint, host, expected) = c;
      test('$name clears 1.4.3 for the label and 1.4.11 for the dot', () {
        final fill = flatten(tint.withValues(alpha: .09), host);
        final ratio = contrast(fg, fill);

        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: '$name label measures $ratio:1 on the composited fill.');
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: 'The 5dp dot carries the same information as the label and '
                'is non-text, so 1.4.11 applies to it.');
        expect(ratio, closeTo(expected, 0.05),
            reason: 'The ratio moved. Either a colour changed or a host did.');
      });
    });

    test('PREMISE: the OLD single-colour pill really did fail', () {
      // If this ever passes, the thresholds above are measuring nothing.
      expect(contrast(_tintActive, flatten(_tintActive.withValues(alpha: .09), _white)),
          lessThan(4.5));
      expect(contrast(_tintInactive, flatten(_tintInactive.withValues(alpha: .09), _white)),
          lessThan(4.5));
    });
  });

  // (b) THE DARK BRANCH IS GENUINELY REACHED. Read off the BUILT TREE, not from
  //     the source: this is what proves Builder sees the ambient Theme.
  testWidgets('the dark foreground is what actually gets painted',
      (tester) async {
    await _pumpPill(tester, dark: true);
    expect(_labelColour(tester), _fgActiveDark);

    await _pumpPill(tester, dark: true, isActive: false);
    expect(_labelColour(tester), _fgInactiveDark);
  });

  testWidgets('the light foreground is what actually gets painted',
      (tester) async {
    await _pumpPill(tester, dark: false);
    expect(_labelColour(tester), _fgActiveLight);

    await _pumpPill(tester, dark: false, isActive: false);
    expect(_labelColour(tester), _fgInactiveLight);
  });

  // (c) THE currentColor INVARIANT, which the original finding omitted. On the
  //     web `.ss-badge__dot` is `background: currentColor` -- the dot IS the
  //     foreground. If they drift apart the dot silently returns to failing.
  testWidgets('the dot is painted in the same colour as the label',
      (tester) async {
    for (final dark in [false, true]) {
      for (final active in [true, false]) {
        await _pumpPill(tester, dark: dark, isActive: active);
        expect(_dotColour(tester), _labelColour(tester),
            reason: 'dark=$dark active=$active: the dot and the label diverged.');
      }
    }
  });

  // (d) THE FILL MUST NOT BECOME OPAQUE. See the docblock: against the navy
  //     card the web's opaque pastels measure 1.03:1 and the inactive one goes
  //     darker than the card.
  testWidgets('the 9% tint fill is unchanged in both themes', (tester) async {
    for (final dark in [false, true]) {
      await _pumpPill(tester, dark: dark);
      final fill = _fillDecoration(tester).color!;
      expect(fill.a, closeTo(0.09, 0.005),
          reason: 'dark=$dark: the fill lost its transparency. An opaque fill '
              'makes the chip vanish into the navy dark card.');
      expect(fill.toARGB32(), _tintActive.withValues(alpha: .09).toARGB32());
    }
  });

  // (e) THE PIXELS, not the declarations. See _paintCounts.
  testWidgets('the DS foreground is what Skia actually paints, dark',
      (tester) async {
    final counts = await _paintCounts(
      tester,
      dark: true,
      host: DarkThemeColor.cCardBackground,
    );

    expect(counts[_hex(_fgActiveDark)] ?? 0, greaterThanOrEqualTo(9),
        reason: 'The dark foreground ${_hex(_fgActiveDark)} is not in the '
            'rasterised output. The 5dp dot alone should contribute a solid '
            'core of it. Painted colours present: '
            '${counts.entries.toList().length} distinct.');

    expect(counts.containsKey(_hex(_tintActive)), isFalse,
        reason: 'The saturated tint ${_hex(_tintActive)} is still being painted '
            'opaque somewhere. That is the 2.33:1 defect itself -- before the '
            'repair it was the dot and the label.');

    expect(counts[_hex(flatten(_tintActive.withValues(alpha: .09), DarkThemeColor.cCardBackground))] ?? 0,
        greaterThan(0),
        reason: 'The 9% tint fill is not reaching the canvas at all, so the '
            'chip has lost its shape against the card.');
  });

  testWidgets('the DS foreground is what Skia actually paints, light',
      (tester) async {
    final counts = await _paintCounts(tester, dark: false, host: _white);

    expect(counts[_hex(_fgActiveLight)] ?? 0, greaterThanOrEqualTo(9),
        reason: 'The light foreground ${_hex(_fgActiveLight)} is not in the '
            'rasterised output.');
    expect(counts.containsKey(_hex(_tintActive)), isFalse);
  });
}
