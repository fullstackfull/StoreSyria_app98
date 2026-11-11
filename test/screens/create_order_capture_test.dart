import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/view/screen/order_screen/create_order_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-CREATEORDER — the counter-sale screen.
/// =================================================================================================
///
/// The one screen in the admin app where a merchant BUILDS something rather than reviewing it:
/// pick a customer, pick products, set quantities, take payment. It is also the longest form, so
/// it is where an Arabic label that wraps or a field that fails to mirror shows up first.
///
/// **Two controllers, both `Get.find`** (`create_order_screen.dart:24,28`), so neither is created
/// by the screen and both must be registered before it builds. Registered in the wrong order the
/// error names a controller the screen's own file does not mention, which is the trap the editor
/// screens recorded.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  for (final combination in kFourCombinations) {
    testWidgets('create order renders its form in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        Builder(builder: (_) => const CreateOrderScreen()),
        api: api,
        combination: combination,
        register: () {
          Get.put(ProductController());
          Get.put(OrderController());
        },
      );

      await pumpFrames(tester, frames: 16);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'create order threw in ${combination.name}');

      final context = tester.element(find.byType(CreateOrderScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'create order rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'create order rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-create-order', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the create-order capture is suspiciously small');
      }
    });
  }
}
