import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/customer_widget.dart';
import 'package:store_go_app/view/new_widgets/delivery_boy_widget.dart';

import '../support/golden_harness.dart';
import '../support/sample_cards.dart';

/// P2.5-FLUTTER-FRAMING — the two list cards expand to fill any bounded height they are given.
/// =================================================================================================
///
/// WHAT WAS RECORDED, AND WHY IT WAS ONLY HALF THE CAUSE.
///
/// `docs/design/GOLDEN-BASELINE-FRAMING.md` measured the eight golden candidates and found the card
/// filling the whole 360x800 surface: 98.2% / 98.3% of each image was the card's own fill, the
/// scaffold background was absent, and a row-by-row scan found exactly one non-background row in
/// the whole image — `y = 799`, the rounded corner at the very bottom. It attributed that to
/// `goldenHost()`'s `Scaffold(body: child)`, which gives its body TIGHT constraints, and proposed
/// one line: wrap the body in `Align(alignment: AlignmentDirectional.topStart)`.
///
/// THAT FIX WAS APPLIED AND THE BASELINES REGENERATED, AND THE MEASUREMENT DID NOT MOVE — still
/// 98.3% `Colors.white` in light, still 98.2% `cCardBackground` in dark, still one differing row at
/// `y = 799`. The harness was not the whole cause.
///
/// THE REST OF IT IS IN THE WIDGETS. Both cards are a `Container` with a width and no height,
/// wrapping a `Column` with no `mainAxisSize` — and a `Column` defaults to `MainAxisSize.max`, which
/// means "be as tall as the incoming maxHeight". So loosening the constraints was not enough: given
/// a loose 800px box the Column still chose 800. `Align` was necessary and not sufficient.
///
/// WHY THE APP LOOKS RIGHT ANYWAY, and why that is not a reason to leave it. Both cards are rendered
/// inside a scrolling list (`customer_screen.dart:282-287`), where the main axis is UNBOUNDED, so
/// `MainAxisSize.max` has nothing to expand into and the card is content-height by accident of its
/// surroundings. Put either card in any bounded box — a `SizedBox`, a `Column` on a fixed-height
/// sheet, a grid cell, a golden harness — and it stretches. The tests below pin both contexts, so
/// the property holds because the widget has it and not because its parent happens to be a list.
///
/// WHAT THIS BUYS THE GOLDENS. With the card at its content height the scaffold background becomes
/// visible and therefore tested, a height regression becomes a visible diff, and the comparison's
/// pixels are mostly the widget under review instead of 98% flat fill.
void main() {
  /// The height the card takes when the box around it is BOUNDED — a golden harness, a sheet, a
  /// grid cell. This is the number the defect is about.
  Future<double> heightInBoundedBox(
    WidgetTester tester,
    Widget Function(BuildContext) build,
  ) async {
    await tester.pumpWidget(goldenHost(
      dark: false,
      direction: TextDirection.ltr,
      child: Builder(builder: build),
    ));
    await tester.pumpAndSettle();

    return tester.getSize(find.byType(Container).first).height;
  }

  /// The height it takes in the context the app really uses: a scrolling list, main axis unbounded.
  Future<double> heightInScrollingList(
    WidgetTester tester,
    Widget Function(BuildContext) build,
  ) async {
    await tester.pumpWidget(goldenHost(
      dark: false,
      direction: TextDirection.ltr,
      child: ListView(children: [Builder(builder: build)]),
    ));
    await tester.pumpAndSettle();

    return tester.getSize(find.byType(Container).first).height;
  }

  group('the list cards are content-height in any box', () {
    testWidgets('the customer card does not fill a bounded 800px surface', (tester) async {
      pinGoldenSurface(tester);

      final bounded = await heightInBoundedBox(
        tester,
        (context) => customerWidget(context: context, customer: sampleCustomer()),
      );

      expect(
        bounded,
        lessThan(400),
        reason: 'the customer card took ${bounded.toStringAsFixed(1)} of the 800px surface. '
            'A `Column` with no `mainAxisSize` is `MainAxisSize.max`, so it expands into whatever '
            'bounded height it is given — which is what made 98% of every golden baseline one flat '
            'colour and a height regression invisible.',
      );
    });

    testWidgets('the delivery-man card does not fill a bounded 800px surface', (tester) async {
      pinGoldenSurface(tester);

      final bounded = await heightInBoundedBox(
        tester,
        (context) => deliveryBoyWidget(context: context, deliveryBoy: sampleDeliveryBoy()),
      );

      expect(
        bounded,
        lessThan(400),
        reason: 'the delivery-man card took ${bounded.toStringAsFixed(1)} of the 800px surface',
      );
    });

    testWidgets('the customer card measures the same in a list and in a bounded box', (tester) async {
      /// THE CONTROL, and the assertion that says the repair changed nothing a merchant sees. In
      /// the real screen the card already rendered at its content height, because a scrolling list
      /// gives it an unbounded main axis. If the two numbers agree, the widget's own height is now
      /// the same one the app has always drawn — the fix removed a dependence on the parent, it did
      /// not resize the card.
      pinGoldenSurface(tester);

      final list = await heightInScrollingList(
        tester,
        (context) => customerWidget(context: context, customer: sampleCustomer()),
      );

      final bounded = await heightInBoundedBox(
        tester,
        (context) => customerWidget(context: context, customer: sampleCustomer()),
      );

      expect(
        bounded,
        closeTo(list, 0.5),
        reason: 'in a scrolling list the card is ${list.toStringAsFixed(1)} tall and in a bounded '
            'box ${bounded.toStringAsFixed(1)}. They must agree: the height the app draws is the '
            'height everything else should measure.',
      );
    });

    testWidgets('the delivery-man card measures the same in a list and in a bounded box', (tester) async {
      pinGoldenSurface(tester);

      final list = await heightInScrollingList(
        tester,
        (context) => deliveryBoyWidget(context: context, deliveryBoy: sampleDeliveryBoy()),
      );

      final bounded = await heightInBoundedBox(
        tester,
        (context) => deliveryBoyWidget(context: context, deliveryBoy: sampleDeliveryBoy()),
      );

      expect(bounded, closeTo(list, 0.5));
    });

    testWidgets('the light card has an edge, because its fill is the page\'s fill', (tester) async {
      /// THE DEFECT THE FRAMING REPAIR UNCOVERED. `LightThemeColor.cBackGround` is `0xffFFFFFF`
      /// (colors.dart:72) and the card's light fill is `Colors.white`, so in light mode the card
      /// and the page are the SAME COLOUR — the only separation was a shadow at alpha .035, which
      /// measured 1.08:1 off the capture. It could not be seen while the card covered the whole
      /// page; it appeared the moment the card became content-height.
      ///
      /// `docs/design/GOLDEN-BASELINE-FRAMING.md` made this reading first and then retracted it.
      /// The retraction was right about DARK (`cCardBackground` #18263F really does differ from
      /// `cBackGround` #0F1A2E, at 1.15:1) and wrong about LIGHT.
      pinGoldenSurface(tester);

      await tester.pumpWidget(goldenHost(
        dark: false,
        direction: TextDirection.ltr,
        child: Builder(
          builder: (context) => customerWidget(context: context, customer: sampleCustomer()),
        ),
      ));
      await tester.pumpAndSettle();

      final decoration = tester.widget<Container>(find.byType(Container).first).decoration;

      expect(decoration, isA<BoxDecoration>());

      final box = decoration! as BoxDecoration;

      expect(
        box.color,
        LightThemeColor.cBackGround,
        reason: 'premise: the light card fill really is the same colour as the page, which is why '
            'it needs an edge of its own',
      );
      expect(
        box.border,
        isNotNull,
        reason: 'the light card has no border, so a white card sits on a white page with nothing '
            'but a 1.08:1 shadow between them',
      );
      expect(
        (box.border! as Border).top.color,
        LightThemeColor.cBorder,
        reason: 'the edge must come from the app\'s own token, not a new literal',
      );
    });

    testWidgets('the dark card keeps its surface difference and gets no outline', (tester) async {
      /// In dark the two fills already differ, so an outline there would fight a surface that is
      /// reading. Asserted so a later "make them consistent" change has to argue with a test.
      pinGoldenSurface(tester);

      await tester.pumpWidget(goldenHost(
        dark: true,
        direction: TextDirection.ltr,
        child: Builder(
          builder: (context) => customerWidget(context: context, customer: sampleCustomer()),
        ),
      ));
      await tester.pumpAndSettle();

      final box = tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;

      expect(box.border, isNull, reason: 'the dark card should not be outlined');
      expect(
        box.color,
        isNot(DarkThemeColor.cBackGround),
        reason: 'the dark card fill must differ from the page, or it needs an edge like the light '
            'one',
      );
    });

    testWidgets('premise: the surface really is 800px tall, so `lessThan(400)` means something',
        (tester) async {
      /// Without this, a harness change that shrank the viewport would make the assertions above
      /// pass for a reason that has nothing to do with the cards.
      pinGoldenSurface(tester);

      await tester.pumpWidget(goldenHost(
        dark: false,
        direction: TextDirection.ltr,
        child: const SizedBox.expand(),
      ));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(Scaffold)).height, 800);
      expect(tester.getSize(find.byType(Scaffold)).width, 360);
    });
  });
}
