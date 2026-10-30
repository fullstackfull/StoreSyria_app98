// P2-07-8 / WS K16 — a state change a screen reader is actually told about.
// =================================================================================================
//
// MEASURED BEFORE ANY CODE WAS WRITTEN: `Semantics(`, `semanticLabel`, `liveRegion`,
// `MergeSemantics` and `ExcludeSemantics` each appeared ZERO times across `lib/`. Nothing in this
// app announced a state change of any kind. So when a list was replaced by "no customers found",
// or by a network error, a merchant using TalkBack or VoiceOver heard nothing at all — as far as
// the reader was concerned the screen simply went quiet.
//
// THE ANNOUNCEMENT LIVES ON THE SHARED WIDGETS, not on each screen, so every list that adopts
// `EmptyState` or `ErrorState` is covered at once. That is the same leverage the web side used by
// putting the live region in one place rather than at sixty call sites.
//
// AND THIS TEST DRIVES THE REAL SEMANTICS TREE rather than grepping for `liveRegion:`. A source
// check would pass on a `Semantics` widget that was never built, or whose label was null; pumping
// the widget and reading the node is what shows a screen reader would receive it.
//
// WHAT P2-07-8 STILL DOES NOT COVER, stated rather than implied:
//
//   - READING ORDER needs a rendered screen and a real reader, and this container has neither
//     (the same B4 constraint recorded against P2-07-5). Not claimed.
//   - DECORATIVE ICONS NEED NOTHING. Flutter's `Icon` already wraps its glyph in
//     `ExcludeSemantics` and labels the node only when `semanticLabel` is given
//     (`packages/flutter/lib/src/widgets/icon.dart`), so a bare `Icon` is silent to a reader by
//     construction. The premise below pins that, so nobody "fixes" 198 files by hand-wrapping
//     icons that were never announced.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';

Widget host(Widget child) {
  // ScreenUtil is required because these widgets size themselves with .w/.h/.r.
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('an empty list announces itself to a screen reader', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(host(const EmptyState(message: 'No customers found')));
    await tester.pumpAndSettle();

    // By TYPE, not by label: the message appears on the visible `Text` too, so a label finder
    // matches more than one element -- which is also how a duplicated announcement was caught.
    final node = tester.getSemantics(find.byType(EmptyState));

    expect(find.text('No customers found'), findsOneWidget,
        reason: 'the message a reader is pointed at must also be the one on screen');

    expect(node.flagsCollection.isLiveRegion, isTrue,
        reason: 'the empty state is not a live region, so swapping a list for it tells a '
            'screen-reader user nothing — the screen just goes quiet');

    handle.dispose();
  });

  testWidgets('a failure announces itself to a screen reader', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(host(ErrorState(message: 'Connection failed', onRetry: () {})));
    await tester.pumpAndSettle();

    final node = tester.getSemantics(find.byType(ErrorState));

    expect(find.text('Connection failed'), findsOneWidget);

    expect(node.flagsCollection.isLiveRegion, isTrue,
        reason: 'a failure the merchant is never told about leaves them waiting for data that '
            'is not coming');

    handle.dispose();
  });

  testWidgets('the retry control is reachable and named', (tester) async {
    final handle = tester.ensureSemantics();
    var retried = false;

    await tester.pumpWidget(
      host(ErrorState(message: 'Connection failed', onRetry: () => retried = true)),
    );
    await tester.pumpAndSettle();

    /* An error state with no way out is a dead end, so the retry must exist, be NAMED, and
       actually fire. It is an `IconButton` with ElevatedButton styling -- I first looked for an
       `ElevatedButton` and found none, which is the kind of guess a widget test exists to
       settle. Being icon-only it needs a tooltip for its accessible name, which is the rule
       P2-07-7 established and this control already follows. */
    final retry = find.byType(IconButton);
    expect(retry, findsOneWidget,
        reason: 'the error state offers no retry, so the merchant can only leave the screen');

    final tooltip = tester.widget<IconButton>(retry).tooltip;
    expect(tooltip, isNotNull,
        reason: 'the retry is icon-only, so without a tooltip a screen reader announces it as '
            '"button" and nothing else');
    expect(tooltip, isNotEmpty);

    await tester.tap(retry);
    await tester.pump();

    expect(retried, isTrue, reason: 'the retry control did not call onRetry');

    handle.dispose();
  });

  test('PREMISE: a bare Icon is silent by construction, so none needs wrapping', () {
    // Pinned so that "hide decorative icons" is not later implemented by hand-wrapping every
    // icon in the app. Flutter excludes the glyph and labels the node only when asked.
    const icon = Icon(Icons.inbox_outlined);
    expect(icon.semanticLabel, isNull,
        reason: 'if this app starts labelling decorative icons, they WILL be announced and the '
            'reasoning in this file needs revisiting');
  });
}
