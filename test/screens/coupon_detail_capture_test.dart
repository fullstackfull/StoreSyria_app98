import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/view/screen/coupon_screen/coupon_detail_screen.dart';

import '../support/golden_harness.dart';
import '../support/nested_fixtures.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-COUPONDETAIL — the redemption history of one coupon.
/// =================================================================================================
///
/// **This screen is not the coupon's definition.** It lists the orders that used the code, which is
/// why `ViewUsedCouponModel` reads `order_id`, `product_order_id`, `amount` and `date_used` and
/// nothing about the discount rule. A fixture built from the coupon's own fields parses to an empty
/// list and renders a screen indistinguishable from a coupon nobody has used — which is exactly how
/// the first version of this file's fixture was wrong, and exactly the reading the empty-state case
/// below exists to separate.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  for (final combination in kFourCombinations) {
    testWidgets('coupon detail lists the orders that used the code in ${combination.name}',
        (tester) async {
      final api = ApiStub()..on('view-used-coupon', usedCouponResponse());
      late final NewCouponController coupons;

      await pumpScreen(
        tester,
        const CouponDetailScreen(couponId: 5),
        api: api,
        combination: combination,
        register: () {
          coupons = Get.put(NewCouponController());
        },
      );

      await pumpUntil(
        tester,
        () => coupons.viewCouponsList.isNotEmpty,
        reason: 'the redemption list never populated, so every assertion below would be made '
            'against an empty screen. Recorded requests: ${api.calls}',
      );
      await pumpFrames(tester, frames: 10);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'coupon detail threw in ${combination.name}');
      expect(api.sawRequestFor('view-used-coupon'), isTrue,
          reason: 'the used-coupon endpoint was never called. Recorded: ${api.calls}');

      // An order number from the fixture, so the list really parsed rather than rendering
      // three empty rows.
      expect(find.textContaining('SY-104'), findsWidgets,
          reason: 'no redemption row carries its order number');

      final context = tester.element(find.byType(CouponDetailScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'coupon detail rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'coupon detail rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-coupon-detail', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the coupon detail capture is suspiciously small');
      }
    });
  }

  /// A coupon nobody has used must not look like a coupon whose history failed to load.
  ///
  /// Both render an empty list, so the only thing that separates them for a merchant is whether
  /// the screen SAYS so. This case asserts the screen survives the empty payload; it is a premise
  /// test, not a capture.
  testWidgets('a coupon with no redemptions renders without throwing', (tester) async {
    final api = ApiStub()..on('view-used-coupon', usedCouponEmptyResponse());

    await pumpScreen(
      tester,
      const CouponDetailScreen(couponId: 5),
      api: api,
      register: () {
        Get.put(NewCouponController());
      },
    );

    await pumpFrames(tester, frames: 14);
    await drainToasts(tester);

    expect(tester.takeException(), isNull,
        reason: 'an unredeemed coupon threw rather than rendering an empty state');
  });
}
