// P2.5-D-01 -- the minimum tap target of every shared button in the merchant app.
//
// WHAT IS MEASURED AND WHY IT IS A WIDGET TEST RATHER THAN A GREP. A grep over
// `common_button.dart` reports the literals 42, 43 and 35. What a merchant's thumb
// meets is the RENDERED box after `flutter_screenutil` has scaled it against the
// 360x800 design size this app declares, so the only honest number comes from
// pumping the widget and reading `tester.getSize`. These tests do that.
//
// THE THRESHOLD, and which one applies. Material's minimum interactive dimension
// is 48dp (`kMinInteractiveDimension`, which this file asserts against rather
// than against a copied 48.0, so a framework change cannot leave the number
// stale). Apple's HIG asks 44pt. WCAG 2.2 AA 2.5.8 requires 24x24 CSS px as a
// floor and names 44x44 as the enhanced level. 48dp satisfies all three.
//
// WHAT WAS FOUND, measured on Flutter 3.47.7 before the fix:
//
//   CommonButton             42.0  -- below Material 48 and below Apple 44
//   CommonIconButton         43.0  -- below Material 48 and below Apple 44
//   SmallCommonIconButton    35.0  -- below all three thresholds
//   AppButton                48.0  -- already correct, and the proof the
//                                     convention exists in this codebase
//
// So this is an internal INCONSISTENCY as much as an accessibility gap: the
// newer shared button already uses 48 and the older family never caught up.
// `SmallCommonIconButton` is deliberately small, so it keeps its painted height
// and gains the tap target through a wrapper -- the "extend the hit area beyond
// the visual bounds" rule, rather than making a small control big.
//
// AND WRITING THIS TEST FOUND A SECOND DEFECT, which is why `iconData` is passed
// below even though the parameter is declared optional. `CommonIconButton`,
// `SmallCommonIconButton` and `CommonIconBorderButton` all declare
// `final String? iconData` and then do `iconData!` in build. The signature says
// the argument is optional; the widget throws `Null check operator used on a
// null value` when it is omitted. The analyzer is silent because the type is
// nullable, so the first report is a runtime crash in front of a merchant.
// Recorded as a finding; not fixed here, because changing it to `required` is a
// signature change rather than accessible presentation.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/widget/common_button.dart';

/// Pumps [child] inside the same ScreenUtil design size the app declares in
/// store_go.dart, so a `.h`/`.w` value resolves exactly as it does at runtime.
Future<void> pumpInApp(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CommonButton meets the Material minimum tap target', (tester) async {
    await pumpInApp(tester, CommonButton(title: 'Save', onPressed: () {}));

    final size = tester.getSize(find.byType(CommonButton));
    expect(
      size.height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
      reason: 'CommonButton renders ${size.height}dp tall. Material requires '
          '$kMinInteractiveDimension; Apple HIG asks 44. It is the primary action '
          'on most merchant forms.',
    );
  });

  testWidgets('CommonIconButton meets the Material minimum tap target', (tester) async {
    await pumpInApp(
      tester,
      CommonIconButton(
        title: 'Filter',
        iconData: DefaultImages.closeIcn,
        onPressed: () {},
      ),
    );

    final size = tester.getSize(find.byType(CommonIconButton));
    expect(
      size.height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
      reason: 'CommonIconButton renders ${size.height}dp tall, below '
          '$kMinInteractiveDimension.',
    );
  });

  testWidgets('SmallCommonIconButton keeps its small look and a full tap target',
      (tester) async {
    await pumpInApp(
      tester,
      SmallCommonIconButton(
        title: 'Edit',
        iconData: DefaultImages.closeIcn,
        onPressed: () {},
      ),
    );

    final size = tester.getSize(find.byType(SmallCommonIconButton));
    expect(
      size.height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
      reason: 'A control may LOOK small; its tap target may not BE small. '
          'SmallCommonIconButton renders ${size.height}dp. The fix is to extend '
          'the hit area past the painted bounds, not to enlarge the painted box.',
    );
  });

  testWidgets('SmallCommonIconButton did not grow visually to earn its tap target',
      (tester) async {
    await pumpInApp(
      tester,
      SmallCommonIconButton(
        title: 'Edit',
        iconData: DefaultImages.closeIcn,
        onPressed: () {},
      ),
    );

    // The OUTER box is the tap target; the first painted Container inside it is what a merchant
    // sees. Asserting only the outer size would let a future "fix" satisfy the previous test by
    // simply making the control bigger -- which is the thing this one exists to forbid.
    final painted = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(SmallCommonIconButton),
        matching: find.byType(Container),
      ),
    ).first;

    expect(
      painted.constraints?.maxHeight ?? (painted.constraints?.minHeight ?? -1),
      35.0,
      reason: 'The painted box must stay 35dp. The tap target is extended past the visual '
          'bounds; the visual decision is not overturned.',
    );

    final outer = tester.getSize(find.byType(SmallCommonIconButton));
    expect(outer.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    expect(outer.height, lessThan(60),
        reason: 'The hit area should reach the minimum, not sprawl past it.');
  });

  testWidgets('the extended margin actually responds to a tap', (tester) async {
    // ADDED AFTER A BITE TEST EMBARRASSED THE ONES ABOVE. Removing
    // `HitTestBehavior.opaque` from the widget left every other test in this file passing:
    // the SizedBox still measures 48, so a size assertion cannot tell a real hit area from a
    // transparent one. That is the exact shape of defect this repository keeps finding in its
    // own controls -- a check that measures the geometry of a fix rather than its effect.
    //
    // So this taps the MARGIN: the strip inside the 48dp target but outside the 35dp painted
    // box. Without `HitTestBehavior.opaque` the gesture detector does not claim that strip and
    // the tap falls through.
    var taps = 0;
    await pumpInApp(
      tester,
      SmallCommonIconButton(
        title: 'Edit',
        iconData: DefaultImages.closeIcn,
        onPressed: () => taps++,
      ),
    );

    final box = tester.getRect(find.byType(SmallCommonIconButton));
    expect(box.height, greaterThanOrEqualTo(kMinInteractiveDimension));

    // (48 - 35) / 2 = 6.5dp of margin at each end; 3dp in is comfortably inside it and
    // comfortably outside the painted child.
    await tester.tapAt(Offset(box.center.dx, box.top + 3));
    await tester.pump();

    expect(taps, 1,
        reason: 'A tap inside the extended target but outside the painted box did not fire. '
            'The SizedBox is the right size and the gesture does not claim it -- check that '
            'HitTestBehavior.opaque is still on the GestureDetector.');
  });

  // THE PREMISE. If kMinInteractiveDimension ever stopped being 48 the three
  // assertions above would still pass while measuring nothing meaningful, so the
  // threshold itself is pinned.
  test('the Material minimum interactive dimension is still 48dp', () {
    expect(kMinInteractiveDimension, 48.0,
        reason: 'The framework constant moved. Re-read the Material and Apple '
            'guidance and re-measure before adjusting anything above.');
  });
}
