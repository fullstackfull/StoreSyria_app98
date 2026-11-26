// P06-WS8-A11Y-01 — the product card's STOCK pill, found by looking at a rendered screen.
// =================================================================================================
//
// HOW THIS WAS FOUND, and it was not by reading the source. `test/golden/screen_golden_test.dart`
// rendered the products screen as a pixel baseline for the first time, and the pill was measured
// OFF THE PNG rather than off a constant:
//
//     products-screen.light-ltr.png, box 100,454 → 152,472
//       background #E7F7FA  66.9 %      ← statusColor at 10 % over the white card
//       ink        #0EAED1   1.0 %      ← the label
//       contrast   2.39:1
//
// `product_widget.dart` derived ONE colour and spent it twice: the fill at 10 % alpha and the
// label opaque. So the label was painted in the same saturated hue as its own tint — the exact
// defect `status_pill.dart` was repaired for, whose own comment records the two figures it was
// fixing (2.33:1 and 2.74:1). The same mistake, in a different file, on a different surface.
//
// AND THE REPOSITORY'S OWN SOURCE ALREADY FORBADE IT. `StoreSyriaBrand.cyan` is declared with the
// docstring *"2.63:1 on white — an accent and a dark-surface brand, **never light-mode text**"*
// (`store_syria_brand.dart:34`). `LightThemeColor.cAccent` is that cyan, `AppColor.themeGreenColor`
// is `cAccent`, and `product_widget.dart:75` spends it as light-mode text. This is not a palette
// opinion; it is a rule this codebase wrote down and a live call site broke.
//
// WHAT CHANGED, AND WHAT DELIBERATELY DID NOT. The TINT HUE IS KEPT AND ONLY THE LABEL MOVES —
// the decision already recorded at `order_status_badge.dart:40-44` and again in
// `status_pill.dart:4-11`, because the tinted fills are what make a grid of products scannable.
// Only the combinations that FAIL move; a passing colour is left alone rather than tidied, so the
// change is as small as the measurement justifies. Every figure below is computed from the
// composited chip (`statusColor` at 10 % over the card), not from the raw hue:
//
//     state         theme   label before   was        label after             is
//     in stock      light   #0EAED1        2.39:1     #15558F --ss-blue-800   7.00:1
//     in stock      dark    #22C7EA        6.19:1     unchanged               6.19:1
//     on backorder  light   #F59E0B        1.99:1     #5D3F04 --ss-amber-900  8.92:1
//     on backorder  dark    #F59E0B        5.99:1     unchanged               5.99:1
//     out of stock  light   #EF4444        3.29:1     #8C1D17 --ss-red-800    7.98:1
//     out of stock  dark    #EF4444        3.70:1     #F3A9A4 dark danger fg  7.31:1
//
// THE REPLACEMENTS ARE NOT A NEW PALETTE. They are the per-theme semantic foregrounds the Store
// Syria design system already defines and that `common_snak_bar_widget.dart:127-145` already
// transcribed into this app from `public/css/store-syria-ds.css`. Nothing new is introduced; a
// table that existed is reached by one more call site.
//
// WHY `--ss-blue-800` AND NOT `--ss-green-800` FOR "IN STOCK". Semantically in-stock is a success,
// and the design system's success foreground is `#165E34`, which measures 7.11:1 here — it would
// also pass. But the CHIP is the brand CYAN, not green, and a dark green label inside a pale cyan
// chip reads as two different meanings stacked. `--ss-blue-800` is the darkest shade of the cool
// family the chip's own hue belongs to (`StoreSyriaBrand`'s band is hue 189.4–218.9), so the chip
// stays one colour idea. Both were measured before choosing; the choice is legibility-equal and
// coherence-better.
//
// WHY 4.5:1 AND NOT 3:1. The label is `fontSize: 9.5.sp` at `FontWeight.w700`. On the 360pt design
// surface `.sp` is 1:1, so that is 9.5 logical pixels ≈ 7.1 pt — far below WCAG's 14 pt-bold
// large-text threshold. SC 1.4.3 asks 4.5:1.
//
// WHAT THIS TEST DOES NOT COVER. The card's SECONDARY text (`#8A8F98` on white, the "Stock: 12"
// row and the placeholder icon) measures 3.25:1 and also fails 1.4.3 at 10.5 sp. It is NOT fixed
// here and NOT asserted here: `subTextColor` is spent at eight sites in this one widget and
// darkening it to the design system's `--ss-grey-700` (`#434D4C`, already transcribed in
// `error_empty_state.dart:299`) repaints the whole secondary layer of every product card. That is
// a palette decision of the kind this project escalates rather than a documented rule being
// broken. It is reported with its measurement, not quietly carried.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';

import '../support/golden_harness.dart';

/// The two hosts the pill is really placed on, read from `product_widget.dart:39`.
const _cardLight = Color(0xFFFFFFFF);
const _cardDark = Color(0xFF18263F);

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

/// [fg] composited onto [bg] — what a merchant's eye actually receives.
///
/// The pill's fill is 10 % translucent, so a ratio taken against the raw hue would be a number
/// nobody sees. `status_pill_contrast_test.dart` records the same compositing step for the same
/// reason.
Color _flatten(Color fg, Color bg) => Color.fromARGB(
      255,
      ((fg.r * fg.a + bg.r * (1 - fg.a)) * 255.0).round(),
      ((fg.g * fg.a + bg.g * (1 - fg.a)) * 255.0).round(),
      ((fg.b * fg.a + bg.b * (1 - fg.a)) * 255.0).round(),
    );

