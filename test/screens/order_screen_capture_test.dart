import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/view/screen/order_screen/order_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-ORDERS — the orders list, driven with real orders in all four combinations.
/// =================================================================================================
///
/// The screen this whole session started from. The ORDERS audit that opened Phase 2.5 was done
/// against the **web** merchant list; this is the Flutter half of the same surface, and until now
/// it had no captures at all because no Flutter screen could be pumped.
///
/// WHAT IS DIFFERENT ABOUT THIS SCREEN, all of it read out of the code rather than assumed:
///
/// 1. **It needs TWO controllers, and only one of them itself.** `_OrderScreenState` holds
///    `Get.find<OrderController>()` in a field initialiser — so the test must register that one —
///    while the delivery-boy controller is handled by the screen:
///    `Get.isRegistered<DeliveryBoyController>() ? Get.find(...) : Get.put(...)`
///    (`order_screen.dart:40-42`). Registering it here as well would be harmless but misleading.
/// 2. **The list is APPENDED to across pages, and de-duplicated against what it already holds.**
///    `getOrderData` builds `existingIds` from the list ONCE, BEFORE the loop
///    (`order_controller.dart:471-475`), and then appends every new item whose id is not in that
///    set. Read carelessly that looks like "no duplicates ever"; it is not. Within a single
///    response two rows sharing an id BOTH enter the list — measured, and the first version of
///    the test below asserted the opposite and failed for that reason. What the guard really
///    protects is the case that actually happens: an order placed between page 1 and page 2
///    shifts the server's offset so page 2 repeats a row from page 1. The last test here drives
///    exactly that.
/// 3. **Page 1 with no filters is CACHED to GetStorage** (`order_controller.dart:498`), under the
///    `cache_*` prefix `resetScreenHarness` clears. Without that clearing a later test would
///    render this test's orders; that mechanism has its own regression test in
///    `screen_harness_test.dart`.
/// 4. **`OrderModel.fromJson` is called with NO status check** (`order_controller.dart:467`), so —
///    unlike tax and shipping — the envelope's `status` is not what decides whether rows appear.
///    What decides it is the shape: `data.data` must be a List of maps. The premise assertion
///    below is what distinguishes "the fixture was wrong" from "the screen stopped rendering".
///
/// The card itself shows `productOrderId`, `userName` and `finalPrice` with the order's own
/// `currencySymbol` (`order_screen.dart:411-425`) — note that this screen gets its currency from
/// the ORDER, which is why it does not have the gap recorded for the tax list in
/// `docs/design/TAX-CURRENCY-SYMBOL.md`.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  Map<String, Object?> order({
    required int id,
    required String ref,
    required String customer,
    required String total,
    required int status,
    required String statusText,
  }) =>
      <String, Object?>{
        'id': id,
        'product_order_id': ref,
        'order_id_string': ref,
        'user_name': customer,
        'order_date': '2026-11-08',
        'created_at': '2026-11-08 09:12:00',
        'final_price': total,
        'product_price': total,
        'delivery_price': '0',
        'tax_price': '0',
        'coupon_price': '0',
        'return_price': '0',
        'currency_symbol': 'ل.س',
        'payment_type': 'COD',
        'payment_status': 'pending',
        'delivered_status': status,
        'delivered_status_string': statusText,
        'is_guest': 0,
        'store_id': 1,
        'user_id': 4,
      };

  Map<String, Object?> orderPage() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'current_page': 1,
          'last_page': 1,
          'per_page': 10,
          'total': 2,
          'data': <Object?>[
            order(
              id: 1041,
              ref: 'SS-1041',
              customer: 'ليلى حداد',
              total: '85000',
              // 6 IS "Shipped" -- the numbering is NOT free, and it agrees with the server's
              // `Order::getDeliveredStatusStringAttribute()`: 0 Pending, 1 Delivered, 2 Cancel,
              // 3 Return, 4 Confirmed, 5 Picked Up, 6 Shipped. The card reads this INT, not
              // `delivered_status_string`, so the first version of this fixture -- 2 with the
              // string 'Shipped' -- captured an order badged "Cancelled". The card was right and
              // the fixture was wrong; `test/widgets/order_status_label_test.dart` pins the map.
              status: 6,
              statusText: 'Shipped',
            ),
            order(
              id: 1042,
              ref: 'SS-1042',
              customer: 'Marwan Haddad',
              total: '126500',
              status: 0,
              statusText: 'Pending',
            ),
          ],
        },
      };

  /// `topOrders` answers EMPTY on purpose. The list header counts a top-orders slot into
  /// `itemCount` when one exists (`order_screen.dart:364`), and the point of this tranche is the
  /// ordinary list; a populated top-orders strip is a different surface with its own card.
  ApiStub stub() => ApiStub()
    ..on('toporder', <String, Object?>{'status': 1, 'data': <Object?>[]})
    ..on('orderlist', orderPage());

  for (final combination in kFourCombinations) {
    testWidgets('the orders list renders its orders in ${combination.name}', (tester) async {
      final api = stub();
      late final OrderController controller;

      await pumpScreen(
        tester,
        const OrderScreen(),
        api: api,
        combination: combination,
        register: () {
          controller = Get.put(OrderController());
        },
      );

      await pumpUntil(
        tester,
        () => controller.orderList.length >= 2,
        reason: 'the orders never loaded. The controller de-duplicates by id, so a fixture whose '
            'two rows shared an id would stop here too. Recorded calls: ${api.calls}',
      );

      await pumpUntil(
        tester,
        () => find.textContaining('SS-1042').evaluate().isNotEmpty,
        reason: 'the second order is in the controller but not on screen, so the list rendered '
            'fewer rows than it holds',
      );

      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'the orders list threw while rendering in ${combination.name}');

      expect(api.sawRequestFor('orderlist'), isTrue,
          reason: 'the screen never called orderlist. Recorded: ${api.calls}');

      /// The customer name and the money, not just the reference. An order row that shows its id
      /// and nothing else is the failure mode the web list had (P2.5-ORD-5/10): findable but
      /// unreadable.
      expect(find.textContaining('Marwan Haddad'), findsWidgets,
          reason: 'the order rendered without its customer name');
      expect(find.textContaining('126500'), findsWidgets,
          reason: 'the order rendered without its total');

      final context = tester.element(find.byType(OrderScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'the orders list rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'the orders list rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(
        tester,
        captureName('flutter-orders-list', combination),
      );
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the orders capture is suspiciously small: a blank render');
      }
    });
  }

  testWidgets('premise: an empty page renders the empty state, not a row', (tester) async {
    /// The control for every assertion above. Without it, "SS-1042 is on screen" could be true of
    /// a screen that renders its fixture regardless of the response.
    final api = ApiStub()
      ..on('toporder', <String, Object?>{'status': 1, 'data': <Object?>[]})
      ..on('orderlist', <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'current_page': 1,
          'last_page': 1,
          'per_page': 10,
          'total': 0,
          'data': <Object?>[],
        },
      });

    await pumpScreen(tester, const OrderScreen(), api: api, register: () {
      Get.put(OrderController());
    });

    await pumpFrames(tester);
    await drainToasts(tester);

    expect(find.textContaining('SS-1042'), findsNothing,
        reason: 'an order appears with no orders in the response, so the populated assertions '
            'prove nothing');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a repeated order on the next page is not added twice', (tester) async {
    /// Note 2 in this file's header, made executable, and driving the case the guard exists for:
    /// a shifting dataset makes page 2 repeat a row from page 1.
    ///
    /// `getOrderData(2)` refuses unless `isScroll` is true, and `isScroll` is set from
    /// `page < lastPage` on the previous response — so page 1 must declare `last_page: 2` or the
    /// second fetch never happens and this test passes without testing anything. The call count
    /// is asserted for that reason.
    Map<String, Object?> page({required List<Object?> rows, required int lastPage}) =>
        <String, Object?>{
          'status': 1,
          'data': <String, Object?>{
            'current_page': 1,
            'last_page': lastPage,
            'per_page': 2,
            'total': 3,
            'data': rows,
          },
        };

    final api = ApiStub()
      ..on('toporder', <String, Object?>{'status': 1, 'data': <Object?>[]})
      // Rules match in the order they were added and also against the full URL, so the narrower
      // page=2 rule has to come first.
      ..on(
        'page=2',
        page(lastPage: 2, rows: <Object?>[
          // THE REPEAT: id 1042 was already on page 1.
          order(
            id: 1042,
            ref: 'SS-1042',
            customer: 'Marwan Haddad',
            total: '126500',
            status: 1,
            statusText: 'Pending',
          ),
          order(
            id: 1043,
            ref: 'SS-1043',
            customer: 'Nour Khalil',
            total: '40000',
            status: 1,
            statusText: 'Pending',
          ),
        ]),
      )
      ..on(
        'orderlist',
        page(lastPage: 2, rows: <Object?>[
          order(
            id: 1041,
            ref: 'SS-1041',
            customer: 'Layla Haddad',
            total: '85000',
            status: 2,
            statusText: 'Shipped',
          ),
          order(
            id: 1042,
            ref: 'SS-1042',
            customer: 'Marwan Haddad',
            total: '126500',
            status: 1,
            statusText: 'Pending',
          ),
        ]),
      );

    late final OrderController controller;

    await pumpScreen(tester, const OrderScreen(), api: api, register: () {
      controller = Get.put(OrderController());
    });

    await pumpUntil(tester, () => controller.orderList.length >= 2,
        reason: 'page 1 never loaded');

    expect(controller.isScroll.value, isTrue,
        reason: 'premise: page 1 did not report a second page, so the page-2 fetch below would be '
            'refused outright and this test would prove nothing');

    /// INSIDE `runWithApi`. `pumpScreen` installs the stub through `http.runWithClient`, which is
    /// a ZONE — it is in force only while that call runs. Driving the second page without this
    /// wrapper sent the request to the real client: it never reached `api.calls`, and the
    /// `pumpUntil` below failed saying the page was never requested, which reads as a screen that
    /// stopped fetching rather than a test that lost its stub. Measured here first.
    await runWithApi(api, () async {
      await controller.getOrderData(2);
      await pumpUntil(tester, () => api.sawRequestFor('page=2'),
          reason: 'the second page was never requested; recorded calls: ${api.calls}');
      await pumpFrames(tester);
      await drainToasts(tester);
    });

    expect(controller.orderList.length, 3,
        reason: 'page 2 repeated order 1042 and the list now holds '
            '${controller.orderList.length} rows instead of 3 — the id guard stopped working, and '
            'a merchant scrolling a busy list sees the same order twice. '
            'Ids: ${controller.orderList.map((o) => o.id).toList()}');

    expect(controller.orderList.where((o) => o.id == 1042).length, 1,
        reason: 'order 1042 is in the list more than once');
  });
}
