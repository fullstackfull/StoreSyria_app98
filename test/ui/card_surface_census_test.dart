import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/coupon_widget.dart';
import 'package:store_go_app/view/new_widgets/top_orders.dart';

import '../support/golden_harness.dart';

/// P2.5-FLUTTER-FRAMING — the same two questions, asked of every card-like widget that can be
/// constructed without a controller.
/// =================================================================================================
///
/// THIS FILE IS MEANT TO GROW. Three cards were repaired one at a time — the customer card, the
/// delivery-man card and the wallet transaction card — and each repair found the same two defects:
///
///   1. the card fills any BOUNDED height it is given, because a `Column` with no `mainAxisSize`
///      is `MainAxisSize.max`. It looks right in the app only because a scrolling list gives it an
///      unbounded main axis;
///   2. in LIGHT mode its fill is the page's fill. `LightThemeColor.cBackGround` and
///      `AppColor.cWhite` are both `0xffFFFFFF`, and so is `Colors.white`.
///
/// A STATIC PATTERN SEARCH IS NOT A SUBSTITUTE, which is the lesson the transaction card taught: a
/// census for "a `Column` with no `mainAxisSize` inside a decorated `Container`" found 64 sites and
/// flagged exactly ONE of that card's two Columns. Fixing the one it found changed nothing, because
/// a `Row` sizes its cross axis to its tallest child and the OTHER Column was the tall one. The
/// measurement is the test; the pattern is only where to point it.
///
/// So this file measures, and every widget that can be built from scalars is in it. A card that
/// needs a GetX controller is not here yet — that is the screen-harness problem, recorded in
/// `PHASE-2.5-SESSION-2026-11-09.md` §8.
///
/// TO ADD A CARD: give it a row in [cards]. Nothing else.
void main() {
  /// name -> how to build it. Values are invented; no real customer data goes in a fixture.
  final cards = <String, Widget Function(BuildContext)>{
    'coupon': (context) => productCouponWidget(
          context: context,
          code: 'EID25',
          name: 'خصم العيد',
          discount: '25%',
          date: '2026-12-31',
          couponType: 'percentage',
          status: 1,
        ),
    'top order': (context) => topOrderCardWidget(
          context: context,
          orderId: 'ORD-2043',
          date: '2026-11-06',
          maskedName: 'أمينة ح.',
          price: '150.00',
          primaryBadgeLabel: 1,
        ),
    // `settingCard` IS DELIBERATELY NOT HERE, AND THE REASON IS RECORDED RATHER THAN GUESSED.
    // Built with the app's own `DefaultImages.statisticIcn`, it throws a RenderFlex `hasSize`
    // assertion during `performLayout` in this harness. That is either a genuine layout fragility
    // in the card or a context this harness does not supply, and the two are not distinguishable
    // without reading it properly. Claiming it either way would be a guess, so it is a LEAD:
    // see PHASE-2.5-SESSION-2026-11-09.md. Adding it here once it is understood is one line.
  };

  Future<double> heightInBoundedBox(WidgetTester tester, Widget Function(BuildContext) build) async {
    await tester.pumpWidget(goldenHost(
      dark: false,
      direction: TextDirection.ltr,
      child: KeyedSubtree(key: const Key('ss-measured'), child: Builder(builder: build)),
    ));
    await tester.pumpAndSettle();

    return tester.getSize(find.byKey(const Key('ss-measured'))).height;
  }

  Future<double> heightInScrollingList(WidgetTester tester, Widget Function(BuildContext) build) async {
    await tester.pumpWidget(goldenHost(
      dark: false,
      direction: TextDirection.ltr,
      child: ListView(children: [
        KeyedSubtree(key: const Key('ss-measured'), child: Builder(builder: build)),
      ]),
    ));
    await tester.pumpAndSettle();

    return tester.getSize(find.byKey(const Key('ss-measured'))).height;
  }

  group('every card-like widget is content-height in any box', () {
    cards.forEach((name, build) {
      testWidgets('the $name card measures the same in a list and in a bounded box', (tester) async {
        pinGoldenSurface(tester);

        final list = await heightInScrollingList(tester, build);
        final bounded = await heightInBoundedBox(tester, build);

        expect(
          bounded,
          closeTo(list, 0.5),
          reason: 'the $name card is ${list.toStringAsFixed(1)}px in a scrolling list and '
              '${bounded.toStringAsFixed(1)}px in a bounded 800px box. A `Column` with no '
              '`mainAxisSize` is `MainAxisSize.max` and fills whatever bounded height arrives; the '
              'app only looks right because a list gives it an unbounded main axis. Check EVERY '
              'Column in the widget — the transaction card had two and only the second one was '
              'stretching.',
        );

        expect(
          bounded,
          lessThan(600),
          reason: 'the $name card took ${bounded.toStringAsFixed(1)} of the 800px surface',
        );
      });
    });

    testWidgets('premise: the surface really is 800px tall', (tester) async {
      /// Without this, `lessThan(600)` could pass because the viewport shrank.
      pinGoldenSurface(tester);

      await tester.pumpWidget(goldenHost(
        dark: false,
        direction: TextDirection.ltr,
        child: const SizedBox.expand(),
      ));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(Scaffold)).height, 800);
    });
  });

  group('the light palette has no surface distinction to inherit', () {
    test('the three light "card" colours are all the page colour', () {
      /// THE REASON THE CARDS NEED AN EDGE OF THEIR OWN, asserted once rather than restated in
      /// every card's test. `LightThemeColor.cBackGround` is the scaffold background
      /// (`theme_controller.dart` passes it to `scaffoldBackgroundColor`), and the three values a
      /// card reaches for in light mode are the same colour.
      expect(LightThemeColor.cBackGround.toARGB32(), 0xFFFFFFFF);
      expect(AppColor.cWhite.toARGB32(), 0xFFFFFFFF);
      expect(Colors.white.toARGB32(), 0xFFFFFFFF);
    });

    test('the dark card and page colours really do differ', () {
      /// So a dark card needs no outline — the opposite claim, asserted so that "make them
      /// consistent" has to argue with a measurement.
      expect(
        DarkThemeColor.cCardBackground.toARGB32(),
        isNot(DarkThemeColor.cBackGround.toARGB32()),
      );
    });
  });
}
