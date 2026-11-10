import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/view/screen/order_screen/order_detail_screen.dart';

import '../support/golden_harness.dart';
import '../support/nested_fixtures.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-ORDERDETAIL — the order a merchant opens from the list.
/// =================================================================================================
///
/// The deepest payload in the admin app. `OrderDetailModel.fromJson` reads **sixty-four** distinct
/// keys across billing and delivery addresses, a product-line array, coupon info, a tax block and
/// eleven money fields — which is why the fixture lives in `test/support/nested_fixtures.dart`
/// rather than inline here. Inlined, the one field a given test is about disappears into the
/// payload.
///
/// **The screen needs two controllers and only declares one.** `OrderController` is found, and
/// `DeliveryBoyController` is found-or-put by the screen itself (`order_detail_screen.dart:37-40`),
/// so a test that registers only the first still works — but a test that registers neither gets a
/// `"OrderController" not found` that reads like a harness bug.
///
/// **The money fields are deliberately all different.** `price`, `orignal_price` and
/// `per_product_discount_price` are three numbers in the fixture, because a fixture where they are
/// equal cannot show whether the screen prints the right one — and printing the wrong one is a
/// defect class this app has already shipped once (P2.5-FLUTTER-PRICE, where the card showed the
/// discount price as if it were the price).
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  for (final combination in kFourCombinations) {
    testWidgets('order detail renders the order, its lines and its totals in ${combination.name}',
        (tester) async {
      final api = ApiStub()..on('vieworder', orderDetailResponse());
      late final OrderController orders;

      await pumpScreen(
        tester,
        const OrderDetailScreen(orderId: '1042'),
        api: api,
        combination: combination,
        register: () {
          orders = Get.put(OrderController());
        },
      );

      await pumpUntil(
        tester,
        () => orders.orderDetail != null,
        reason: 'the order never loaded, so everything below would be asserted against an empty '
            'screen. Recorded requests: ${api.calls}',
      );
      await pumpFrames(tester, frames: 10);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'order detail threw in ${combination.name}');
      expect(api.sawRequestFor('vieworder'), isTrue,
          reason: 'the order-detail endpoint was never called. Recorded: ${api.calls}');

      // The order's own identity must be on its own screen. Without this the test passes against
      // a screen that loaded SOME order, which is the failure a capture cannot show.
      expect(find.textContaining('SY-10427'), findsWidgets,
          reason: 'the order number is not on the order detail screen');

      // A product line, so the array really parsed rather than silently becoming empty.
      expect(find.textContaining('Aleppo Laurel Soap'), findsWidgets,
          reason: 'the order line did not render, so the product array did not parse');

      final context = tester.element(find.byType(OrderDetailScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'order detail rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'order detail rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-order-detail', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the order detail capture is suspiciously small');
      }
    });
  }

  /// The shape the screen must survive rather than crash on.
  ///
  /// `order_detail_model.dart:130` records that `order_detail_screen.dart:808` force-unwraps a
  /// field an empty order leaves absent. A suite that only ever drives the happy path never
  /// reaches that line, so this case exists to reach it — and it is a PREMISE test, not a capture:
  /// what matters is that nothing throws.
  testWidgets('an order with no lines renders without throwing', (tester) async {
    final api = ApiStub()..on('vieworder', orderDetailEmptyResponse());

    await pumpScreen(
      tester,
      const OrderDetailScreen(orderId: '1042'),
      api: api,
      register: () {
        Get.put(OrderController());
      },
    );

    await pumpFrames(tester, frames: 14);
    await drainToasts(tester);

    expect(tester.takeException(), isNull,
        reason: 'an order with an empty product array threw. That is the force-unwrap recorded at '
            'order_detail_model.dart:130, and a merchant with a cancelled or fully-returned order '
            'reaches it.');
  });
}
