import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/view/screen/customers/customers_details.dart';
import 'package:store_go_app/view/screen/setting_screen/store_setting_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-DETAIL — the store-settings hub and the customer detail screen.
/// =================================================================================================
///
/// Two of the surfaces a merchant reaches by pushing from a list, and the first captures of either.
///
/// **`StoreSettingScreen` is a hub, not a form.** It renders a grid of cards leading to the store's
/// language, information and design screens — three surfaces already captured elsewhere — so what
/// matters here is that the hub itself is translated, since every one of its labels is a key
/// (`store_settings`, `store_language_and_currencies`, `store_information`, `store_design`) and a
/// missing one renders as the raw identifier.
///
/// **`CustomerDetailsScreen` needs TWO controllers**, `CustomerController` and `OrderController`,
/// because it shows a customer beside that customer's orders. It also calls
/// `clearCustomerOrders()` synchronously in `initState` BEFORE its post-frame fetch, which is the
/// detail that makes the fixture matter: the list is emptied first, so a response that fails to
/// parse leaves an empty list that looks exactly like a customer with no orders.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// `/customer/orders` — the customer beside their orders, in the envelope
  /// `CustomerOrdersModel.fromJson` reads: a `customer` map, an `orders` list and a `pagination`
  /// map, all under `data`.
  Map<String, Object?> customerOrders() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'customer': <String, Object?>{
            'id': 4,
            'name': 'ليلى حداد',
            'email': 'layla@example.com',
            'mobile': '0991234567',
          },
          'orders': <Object?>[
            <String, Object?>{
              'id': 1042,
              'product_order_id': 'SS-1042',
              'order_date': '2026-11-08',
              'final_price': '126500',
              'currency_symbol': 'ل.س',
              'delivered_status': 0,
              'delivered_status_string': 'Pending',
              'payment_type': 'COD',
              'payment_status': 'pending',
            },
          ],
          'pagination': <String, Object?>{
            'total': 1,
            'per_page': 10,
            'current_page': 1,
            'last_page': 1,
          },
        },
      };

  for (final combination in kFourCombinations) {
    testWidgets('the store settings hub renders in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        // INSIDE A `Builder`. `StoreSettingScreen` is a StatelessWidget whose FIELD INITIALISER
        // calls `Get.put(StoreSettingController())`, and that controller's `onInit` reaches
        // `StoreChangeService.instance`. A field initialiser runs when the widget is
        // CONSTRUCTED, so building it eagerly in the test argument list runs it before
        // `pumpScreen` has registered that service, and the screen throws
        // `"StoreChangeService" not found`. Constructing it during build puts it back in order.
        Builder(builder: (_) => StoreSettingScreen()),
        api: api,
        combination: combination,
      );
      await pumpFrames(tester, frames: 12);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'the store settings hub threw in ${combination.name}');

      /// EVERY LABEL ON THIS SCREEN IS A KEY, so a missing translation renders the raw identifier
      /// — `store_language_and_currencies` instead of a heading. That is the failure this asserts
      /// against directly: the underscore form must NOT be on screen in either language.
      for (final key in <String>[
        'store_settings',
        'store_language_and_currencies',
        'store_information',
        'store_design',
      ]) {
        expect(find.textContaining(key), findsNothing,
            reason: 'the raw key "$key" is rendered on the store settings hub in '
                '${combination.name}, which means its translation is missing from the active map');
      }

      final context = tester.element(find.byType(StoreSettingScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'the store settings hub rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'the store settings hub rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-store-settings-hub', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the store settings hub capture is suspiciously small');
      }
    });

    testWidgets('customer detail renders the customer and their orders in ${combination.name}',
        (tester) async {
      final api = ApiStub()..on('customer/orders', customerOrders());
      late final CustomerController customers;

      await pumpScreen(
        tester,
        const CustomerDetailsScreen(customerId: '4'),
        api: api,
        combination: combination,
        register: () {
          customers = Get.put(CustomerController());
          Get.put(OrderController());
        },
      );

      await pumpUntil(
        tester,
        () => customers.customerProfile.value != null,
        reason: 'the customer never loaded. `clearCustomerOrders()` runs synchronously in '
            'initState before the fetch, so a response that fails to parse leaves an empty screen '
            'that looks exactly like a customer with no orders. Recorded calls: ${api.calls}',
      );
      await pumpFrames(tester, frames: 10);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'customer detail threw in ${combination.name}');
      expect(api.sawRequestFor('customer/orders'), isTrue,
          reason: 'the customer-orders endpoint was never called. Recorded: ${api.calls}');

      expect(find.textContaining('ليلى حداد'), findsWidgets,
          reason: 'the customer\'s name is not on their own detail screen');

      final context = tester.element(find.byType(CustomerDetailsScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'customer detail rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'customer detail rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-customer-detail', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the customer detail capture is suspiciously small');
      }
    });
  }

  testWidgets('premise: a customer with no orders is distinguishable from a failed load',
      (tester) async {
    /// The distinction `clearCustomerOrders()` makes dangerous. Both states show an empty order
    /// list, so the screen must still identify the CUSTOMER in the empty case — otherwise a
    /// merchant cannot tell "this customer has never ordered" from "this screen is broken".
    final empty = customerOrders();
    (empty['data']! as Map<String, Object?>)['orders'] = <Object?>[];

    final api = ApiStub()..on('customer/orders', empty);
    late final CustomerController customers;

    await pumpScreen(tester, const CustomerDetailsScreen(customerId: '4'), api: api, register: () {
      customers = Get.put(CustomerController());
      Get.put(OrderController());
    });

    await pumpUntil(tester, () => customers.customerProfile.value != null,
        reason: 'the customer profile did not load in the empty-orders case');
    await drainToasts(tester);

    expect(find.textContaining('ليلى حداد'), findsWidgets,
        reason: 'a customer with no orders shows nothing identifying them, so an empty list and a '
            'broken screen look the same');
    expect(tester.takeException(), isNull);
  });
}
