import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/wallet/wallet_controller.dart';
import 'package:store_go_app/view/new_widgets/balance_card.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-WALLET-CARD — in dark mode the wallet's primary action was invisible: 1.03:1.
/// =================================================================================================
///
/// **FOUND IN A CAPTURE, CONFIRMED BY ARITHMETIC.** `flutter-wallet_en_ltr_dark.png`
/// (`evidence/flutter-ops-2026-11-09/`) shows the balance card with ONE button on it. The light
/// capture of the same screen shows two. "Add Funds" had not moved and had not failed to render —
/// it was drawn in a colour 1.03:1 against the colour behind it.
///
/// THE ROOT CAUSE IS A NAME. `AppColor.themeNavyBlueColor` is not navy. It is a mutable static that
/// the active theme reassigns (`light_theme.dart:26`, `dark_theme.dart:28`), and in DARK mode it
/// becomes `DarkThemeColor.cPrimary` — `StoreSyriaBrand.cyanOnDark`, a bright cyan. The card built
/// its gradient as `[themeNavyBlueColor, themeNavyBlueColor, themeGreenColor]`, reading as
/// "navy, navy, cyan"; in dark mode that evaluated to "cyan, cyan, cyan" and the card became a flat
/// cyan slab. The filled button then drew `themeGreenColor` at 70% over that cyan, bordered and
/// LABELLED in `themeNavyBlueColor` — cyan on cyan.
///
/// Measured on the colours the widget actually used:
///
/// | element | dark | light |
/// |---|---:|---:|
/// | "Add Funds" label on its own fill | **1.03:1** | 2.16:1 |
/// | its border against the card | **1.02:1** | — |
/// | "Withdraw" label (white) on the card | 2.05:1 | 4.05:1 |
/// | the balance itself (white) on the card | 2.05:1 | 6.42:1 |
///
/// So dark mode failed every one of them and light mode failed three — the "premium" card was the
/// least readable surface in the app, in both themes.
///
/// THE REPAIR, AND WHY IT IS SHAPED THIS WAY. A label's contrast against a GRADIENT depends on
/// where along the gradient it sits, which is why "white on the brand card" kept drifting under
/// 4.5:1 towards the cyan end. Both buttons are therefore SOLID, SELF-CONTAINED surfaces: the
/// label is measured against its own fill, not against the card, and that number — 13.94:1 — holds
/// wherever the button lands and in both themes. Each then carries a border in the opposite tone,
/// so at every point of the gradient at least one of (fill, border) clears 3:1 against the card,
/// which is what makes the control perceivable as a control (WCAG 2.1 SC 1.4.11).
///
/// The dark gradient is additionally pinned to a dark SURFACE navy rather than to whatever
/// `themeNavyBlueColor` currently means, which is what restores the headline balance from 2.05:1 to
/// 16.05:1.
///
/// This test reads the colours OFF THE RENDERED WIDGETS — the gradient from the card's own
/// `BoxDecoration`, each fill and border from the button's, each label from its `TextStyle`. It
/// would still pass if someone changed the constants and still fail if they changed what is drawn.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// WCAG 2.1 relative luminance and contrast. Defined here rather than imported because every
  /// a11y test in this directory carries its own copy (`toast_type_contrast_test.dart:124`,
  /// `dropdown_hint_contrast_test.dart`, `field_focus_contrast_test.dart`) and a shared helper
  /// would be a refactor of files this change does not otherwise touch.
  double channel(int v) {
    final c = v / 255.0;
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  double luminance(Color c) {
    final r = (c.r * 255).round(), g = (c.g * 255).round(), b = (c.b * 255).round();
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
  }

  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Flattens a possibly translucent colour onto an opaque one, which is what the screen does.
  Color flatten(Color fg, Color bg) {
    final a = fg.a;
    int mix(double f, double b) => ((f * 255) * a + (b * 255) * (1 - a)).round().clamp(0, 255);
    return Color.fromARGB(255, mix(fg.r, bg.r), mix(fg.g, bg.g), mix(fg.b, bg.b));
  }

  Color lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  Future<_CardColours> renderCard(WidgetTester tester, {required bool isDark}) async {
    final api = ApiStub()..on('wallet/transactions', <String, Object?>{'status': 0});
    late final WalletController controller;

    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: balanceCard(isDark: isDark, controller: controller, context: context),
        ),
      ),
      api: api,
      combination: kFourCombinations.firstWhere((c) => c.name == (isDark ? 'dark-ltr' : 'light-ltr')),
      register: () {
        controller = Get.put(WalletController());
      },
    );
    await drainToasts(tester);

    final gradient = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.gradient)
        .whereType<LinearGradient>()
        .first;

    /// The two buttons, in layout order: `cardButton` wraps each in an `InkWell` whose child is a
    /// `Container` with a fill and a border. Reading them from the tree rather than from constants
    /// is the point — a change to what is DRAWN has to move these numbers.
    final buttons = find
        .descendant(of: find.byType(InkWell), matching: find.byType(Container))
        .evaluate()
        .map((e) => e.widget as Container)
        .where((c) => c.decoration is BoxDecoration)
        .toList();

    expect(buttons.length, greaterThanOrEqualTo(2),
        reason: 'premise: the card did not render its two action buttons');

    final labels = find
        .descendant(of: find.byType(InkWell), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).style!)
        .toList();

    expect(labels.length, greaterThanOrEqualTo(2),
        reason: 'premise: the card did not render both button labels');

    return _CardColours(
      gradient: gradient.colors,
      fills: buttons.take(2).map((b) => (b.decoration! as BoxDecoration).color).toList(),
      borders: buttons
          .take(2)
          .map((b) => (b.decoration! as BoxDecoration).border?.top.color)
          .toList(),
      labels: labels.take(2).map((s) => s.color!).toList(),
    );
  }

  /// Samples the gradient where a button can land. `t` runs the full band because the card's
  /// height — and so where the button row sits along a topLeft→bottomRight gradient — changes with
  /// the text scale and the locale.
  const samples = <double>[0.0, 0.25, 0.5, 0.75, 1.0];

  for (final isDark in <bool>[false, true]) {
    final theme = isDark ? 'dark' : 'light';

    testWidgets('$theme: every button label clears 4.5:1 against its own fill', (tester) async {
      final card = await renderCard(tester, isDark: isDark);

      for (var i = 0; i < 2; i++) {
        final fillRaw = card.fills[i];
        expect(fillRaw, isNotNull,
            reason: '$theme button $i has no fill, so its label is measured against the GRADIENT '
                'and its contrast changes with where the button sits. Both buttons are meant to be '
                'solid, self-contained surfaces.');
        expect(fillRaw!.a, 1.0,
            reason: '$theme button $i has a translucent fill ($fillRaw), so the card shows through '
                'and the label contrast depends on the gradient again. That translucency — '
                '`themeGreenColor.withValues(alpha: 0.7)` over a cyan card — is what produced the '
                '1.03:1 reading.');

        final ratio = contrast(card.labels[i], fillRaw);
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: '$theme button $i label ${card.labels[i]} on fill $fillRaw is only '
                '${ratio.toStringAsFixed(2)}:1. WCAG 1.4.3 wants 4.5:1 for text this size.');
      }
    });

    testWidgets('$theme: every button stays perceivable against the whole gradient', (tester) async {
      /// WCAG 2.1 SC 1.4.11: a control has to be distinguishable from what is behind it. The card
      /// is a gradient, so this checks the WHOLE band — the original defect was a border at
      /// 1.02:1 against the exact point it sat on.
      final card = await renderCard(tester, isDark: isDark);

      for (var i = 0; i < 2; i++) {
        for (final t in samples) {
          final behind = lerp(card.gradient.first, card.gradient.last, t);
          final fill = flatten(card.fills[i]!, behind);
          final border = card.borders[i] == null ? null : flatten(card.borders[i]!, behind);

          final best = math.max(
            contrast(fill, behind),
            border == null ? 0.0 : contrast(border, behind),
          );

          expect(best, greaterThanOrEqualTo(3.0),
              reason: '$theme button $i is only ${best.toStringAsFixed(2)}:1 against the card at '
                  't=$t ($behind). Neither its fill ($fill) nor its border ($border) separates it '
                  'from the gradient there, so at that point it reads as part of the card — which '
                  'is exactly how "Add Funds" vanished in dark mode.');
        }
      }
    });

    testWidgets('$theme: the balance itself is readable where it is drawn', (tester) async {
      /// The headline sits at the gradient's START (top-left), in white. In dark mode that start
      /// used to be cyan, so the merchant's balance was 2.05:1.
      final card = await renderCard(tester, isDark: isDark);

      final ratio = contrast(const Color(0xFFFFFFFF), card.gradient.first);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: '$theme: white on the gradient start ${card.gradient.first} is only '
              '${ratio.toStringAsFixed(2)}:1, and the balance, the currency and the '
              '"Current Balance" caption are all drawn in white there.');
    });
  }

  testWidgets('the dark card is not the light card: the gradient really is theme-aware',
      (tester) async {
    /// The control. If both themes resolved the same gradient, every assertion above would be
    /// testing one configuration twice — and a "dark mode" that is identical to light is the
    /// defect this repository has shipped before (four byte-identical LTR/RTL baselines,
    /// `RESUME-POINT-2026-10-27.md`).
    final light = await renderCard(tester, isDark: false);
    resetScreenHarness();
    final dark = await renderCard(tester, isDark: true);

    expect(dark.gradient.first, isNot(light.gradient.first),
        reason: 'the balance card renders the same gradient start in both themes');
  });
}

class _CardColours {
  _CardColours({
    required this.gradient,
    required this.fills,
    required this.borders,
    required this.labels,
  });

  final List<Color> gradient;
  final List<Color?> fills;
  final List<Color?> borders;
  final List<Color> labels;
}
