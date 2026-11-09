import 'dart:io';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/new_widgets/settings_card.dart';

import '../support/golden_harness.dart';
import '../support/source_tree.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-MORE-CARD — the More grid's cards were unreadable under their own titles.
/// =================================================================================================
///
/// The "More" grid is the merchant's navigation hub: Analytics, Shipping, Customers, Delivery Men
/// and Coupon are reached only from here. Its cards carry a title, a one-line explanation of what
/// the card is for, a chevron saying the card is navigable, and an icon. Three of those four were
/// below threshold, and the LIGHT theme was worse than the dark one:
///
/// | element | dark | light | needs |
/// |---|---:|---:|---:|
/// | subtitle | 3.30:1 | **2.15:1** | 4.5:1 |
/// | chevron | 2.38:1 | **1.99:1** | 3:1 |
/// | card icon | **1.89:1** | 5.72:1 | 3:1 |
///
/// THE CAUSE IS THE SAME IN ALL THREE: an alpha applied on top of a colour that was already the
/// designed secondary tone. `AppColor.cFont` resolves to `DarkThemeColor.cSecondaryText` (#A9B8D0)
/// in dark and `LightThemeColor.cFont` (#66728C) in light — both of which clear 4.5:1 on their own
/// card at FULL opacity (7.53:1 and 4.83:1). The `withValues(alpha: 0.55)` is what pushed them
/// under. The subtitle's branch was also a no-op: `isDark ? ...alpha: 0.55 : ...alpha: 0.55`, the
/// same expression twice, which is the shape of a value that was tuned for one theme and then
/// copied.
///
/// The dark icon had the same problem at `alpha: 0.3` on a tinted circle, while the light icon was
/// already drawn at full opacity — so the two themes disagreed about whether the icon was an
/// illustration or an indicator.
///
/// This measures the colours OFF THE RENDERED CARD, flattened onto what is actually behind them,
/// so it would still fail if the tokens changed underneath.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  double channel(int v) {
    final c = v / 255.0;
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  double luminance(Color c) => 0.2126 * channel((c.r * 255).round()) +
      0.7152 * channel((c.g * 255).round()) +
      0.0722 * channel((c.b * 255).round());

  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  Color flatten(Color fg, Color bg) {
    final a = fg.a;
    int mix(double f, double b) => ((f * 255) * a + (b * 255) * (1 - a)).round().clamp(0, 255);
    return Color.fromARGB(255, mix(fg.r, bg.r), mix(fg.g, bg.g), mix(fg.b, bg.b));
  }

  for (final dark in <bool>[false, true]) {
    final theme = dark ? 'dark' : 'light';
    final combination =
        kFourCombinations.firstWhere((c) => c.name == (dark ? 'dark-ltr' : 'light-ltr'));

    Future<(Color card, TextStyle subtitle, Color chevron)> render(WidgetTester tester) async {
      await pumpScreen(
        tester,
        Builder(
          builder: (_) => Scaffold(
            body: SizedBox(
              width: 170,
              height: 180,
              child: settingCard(
                icon: DefaultImages.statisticIcn,
                title: 'Analytics',
                subtitle: 'View your store\'s performance',
                isDark: dark,
                function: () {},
              ),
            ),
          ),
        ),
        api: ApiStub(),
        combination: combination,
      );
      await pumpFrames(tester, frames: 6);

      /// The card's own fill: the first `Container` under the `InkWell` that carries a decoration
      /// with a colour. Read from the tree rather than from `DarkThemeColor.cCardBackground`, so a
      /// change to which token the card uses moves this measurement too.
      final cardFill = tester
          .widgetList<Container>(
              find.descendant(of: find.byType(InkWell), matching: find.byType(Container)))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .whereType<Color>()
          .first;

      final subtitleStyle = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere((t) => (t.data ?? '').contains('performance'))
          .style!;

      final chevron = tester
          .widgetList<Icon>(find.byType(Icon))
          .firstWhere((i) => i.icon == Icons.arrow_forward_ios_rounded)
          .color!;

      return (cardFill, subtitleStyle, chevron);
    }

    testWidgets('$theme: the card subtitle is readable', (tester) async {
      final (card, subtitle, _) = await render(tester);
      final colour = flatten(subtitle.color!, card);
      final ratio = contrast(colour, card);

      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: '$theme: the card subtitle is ${ratio.toStringAsFixed(2)}:1 ($colour on $card). '
              'It is the only sentence telling a merchant what the card does, on the grid every '
              'other merchant surface is reached through. Its colour already clears 4.5:1 at full '
              'opacity; an alpha on top of it is what pushed it under.');
    });

    testWidgets('$theme: the card chevron is perceivable', (tester) async {
      final (card, _, chevron) = await render(tester);
      final colour = flatten(chevron, card);
      final ratio = contrast(colour, card);

      /// 3:1, the non-text threshold: the chevron is not decoration, it is the signal that the
      /// card is a navigation target.
      expect(ratio, greaterThanOrEqualTo(3.0),
          reason: '$theme: the card chevron is ${ratio.toStringAsFixed(2)}:1 ($colour on $card), '
              'so nothing on the card says it leads somewhere.');
    });
  }

  test('the subtitle no longer branches on a theme it does not use', () {
    /// The subtitle style was `isDark ? ...alpha: 0.55 : ...alpha: 0.55` — the SAME expression on
    /// both sides. A conditional whose branches are identical is not a choice, it is a value that
    /// was tuned once and copied, and it hid the fact that one number was serving two very
    /// different backgrounds. This fails if that shape comes back.
    /// COMMENTS STRIPPED FIRST. The first version of this guard read the raw file and failed on
    /// its own fix: the comment explaining why 0.55 was removed contains the literal `alpha: 0.55`.
    /// `codeOnly` is the project's helper for exactly this
    /// (`test/support/source_tree.dart:62`), and getting it wrong is recorded there too.
    final source = codeOnly(
      File('lib/view/new_widgets/settings_card.dart').readAsStringSync(),
    );

    expect(source.contains('alpha: 0.55'), isFalse,
        reason: 'the 0.55 alpha is back on the settings card. It measured 3.30:1 in dark and '
            '2.15:1 in light against the card it was drawn on.');
  });
}
