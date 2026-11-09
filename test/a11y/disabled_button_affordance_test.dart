import 'dart:math' as math;

import 'dart:ui' show SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/widget/common_button.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-BTN-DISABLED — a button with no handler looked exactly like one that works.
/// =================================================================================================
///
/// **THIS IS A LATENT DEFECT, NOT A LIVE ONE, and the distinction is stated here rather than
/// glossed.** All six `CommonButton` call sites in `lib/` pass an `onPressed`, so no shipped screen
/// renders the broken state today. It is fixed because `onPressed` is **nullable by design** — the
/// component's own signature invites `null` — and when it is null the button still paints the full
/// brand blue, still shows its white label, and simply does nothing when tapped. The next call site
/// to disable a button during validation or a permission check would ship a control that lies.
///
/// Found by rendering the component gallery (`flutter-component-buttons_*`): the specimen captioned
/// "disabled (no handler)" was indistinguishable from the one captioned "idle".
///
/// WHAT THE REPAIR OWES, from `ui-ux-pro-max` §8 `disabled-states` — "reduced opacity (0.38–0.5) +
/// cursor change + semantic attribute" — and §4 `state-clarity`:
///
///   * a VISIBLE difference, so a sighted merchant can see the control is inert;
///   * a SEMANTIC one, so a screen reader says so too. A visual-only fix would leave assistive
///     technology announcing an ordinary button.
///
/// `isLoading` is deliberately NOT treated as the same thing: it already replaces the label with a
/// spinner, which is its own clear state, and it already blocks the tap
/// (`common_button.dart:42`).
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

  /// The rendered OPACITY, not the declared fill. The button dims through `AnimatedOpacity`, so
  /// `BoxDecoration.color` is identical in both states and reading it would compare the wrong
  /// thing — which the first version of this test did.
  Future<double> opacityOf(WidgetTester tester, Widget child) async {
    await pumpScreen(
      tester,
      Builder(builder: (_) => Scaffold(body: child)),
      api: ApiStub(),
    );
    await pumpFrames(tester, frames: 8);

    return tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first).opacity;
  }

  testWidgets('a button with no handler does not look like one that works', (tester) async {
    final enabled = await opacityOf(tester, CommonButton(title: 'Send', onPressed: () {}));
    resetScreenHarness();
    final disabled = await opacityOf(tester, CommonButton(title: 'Send'));

    expect(enabled, 1.0, reason: 'premise: an enabled button is no longer drawn at full strength');

    expect(disabled, lessThan(enabled),
        reason: 'a CommonButton with `onPressed: null` is drawn exactly as strongly as one with a '
            'handler, so a merchant cannot see that it is inert. `onPressed` is nullable by '
            'design, so this is reachable the moment any call site disables a button.');

    expect(disabled, inInclusiveRange(0.38, 0.5),
        reason: 'the disabled strength is $disabled, outside the 0.38-0.5 band that reads as '
            'unavailable without becoming illegible');
  });

  testWidgets('and it says so to a screen reader', (tester) async {
    /// The half a visual fix would miss. Without this, assistive technology announces an ordinary
    /// button and a merchant who cannot see the dimming is told nothing at all.
    final handle = tester.ensureSemantics();

    await pumpScreen(
      tester,
      Builder(builder: (_) => Scaffold(body: CommonButton(title: 'Send'))),
      api: ApiStub(),
    );
    await pumpFrames(tester, frames: 6);

    // The button's OWN semantics node. `bySemanticsLabel` is avoided deliberately: it matches on
    // the merged label, and what is being asserted here is the node's flags, not its text.
    final node = tester.getSemantics(find.byType(CommonButton));

    expect(node.label, contains('Send'),
        reason: 'the disabled button exposes no accessible name at all');
    expect(node.hasFlag(SemanticsFlag.isButton), isTrue,
        reason: 'the control is not announced as a BUTTON. It is a GestureDetector around a '
            'Container, so without explicit semantics a screen reader reads its label as plain '
            'text and a merchant is never told it is actionable.');
    expect(node.hasFlag(SemanticsFlag.isEnabled), isFalse,
        reason: 'the disabled button still reports itself as ENABLED, so a screen reader '
            'announces a working control');

    handle.dispose();
  });

  testWidgets('an enabled button still reports itself enabled', (tester) async {
    /// The control. A repair that marked everything disabled would pass the test above and break
    /// every working button in the app.
    final handle = tester.ensureSemantics();

    await pumpScreen(
      tester,
      Builder(builder: (_) => Scaffold(body: CommonButton(title: 'Send', onPressed: () {}))),
      api: ApiStub(),
    );
    await pumpFrames(tester, frames: 6);

    final node = tester.getSemantics(find.byType(CommonButton));
    expect(node.hasFlag(SemanticsFlag.isEnabled), isTrue,
        reason: 'a button WITH a handler is reporting itself disabled, which would silence every '
            'working button in the app');

    handle.dispose();
  });

  testWidgets('the dimmed label is still readable against the dimmed fill', (tester) async {
    /// Dimming a control must not make it unreadable — a disabled control still has to be read to
    /// be understood. WCAG exempts disabled elements from the contrast minimum, so this holds the
    /// label to 3:1 rather than 4.5:1: enough to read, visibly weaker than the active state.
    await pumpScreen(
      tester,
      Builder(builder: (_) => Scaffold(body: CommonButton(title: 'Send'))),
      api: ApiStub(),
    );
    await pumpFrames(tester, frames: 6);

    final fill = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.color)
        .whereType<Color>()
        .first;

    final label = tester.widget<Text>(find.text('Send')).style!.color!;

    // Flatten both onto the page behind them, then compare.
    Color flatten(Color fg, Color bg) {
      final a = fg.a;
      int mix(double f, double b) => ((f * 255) * a + (b * 255) * (1 - a)).round().clamp(0, 255);
      return Color.fromARGB(255, mix(fg.r, bg.r), mix(fg.g, bg.g), mix(fg.b, bg.b));
    }

    const page = Color(0xFFFFFFFF);
    final ratio = contrast(flatten(label, flatten(fill, page)), flatten(fill, page));

    expect(ratio, greaterThanOrEqualTo(3.0),
        reason: 'the disabled label is only ${ratio.toStringAsFixed(2)}:1 on its own fill. A '
            'disabled control still has to be legible to be understood; dimming it into '
            'invisibility replaces one defect with another.');
  });
}