double _contrast(Color fg, Color bg) {
  final l1 = _lum(_flatten(fg, bg)), l2 = _lum(bg);
  final hi = math.max(l1, l2), lo = math.min(l1, l2);

  return (hi + 0.05) / (lo + 0.05);
}

String _hex(Color c) => '#'
    '${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}';

/// One product card, in the state [trackStock]/[stock]/[stockStatus] select.
///
/// `goldenHost` rather than a bare `MaterialApp`: the card reads `Theme.of(context).brightness`
/// AND the process-global `AppColor` that `ThemeController.theme` reassigns, and it renders `.tr`
/// labels. A bare `ThemeData(brightness:)` would paint colours the app never paints — trap 1 in
/// `golden_harness.dart`.
Future<void> _pumpCard(
  WidgetTester tester, {
  required bool dark,
  required bool trackStock,
  required String stock,
  String? stockStatus,
}) async {
  pinGoldenSurface(tester);

  await tester.pumpWidget(goldenHost(
    dark: dark,
    direction: TextDirection.ltr,
    child: Builder(
      builder: (context) => SizedBox(
        width: 220,
        height: 290,
        child: allProductsListItemWidget(
          context: context,
          imageUrl: '',
          categoryName: 'Textiles',
          productId: '41',
          productName: 'Damask Cotton Scarf',
          price: '24.00',
          status: 1,
          trackStock: trackStock,
          stock: stock,
          stockStatus: stockStatus,
          rating: 4.0,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// The pill is the ONLY `Container` in this widget whose fill is 10 % translucent
/// (`product_widget.dart:346`). Every other alpha in the file is .06, .07, .18, .72, .78, .8 or
/// .95, so this is an exact identification rather than a guess — and the assertion that exactly
/// one matches is what keeps it one if that ever stops being true.
Container _pill(WidgetTester tester) {
  final pills = tester
      .widgetList<Container>(find.byType(Container))
      .where((c) =>
          c.decoration is BoxDecoration &&
          ((c.decoration! as BoxDecoration).color?.a ?? 1.0) > 0.09 &&
          ((c.decoration! as BoxDecoration).color?.a ?? 1.0) < 0.11)
      .toList();

  expect(pills, hasLength(1),
      reason: 'expected exactly one 10 %-translucent fill, the stock pill. Found ${pills.length} — '
          'either the pill changed its alpha or another element now shares it, and this test is '
          'measuring the wrong thing');

  return pills.single;
}

Color _pillFill(WidgetTester tester) => (_pill(tester).decoration! as BoxDecoration).color!;

Color _pillLabel(WidgetTester tester) {
  final texts = tester
      .widgetList<Text>(find.descendant(of: find.byWidget(_pill(tester)), matching: find.byType(Text)))
      .toList();

  expect(texts, hasLength(1), reason: 'the stock pill should hold exactly one label');

  return texts.single.style!.color!;
}

void main() {
  setUpAll(loadAppFonts);
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  /// The three states, as the card's own `resolveStockState` reaches them. `on_backorder` is
  /// reachable ONLY through the untracked branch: for a tracked product the quantity decides and
  /// the stored column is ignored (`stock_state.dart:46-60`), so a test that passed
  /// `stockStatus: 'on_backorder'` with `trackStock: true` would silently measure the in-stock
  /// chip and report it as backorder.
  const states = <String, (bool trackStock, String stock, String? stockStatus)>{
    'in stock': (true, '12', null),
    'on backorder': (false, '0', 'on_backorder'),
    'out of stock': (true, '0', null),
  };

  for (final dark in <bool>[false, true]) {
    final theme = dark ? 'dark' : 'light';
    final card = dark ? _cardDark : _cardLight;

    for (final entry in states.entries) {
      final (trackStock, stock, stockStatus) = entry.value;

      testWidgets('the ${entry.key} pill label reaches 4.5:1 on its own tint — $theme',
          (tester) async {
        await _pumpCard(
          tester,
          dark: dark,
          trackStock: trackStock,
          stock: stock,
          stockStatus: stockStatus,
        );

        final chip = _flatten(_pillFill(tester), card);
        final label = _pillLabel(tester);
        final ratio = _contrast(label, chip);

        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'the ${entry.key} label ${_hex(label)} measures '
                '${ratio.toStringAsFixed(2)}:1 against its own composited chip ${_hex(chip)} in '
                '$theme mode. The label is 9.5 sp w700 — 7.1 pt, small text — so SC 1.4.3 asks '
                '4.5:1. Darken (light) or lighten (dark) the LABEL; do not repaint the tint, '
                'which is what makes the grid scannable');
      });
    }

    testWidgets('the tint hue is unchanged, in $theme', (tester) async {
      await _pumpCard(tester, dark: dark, trackStock: true, stock: '12');

      final fill = _pillFill(tester);

      expect(fill.a, closeTo(0.10, 0.001),
          reason: 'the pill fill is no longer a 10 % tint. The repair this file pins moved the '
              'LABEL and deliberately left the fill alone: replacing the tint with an opaque '
              'pastel is the change status_pill_contrast_test.dart measured as actively harmful '
              'on this app\'s navy dark card (1.03:1 — the chip shape disappears)');
    });
  }
}
