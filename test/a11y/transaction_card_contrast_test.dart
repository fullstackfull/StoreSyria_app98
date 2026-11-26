// GAP-271 / GAP-272 — the wallet transaction card's colours, measured against the hosts it
// really sits on.
// =================================================================================================
//
// GAP-272 RECORDS ITS OWN HAZARD — "dark passes throughout" was a figure taken on one surface —
// and checking it was right. **Dark does not pass throughout.** Measured against the card fill,
// which is what text sits on:
//
//     element                               light card #FFFFFF   dark card #18263F
//     success #16A34A  Credit, + amount           3.30:1 FAIL        4.59:1 pass
//     danger  #EF4444  Debit,  - amount           3.76:1 FAIL        **4.02:1 FAIL**
//     secondary #777D87 / #A9B8D0  12 sp          4.14:1 FAIL        7.53:1 pass
//
// The amount is 15 sp w800 — 11.25 pt, below WCAG's 14 pt-bold large-text threshold — and the
// labels are 11–12 sp, so SC 1.4.3 asks 4.5:1 of all of them.
//
// GAP-271's second half is the pill, and it is the same tint-on-tint defect this project has now
// repaired three times (`status_pill.dart`, the order badge, the product stock pill): one colour
// spent twice, as a 10%/18% fill and as its own opaque label.
//
//     light  success  chip #E8F6ED   2.96:1 FAIL
//     light  warning  chip #FEF5E7   1.99:1 FAIL
//     dark   success  chip #183C41   3.62:1 FAIL
//     dark   warning  chip #403C36   5.10:1 pass
//
// ── AND A DEFECT NEITHER ROW RECORDS, FOUND BY ASKING WHICH HOST ────────────────────────────────
//
// The coupon card taught this one commit ago: a component baseline cannot tell you what host the
// component really sits on. `transactionCard` has exactly one call site,
// `wallet_screen.dart:169`, and that screen's `Scaffold` is `backgroundColor: AppColor.cLight`
// (`:69`) — a static the themes REASSIGN: light → `LightThemeColor.cLight` `#F2F6FA`, dark →
// **`DarkThemeColor.cCardBackground` `#18263F`**.
//
// `#18263F` is the card's own dark fill. So on /finance in dark mode the card is **1.00:1 against
// its page**, with `border: isDark ? null` and `boxShadow: isDark ? null` — no edge, no shadow, no
// fill difference. The card is invisible as an object, and the comment in the widget said the
// opposite: *"nothing in dark, where `0xFF18263F` already differs from the page"*. It differs from
// the GOLDEN HARNESS's page (`DarkThemeColor.cBackGround` `#0F1A2E`, 1.15:1), which is where that
// reading was taken. It does not differ from the page the merchant sees.
//
//     host                      light            dark
//     golden harness page       #FFFFFF 1.00:1   #0F1A2E 1.15:1
//     wallet_screen.dart:69     #F2F6FA 1.09:1   #18263F **1.00:1**
//
// So the LIGHT half got the hairline (`3727efc`'s token, `LightThemeColor.cBorder`) and the dark
// half — the one with no boundary at all on its real page — got nothing. Both now have an edge.
//
// NOT CHANGED, and it is the underlying cause rather than this card's fault: a Scaffold painting
// `AppColor.cLight`, whose dark value is the CARD background, is a page wearing a card's colour.
// Fixing that moves every screen that uses the same static, which is a design decision.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/new_widgets/transactions_widget.dart';

import '../support/golden_harness.dart';
import '../support/sample_cards.dart';

const _cardLight = Color(0xFFFFFFFF);
const _cardDark = Color(0xFF18263F);

/// `AppColor.cLight` per theme — the page `wallet_screen.dart:69` really paints.
const _pageLight = Color(0xFFF2F6FA);
const _pageDark = Color(0xFF18263F);

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

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

