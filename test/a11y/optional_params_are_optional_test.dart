// P2.5-R-04 -- six shared buttons declare their label and icon OPTIONAL and then force-unwrap them.
//
// Found while measuring tap targets for P2.5-D-01: the harness omitted `iconData`, which the
// signature says is allowed, and the widget threw instead of building. Recorded then as P2.5-F-06
// and repaired now under the owner's decision of 2026-11-03.
//
// WHAT THE SIGNATURE PROMISES, in every one of the six:
//
//     final String? title;        final String? iconData;
//     CommonIconButton({ this.title, this.iconData, ... });
//
// and what the build method does with that promise: `title!` at :68, :130, :215, :271, :327, :409
// and `iconData!` at :126, :210, :333. A caller who takes the signature at its word gets a
// "Null check operator used on a null value" at build time -- not a lint, not a degraded render, a
// thrown exception that takes the screen down.
//
// EVERY EXISTING CALL SITE PASSES BOTH, which is why no merchant has met this. That is also what
// makes the repair safe: rendering an icon-less button as a label, and a label-less button as an
// icon, changes nothing for any caller that exists today. The alternative -- making the parameters
// required -- would be a breaking API change for a shared widget, and the owner's decision asks for
// backward-compatible repairs.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/common_button.dart';

Future<void> pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(home: Scaffold(body: Center(child: child))),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('a button built without an icon still builds', () {
    testWidgets('CommonIconButton', (tester) async {
      await pump(tester, CommonIconButton(title: 'Save', onPressed: () {}));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('SmallCommonIconButton', (tester) async {
      await pump(tester, SmallCommonIconButton(title: 'Edit', onPressed: () {}));
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('CommonIconBorderButton', (tester) async {
      await pump(tester, CommonIconBorderButton(title: 'Export', onPressed: () {}));
      expect(find.text('Export'), findsOneWidget);
    });
  });

  group('a button built without a title still builds', () {
    testWidgets('CommonButton', (tester) async {
      await pump(tester, CommonButton(onPressed: () {}));
      expect(tester.takeException(), isNull);
    });

    testWidgets('CommonBorderButton', (tester) async {
      await pump(tester, CommonBorderButton(onPressed: () {}));
      expect(tester.takeException(), isNull);
    });

    testWidgets('CommonSocialButton', (tester) async {
      await pump(tester, CommonSocialButton(onPressed: () {}));
      expect(tester.takeException(), isNull);
    });
  });

  // NEGATIVE CONTROL. The repair must not silently swallow a label that WAS passed, which is the
  // obvious way to make the tests above green while breaking every real screen.
  group('what IS passed is still rendered', () {
    testWidgets('the title survives', (tester) async {
      await pump(tester, CommonIconButton(title: 'Confirm order', onPressed: () {}));
      expect(find.text('Confirm order'), findsOneWidget);
    });

    testWidgets('the button is still tappable without an icon', (tester) async {
      var taps = 0;
      await pump(tester, CommonIconButton(title: 'Tap me', onPressed: () => taps++));
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(taps, 1, reason: 'the icon-less branch dropped the gesture handler');
    });

    // And the tap target P2.5-D-01 fixed is still 48dp when the icon is absent, because a
    // conditional that rebuilds the child tree is exactly where a height gets lost.
    testWidgets('the 48dp tap target survives an absent icon', (tester) async {
      await pump(tester, CommonIconButton(title: 'Sized', onPressed: () {}));
      final box = tester.getSize(find.byType(CommonIconButton));
      expect(box.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    });
  });
}
