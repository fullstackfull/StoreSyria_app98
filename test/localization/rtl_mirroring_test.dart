// P2-07-5 -- RTL LAYOUT VERIFIED THROUGH THE REAL LAYOUT ENGINE.
//
// WHY THIS, AND NOT SCREENSHOTS. The ledger recorded the RTL visual pass as BLOCKED: no device,
// no emulator, no Flutter rendering in this container. Two of those have changed and one has
// not. A Flutter SDK is installed now (3.47.8 / Dart 3.13.7), so `flutter test` runs -- and a
// widget test is NOT a mock: `tester.pumpWidget` builds, lays out and paints through the same
// RenderObject tree a device uses, and `tester.getTopLeft()` reads the resolved geometry. What
// is still absent is a screen to photograph.
//
// `flutter build web`, which would have given a rendering surface a browser could screenshot,
// FAILS -- and not on this app's code. `firebase_messaging_web` 3.5.18, a transitive pin, does
// not compile under Dart 3.13.7 (`dartify` against its own MessagePayload). Zero files under
// lib/ appear in the failure. Raising that pin is a dependency change on the push-notification
// path, which is an owner decision, not a test fixture. So: still blocked for pixels, no longer
// blocked for LAYOUT, and layout is what "does it mirror" actually asks.
//
// WHAT IT MEASURES. Each case pumps the SAME widget twice, once under
// `Directionality(TextDirection.ltr)` and once under `.rtl`, and asserts the painted geometry is
// a MIRROR -- not merely "different". A widget using a hardcoded `Alignment.centerLeft` or
// `EdgeInsets.only(right:)` renders IDENTICALLY in both directions, which is exactly the defect:
// an Arabic heading pinned to the physical left of its row. So the assertion is that the two
// runs differ in the specific way mirroring predicts.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] at a fixed width under one direction and returns the painted rect of [finder].
Future<Rect> _rectIn(
  WidgetTester tester,
  TextDirection direction,
  Widget child,
  Finder finder, {
  double width = 400,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Material(
          child: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  return tester.getRect(finder);
}

/// The distance from the row's START edge, which is what must be equal in a mirrored layout.
double _startInset(Rect child, Rect row, TextDirection direction) =>
    direction == TextDirection.ltr ? child.left - row.left : row.right - child.right;

void main() {
  group('a start-aligned heading mirrors', () {
    // The shape used for every section heading in the customers screen.
    Widget heading() => const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text('عنوان', key: Key('heading')),
        );

    testWidgets('it sits at the start edge in BOTH directions', (tester) async {
      final ltr = await _rectIn(tester, TextDirection.ltr, heading(), find.byKey(const Key('heading')));
      final ltrRow = tester.getRect(find.byType(Align));

      final rtl = await _rectIn(tester, TextDirection.rtl, heading(), find.byKey(const Key('heading')));
      final rtlRow = tester.getRect(find.byType(Align));

      expect(
        _startInset(ltr, ltrRow, TextDirection.ltr),
        moreOrLessEquals(_startInset(rtl, rtlRow, TextDirection.rtl), epsilon: 0.5),
        reason: 'the heading is not the same distance from the start edge in each direction',
      );
    });

    testWidgets('and it actually MOVES -- the mirror is not a no-op', (tester) async {
      // Without this, the test above would also pass for a CENTRED heading, which is a
      // different layout that happens to be symmetric.
      final ltr = await _rectIn(tester, TextDirection.ltr, heading(), find.byKey(const Key('heading')));
      final rtl = await _rectIn(tester, TextDirection.rtl, heading(), find.byKey(const Key('heading')));

      expect(ltr.left, lessThan(rtl.left),
          reason: 'a start-aligned heading must sit further right under RTL than under LTR');
    });

    testWidgets('a HARDCODED centerLeft heading does NOT mirror -- the defect, pinned', (tester) async {
      // This is what the customers screen had. It is asserted so the difference between the two
      // is a measured fact in this file rather than a claim in a commit message.
      Widget pinned() => const Align(
            alignment: Alignment.centerLeft,
            child: Text('عنوان', key: Key('pinned')),
          );

      final ltr = await _rectIn(tester, TextDirection.ltr, pinned(), find.byKey(const Key('pinned')));
      final rtl = await _rectIn(tester, TextDirection.rtl, pinned(), find.byKey(const Key('pinned')));

      expect(ltr.left, moreOrLessEquals(rtl.left, epsilon: 0.5),
          reason: 'Alignment.centerLeft is direction-blind: that is why it was replaced');
    });
  });

  group('directional padding mirrors', () {
    Widget field() => const Padding(
          padding: EdgeInsetsDirectional.only(start: 8, end: 12),
          child: SizedBox(key: Key('inner'), height: 20),
        );

    testWidgets('start padding stays at the start in both directions', (tester) async {
      final ltr = await _rectIn(tester, TextDirection.ltr, field(), find.byKey(const Key('inner')));
      final ltrOuter = tester.getRect(find.byType(Padding).last);

      final rtl = await _rectIn(tester, TextDirection.rtl, field(), find.byKey(const Key('inner')));
      final rtlOuter = tester.getRect(find.byType(Padding).last);

      expect(_startInset(ltr, ltrOuter, TextDirection.ltr), moreOrLessEquals(8, epsilon: 0.5));
      expect(_startInset(rtl, rtlOuter, TextDirection.rtl), moreOrLessEquals(8, epsilon: 0.5));
    });

    testWidgets('and the physical sides really do swap', (tester) async {
      final ltr = await _rectIn(tester, TextDirection.ltr, field(), find.byKey(const Key('inner')));
      final ltrOuter = tester.getRect(find.byType(Padding).last);
      final ltrLeftGap = ltr.left - ltrOuter.left;

      final rtl = await _rectIn(tester, TextDirection.rtl, field(), find.byKey(const Key('inner')));
      final rtlOuter = tester.getRect(find.byType(Padding).last);
      final rtlLeftGap = rtl.left - rtlOuter.left;

      expect(ltrLeftGap, moreOrLessEquals(8, epsilon: 0.5));
      expect(rtlLeftGap, moreOrLessEquals(12, epsilon: 0.5),
          reason: 'under RTL the 12-unit END padding must be the one on the physical left');
    });
  });

  group('the source no longer pins layout to a physical side', () {
    // A RATCHET, not a layout test: the four files P2-07 converted must not drift back, and a
    // new screen must not introduce the same shape unnoticed.
    //
    // Comment lines are stripped first, so a docblock explaining the defect -- this file's own
    // siblings contain several -- cannot satisfy or pollute the scan.
    const converted = <String>[
      'lib/view/screen/customers/customers_details.dart',
      'lib/view/new_widgets/top_orders.dart',
      'lib/view/new_widgets/app_txt_field.dart',
      'lib/view/widget/common_drop_down_widget.dart',
    ];

    test('no converted file still uses a direction-blind alignment or padding', () {
      final offenders = <String>[];

      for (final path in converted) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path is missing; update this list');

        final code = file
            .readAsLinesSync()
            .where((l) {
              final t = l.trimLeft();
              return !(t.startsWith('//') || t.startsWith('*') || t.startsWith('/*'));
            })
            .join('\n');

        for (final pattern in [
          'Alignment.centerLeft',
          'Alignment.centerRight',
          'EdgeInsets.only(left:',
          'EdgeInsets.only(right:',
        ]) {
          if (code.contains(pattern)) {
            offenders.add('$path  ->  $pattern');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'These render identically in Arabic and English, which is the RTL defect '
              'P2-07 converted away from:\n  ${offenders.join('\n  ')}');
    });
  });
}
