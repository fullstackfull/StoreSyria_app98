import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/core/controller/delivery_boy/delivery_boy_controller.dart';
import 'package:store_go_app/view/screen/customers/customer_screen.dart';
import 'package:store_go_app/view/screen/delivery_boys/delivery_boy_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-COVERAGE — two Flutter surfaces rendered WITH DATA, in all four combinations.
/// =================================================================================================
///
/// `screen_mount_matrix_test.dart` proves five screens can be driven, but it stubs EMPTY pages on
/// purpose: a populated fixture has to match each model's own field names, and this project has
/// twice frozen a baseline whose fixture used the wrong key (`email` nested inside `customer_info`
/// instead of at the root; `mobile` instead of `contact` on the delivery man). An empty page
/// exercises the parse, the loading-to-loaded transition and the empty state without inventing a
/// shape that might be wrong.
///
/// **BUT AN EMPTY LIST IS NOT A VERIFIED LIST SCREEN.** A reviewer looking only at "No customers
/// found" has not seen the screen, and the Phase 2.5 matrix's `REDESIGNED AND VERIFIED` means the
/// running application was driven and captured. So these two — the two whose model shapes are
/// already established in this repository's own tests — are rendered with rows in them.
///
/// EACH FIXTURE'S SHAPE IS ASSERTED, NOT ASSUMED. Every case first checks that the controller's
/// list actually filled from the stub. A fixture with a wrong key parses to an empty list and
/// renders the empty state, which looks exactly like a screen that works — the same false reading
/// the two earlier baselines froze.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// Three customers, in the envelope `CustomerModel.fromJson` reads.
  ///
  /// `email` and `state_name` sit at the ROOT, not inside `customer_info` — `CustomerInfo` carries
  /// only name and mobile, and the API puts both of these beside that object. The first version of
  /// this project's golden fixture nested `email`, so it was never read and four baselines froze a
  /// literal `--` where the address belongs.
  Map<String, Object?> customerPage() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'customers': <Object?>[
            <String, Object?>{
              'id': 1,
              'customer_info': <String, Object?>{'name': 'أمينة حداد', 'mobile': '0911222333'},
              'email': 'amina@example.test',
              'state_name': 'دمشق',
              'status': 1,
            },
            <String, Object?>{
              'id': 2,
              'customer_info': <String, Object?>{'name': 'عمر خليل', 'mobile': '0922333444'},
              'email': 'omar@example.test',
              'state_name': 'حلب',
              'status': 1,
            },
            <String, Object?>{
              'id': 3,
              'customer_info': <String, Object?>{'name': 'نور صالح', 'mobile': '0933444555'},
              'email': 'nour@example.test',
              'state_name': 'اللاذقية',
              'status': 0,
            },
          ],
          'pagination': <String, Object?>{'last_page': 1},
        },
      };

  /// Three delivery men. `DeliveryBoyModel.fromJson` reads `data` as a LIST directly — not the
  /// paginator envelope the customer endpoint uses — and each row's phone is `contact`, NOT
  /// `mobile`. Passing `mobile` is the mistake that froze a blank dash into four baselines.
  /// NOTE THE `status` TYPE. `DeliveryBoyModel.fromJson` reads it as `json['status']?.toString()`,
  /// but the CONTROLLER gates on the raw value: `data['status'] == 'success' || data['status'] == 1`
  /// (`delivery_boy_controller.dart:71`). A fixture carrying the string `'1'` matches neither, so
  /// the list silently stays empty and the screen renders its empty state — which looks exactly
  /// like a working screen with no data. Measured: that is what the first version of this fixture
  /// did, and `pumpUntil` is what turned it into a named failure instead of a passing test.
  Map<String, Object?> deliveryBoyList() => <String, Object?>{
        'status': 1,
        'data': <Object?>[
          <String, Object?>{
            'id': 1,
            'name': 'سامر خليل',
            'email': 'samer@example.test',
            'contact': '0933444555',
            'type': 'delivery_boy',
            'status': 1,
          },
          <String, Object?>{
            'id': 2,
            'name': 'رامي حداد',
            'email': 'rami@example.test',
            'contact': '0944555666',
            'type': 'delivery_boy',
            'status': 1,
          },
        ],
      };

  for (final combination in kFourCombinations) {
    testWidgets('the customers list renders its rows in ${combination.name}', (tester) async {
      final api = ApiStub()..on('customerlist', customerPage());
      final controller = CustomerController();

      await pumpScreen(
        tester,
        const CustomerScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(controller);
        },
      );

      await pumpUntil(
        tester,
        () => controller.customerList.isNotEmpty,
        reason: 'the customer list never filled — check the fixture\'s keys against '
            'CustomerModel.fromJson before assuming the screen is at fault',
      );

      await drainToasts(tester);

      expect(tester.takeException(), isNull);
      expect(controller.customerList.length, 3,
          reason: 'the fixture carries three customers; a different count means a parse problem');

      // The rows are really on screen, not merely in the controller.
      expect(find.textContaining('أمينة'), findsWidgets,
          reason: 'the first customer\'s name is not rendered, so the capture would show an '
              'empty list with a full controller behind it');

      final captured = await captureScreen(tester, captureName('flutter-customers-list', combination));

      if (captureDir != null) {
        expect(captured!.lengthSync(), greaterThan(1000));
      }
    });

    testWidgets('the delivery men list renders its rows in ${combination.name}', (tester) async {
      final api = ApiStub()..on('deliveryboy', deliveryBoyList());
      final controller = DeliveryBoyController();

      await pumpScreen(
        tester,
        const DeliveryBoyScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(controller);
        },
      );

      await pumpUntil(
        tester,
        () => controller.deliveryBoyList.isNotEmpty,
        reason: 'the delivery-man list never filled — DeliveryBoyModel reads `data` as a LIST and '
            'each row\'s phone as `contact`, not `mobile`',
      );

      await drainToasts(tester);

      expect(tester.takeException(), isNull);
      expect(controller.deliveryBoyList.length, 2);
      expect(find.textContaining('سامر'), findsWidgets,
          reason: 'the first delivery man\'s name is not rendered');

      final captured =
          await captureScreen(tester, captureName('flutter-delivery-men-list', combination));

      if (captureDir != null) {
        expect(captured!.lengthSync(), greaterThan(1000));
      }
    });
  }
}
