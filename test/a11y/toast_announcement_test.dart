// P2.5 a11y — the toast a screen reader is actually told about.
// =================================================================================================
//
// THE DEFECT THIS GUARDS. `common_snak_bar_widget.dart` is a hand-rolled toast: the controller
// builds a raw `OverlayEntry` and inserts it, and `_SimpleSnackBar.build` returned
// `PositionedDirectional > SafeArea > SlideTransition > FadeTransition > Material > Container > Row`
// with no `Semantics` node at any level. A raw overlay subtree with no live region is not announced
// by TalkBack or VoiceOver, so a merchant using a screen reader pressed Save and was told nothing
// at all — success and refusal were indistinguishable.
//
// THIS IS THE ONLY FEEDBACK PATH FOR ROUGHLY 270 CALL SITES: every save, every refusal, every 403,
// every "action not permitted" and every demo-mode block routes through `commonToast`. So the
// announcement belongs on the one shared widget, not at 270 call sites — the same leverage
// `EmptyState`, `ErrorState` and `StaleDataNotice` already use (`error_empty_state.dart`), and the
// same shape Flutter's own `SnackBar` uses (`material/snack_bar.dart:830`): `liveRegion: true` with
// `container: true` and NO `label:`, so the visible text stays the thing that is read rather than
// being spoken twice.
//
// AND THIS TEST READS THE REAL SEMANTICS TREE. `state_announcement_test.dart`'s header insists on
// that discipline because a source grep for `liveRegion:` passes for a widget that is never built,
// or whose node is merged away. So each case here enables semantics, drives the real public entry
// point `commonToast`, finds the semantics node of the message that is actually on screen, and
// walks that node's ANCESTORS for the live-region flag. Nothing here reads
// `common_snak_bar_widget.dart` as text.
//
// ─────────────────────────────────────────────────────────────────────────────────────────────────
// WHY THE HARNESS WRAPS THE APP IN AN OUTER `Overlay`, AND WHAT THAT DOES NOT CLAIM
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//
// test/README.md records "overlay-based toasts cannot be pumped", and `add_tax_gate_test.dart`
// swallows a `No Overlay widget found` as a harness limit. MEASURED AGAIN HERE, the cause is not
// the harness:
//
//   `_AppSnackBarController.show` resolves `Get.overlayContext`, which GetX 4.7.3 defines as the
//   single child element of the root navigator's `OverlayState` context — i.e. the `_Theater`
//   element (`extension_navigation.dart:1150`). It then calls `Overlay.of(thatContext,
//   rootOverlay: true)`. Since Flutter's OverlayPortal rework, `Overlay.maybeOf` resolves through
//   the `_RenderTheaterMarker` inherited widget that each `_OverlayEntryWidget` provides
//   (`widgets/overlay.dart:634`), so it only answers for a context INSIDE an overlay entry.
//   `_Theater` is the PARENT of every entry, so no marker is above it and the lookup returns null.
//
// That ancestor chain is the same in the shipped app — `GetMaterialApp`'s `builder:` installs
// `ThemeSwitchOverlay`, which is a `Stack`, not an `Overlay` — and it was measured with an
// app-root-shaped tree, not just a bare one. So on Flutter 3.47.7 `commonToast` throws before it
// can insert anything, in debug through `Overlay.of`'s assert and in release through its `result!`.
// THAT IS A SEPARATE AND LARGER DEFECT than the one this file repairs, it is reported rather than
// fixed here, and it is the reason the harness has to supply an outer `Overlay`: with one present,
// the lookup from `_Theater` finds a marker above it and the production code resolves an overlay
// and inserts into it.
//
// SO WHAT THIS FILE PROVES, stated exactly: `commonToast` → `AppSnackBar.<type>` → `_show` →
// `_AppSnackBarController.show` → the real `OverlayEntry` → the real `_SimpleSnackBar.build`
// produces a subtree whose message sits inside a live region. Every line of that path is
// production code. What it does NOT prove is that the toast reaches an overlay in the shipped app
// at all — see the paragraph above — nor that a handset's TalkBack speaks it, which needs a device
// this container does not have.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