Future<void> _pumpCard(WidgetTester tester, {required bool dark, required bool debit}) async {
  pinGoldenSurface(tester);

  await tester.pumpWidget(goldenHost(
    dark: dark,
    direction: TextDirection.ltr,
    child: Builder(
      builder: (context) => transactionCard(
        tx: debit ? sampleWithdrawalTransaction() : sampleTransaction(),
        currency: 'SYP',
        isDark: dark,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// The card's own outermost decorated `Container`.
BoxDecoration _cardDecoration(WidgetTester tester) {
  final boxes = tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => c.decoration is BoxDecoration)
      .map((c) => c.decoration! as BoxDecoration)
      .where((d) => (d.color?.a ?? 0) == 1.0)
      .toList();

  expect(boxes, isNotEmpty, reason: 'the card paints no opaque decorated Container');

  return boxes.first;
}

/// The status pill: the one translucent `Container` that holds a `Text`.
///
/// The icon tile is translucent too and at the SAME 10 % alpha in light mode, so alpha alone does
/// not identify the pill — the tile holds an `Icon`, the pill holds the label. Asserting exactly
/// one match is what keeps that true.
({Color fill, Color label}) _pill(WidgetTester tester) {
  final matches = <({Color fill, Color label})>[];

  for (final element in find.byType(Container).evaluate()) {
    final container = element.widget as Container;
    final decoration = container.decoration;

    if (decoration is! BoxDecoration) continue;
    if ((decoration.color?.a ?? 1.0) >= 0.99) continue;

    final texts = find
        .descendant(of: find.byWidget(container), matching: find.byType(Text))
        .evaluate()
        .map((e) => e.widget as Text)
        .toList();

    if (texts.length == 1) {
      matches.add((fill: decoration.color!, label: texts.single.style!.color!));
    }
  }

  expect(matches, hasLength(1),
      reason: 'expected exactly one translucent chip holding a single label — the status pill. '
          'Found ${matches.length}');

  return matches.single;
}

void main() {
  setUpAll(loadAppFonts);
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  for (final dark in <bool>[false, true]) {
    final theme = dark ? 'dark' : 'light';
    final card = dark ? _cardDark : _cardLight;

    for (final debit in <bool>[false, true]) {
      final side = debit ? 'debit' : 'credit';

      testWidgets('GAP-272: the $side accent text reaches 4.5:1 on the card — $theme',
          (tester) async {
        await _pumpCard(tester, dark: dark, debit: debit);

        final label = tester.widget<Text>(find.text(debit ? 'Debit' : 'Credit')).style!.color!;
        final ratio = _contrast(label, card);

        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'the $side label ${_hex(label)} measures ${ratio.toStringAsFixed(2)}:1 on the '
                '$theme card ${_hex(card)}. It is 11 sp w600 and the amount beside it is 15 sp '
                'w800 (11.25 pt) — both below the large-text threshold, so SC 1.4.3 asks 4.5:1');
      });

      testWidgets('GAP-272: the $side AMOUNT is painted in that same colour — $theme',
          (tester) async {
        // The amount is a `RichText` rather than a `Text`, so it is not covered by the assertion
        // above and could drift away from it. It is the largest number on the row.
        await _pumpCard(tester, dark: dark, debit: debit);

        final label = tester.widget<Text>(find.text(debit ? 'Debit' : 'Credit')).style!.color!;

        final spans = tester
            .widgetList<RichText>(find.byType(RichText))
            .map((r) => r.text)
            .whereType<TextSpan>()
            .where((s) => (s.children?.length ?? 0) == 2)
            .toList();

        expect(spans, hasLength(1), reason: 'expected one two-part amount span');

        for (final child in spans.single.children!.cast<TextSpan>()) {
          expect(child.style!.color, label,
              reason: 'the amount is painted in ${_hex(child.style!.color!)} while the $side '
                  'label is ${_hex(label)}; the two carry the same meaning and must not diverge');
        }
      });

      testWidgets('GAP-271: the $side status pill label reaches 4.5:1 on its own chip — $theme',
          (tester) async {
        await _pumpCard(tester, dark: dark, debit: debit);

        final pill = _pill(tester);
        final chip = _flatten(pill.fill, card);
        final ratio = _contrast(pill.label, chip);

        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'the pill label ${_hex(pill.label)} measures ${ratio.toStringAsFixed(2)}:1 '
                'against its own composited chip ${_hex(chip)} in $theme mode. 10 sp w600 is '
                'small text. Darken (light) or lighten (dark) the LABEL and keep the tint, which '
                'is what makes a ledger scannable');
      });
    }

    testWidgets('GAP-272: the secondary text reaches 4.5:1 on the card — $theme', (tester) async {
      await _pumpCard(tester, dark: dark, debit: false);

      // The description line, which is the longest run of secondary text on the card.
      final secondary =
          tester.widget<Text>(find.text('طلب #ORD-2043')).style!.color!;
      final ratio = _contrast(secondary, card);

      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'the secondary text ${_hex(secondary)} measures ${ratio.toStringAsFixed(2)}:1 '
              'on the $theme card. It is 12 sp — the type line, the description and the date all '
              'use it');
    });

    testWidgets('the card has a boundary in $theme, on the page it really ships on',
        (tester) async {
      /// THE HOST QUESTION. `wallet_screen.dart:69` paints `AppColor.cLight`, which the themes
      /// reassign: light `#F2F6FA`, dark `DarkThemeColor.cCardBackground` `#18263F` — the card's
      /// own fill. So in dark the card was 1.00:1 against its page with no border and no shadow.
      await _pumpCard(tester, dark: dark, debit: false);

      final decoration = _cardDecoration(tester);
      final page = dark ? _pageDark : _pageLight;
      final fillOnPage = _contrast(decoration.color!, page);

      expect(decoration.border, isNotNull,
          reason: 'the $theme card has no border. Its fill measures '
              '${fillOnPage.toStringAsFixed(2)}:1 against the page wallet_screen.dart:69 actually '
              'paints (${_hex(page)}), so without an edge there is nothing to see it by. The '
              'golden harness paints a different page, which is why a component capture reads '
              'this as fine');
    });
  }

  test('premise: the two pages this card ships on are what this file says they are', () {
    // Without this the assertions above could be measuring colours nobody paints. These are the
    // values `AppColor.cLight` takes once each theme's setter has run.
    expect(_pageLight, const Color(0xFFF2F6FA), reason: 'LightThemeColor.cLight moved');
    expect(_pageDark, _cardDark,
        reason: 'DarkThemeColor.cCardBackground is no longer the card fill, so the dark '
            '1.00:1 reading this file is built on has changed');
  });
}