/// Pumps the app under an outer `Overlay` so the production overlay lookup can resolve.
///
/// `GetMaterialApp` is the real app root, so `Get.key` is wired exactly as the app wires it and
/// `Get.overlayContext` resolves the same `_Theater` it resolves in production. The outer
/// `Overlay` is the only harness-supplied part, and the header says why it is needed.
Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (_) => const GetMaterialApp(
                home: Scaffold(body: Center(child: Text('ORIGIN'))),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// True when `node` or any of its ANCESTORS is a live region.
///
/// Ancestors, because `container: true` without merging gives the flag a node of its own ABOVE the
/// message's node — which is the whole point of not setting a `label:`. A check on the message
/// node alone would report a correct fix as broken.
bool _isInsideLiveRegion(SemanticsNode node) {
  SemanticsNode? current = node;
  while (current != null) {
    if (current.flagsCollection.isLiveRegion) {
      return true;
    }
    current = current.parent;
  }
  return false;
}

/// Lets the controller's own 3-second `Timer` fire so the entry is removed the way production
/// removes it, rather than leaving a pending timer for the next test to trip over.
Future<void> _letTheToastExpire(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

void main() {
  // One `testWidgets` per type, not one case with four `expect`s: test/README.md records that
  // element-tree reuse across assertions has produced false readings here, and a bundled case can
  // pass on the first type and never reach the rest. The four share one `_SimpleSnackBar`, so the
  // repair covers them together — but a future change that special-cases one type has to come past
  // all four.
  const Map<AppSnackBarType, String> cases = <AppSnackBarType, String>{
    AppSnackBarType.success: 'Product saved',
    AppSnackBarType.error: 'Action not permitted',
    AppSnackBarType.warning: 'Stock is running low',
    AppSnackBarType.info: 'Sync finished',
  };

  for (final MapEntry<AppSnackBarType, String> entry in cases.entries) {
    final String type = entry.key.name;
    final String message = entry.value;

    testWidgets('a $type toast announces itself to a screen reader', (tester) async {
      // Disposed at the end of the BODY, not via addTearDown: flutter_test runs
      // `_verifySemanticsHandlesWereDisposed` before tearDown callbacks, so an `addTearDown` here
      // fails every case with "A SemanticsHandle was active at the end of the test" — measured.
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pumpApp(tester);

      // THE REAL PUBLIC ENTRY POINT. All ~270 sites call `commonToast`; none can reach
      // `_SimpleSnackBar`, which is private. Driving the private widget would prove only that it
      // can be constructed.
      commonToast(message, type: entry.key);
      await tester.pumpAndSettle();

      // PREMISE, asserted before the a11y question so a vacuous pass is impossible: if the toast
      // did not render, there is no node to ask about and the real assertion below would fail for
      // the wrong reason.
      expect(
        find.text(message),
        findsOneWidget,
        reason: 'the $type toast did not render, so this case cannot say anything about whether '
            'it is announced',
      );

      final SemanticsNode node = tester.getSemantics(find.text(message));

      expect(
        _isInsideLiveRegion(node),
        isTrue,
        reason: 'the $type toast is not inside a live region, so a merchant using TalkBack or '
            'VoiceOver presses Save and is told nothing — and this toast is the only feedback '
            'path for roughly 270 call sites, every refusal among them',
      );

      await _letTheToastExpire(tester);
      handle.dispose();
    });
  }

  testWidgets('the live region carries the message exactly once', (tester) async {
    // MEASURED, and it corrected my first version of this case. With `container: true` and the
    // default `explicitChildNodes: false`, the visible `Text`'s label is MERGED INTO the
    // live-region node, so that node's label IS the message — it is not empty, and there is one
    // node rather than two. That is what makes the announcement work without a `label:`.
    //
    // So the thing that can regress is not an absent label but a DOUBLED one: adding
    // `label: widget.title` to the Semantics would leave the explicit label and the merged text
    // both on the node, which is the duplication `error_empty_state.dart:41-45` records hitting
    // `EmptyState`. This case pins the label to exactly the message.
    final SemanticsHandle handle = tester.ensureSemantics();

    await _pumpApp(tester);

    commonToast('Product saved', type: AppSnackBarType.success);
    await tester.pumpAndSettle();

    SemanticsNode? liveRegion = tester.getSemantics(find.text('Product saved'));
    while (liveRegion != null && !liveRegion.flagsCollection.isLiveRegion) {
      liveRegion = liveRegion.parent;
    }

    expect(
      liveRegion,
      isNotNull,
      reason: 'no live region above the toast message, so the premise of this case is gone — see '
          'the per-type cases above',
    );
    expect(
      liveRegion!.label,
      'Product saved',
      reason: 'the live region announces something other than the message exactly once — a '
          'doubled label means a screen reader reads the same sentence twice',
    );

    await _letTheToastExpire(tester);
    handle.dispose();
  });

  tearDown(() {
    // `Get.key` is rebuilt by each `GetMaterialApp`, and the controller keeps static overlay state.
    // Resetting keeps one case's leftovers out of the next one's tree.
    Get.reset();
  });
}
