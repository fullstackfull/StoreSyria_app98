import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/product_controller/add_product_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/view/screen/product_screen/add_new_product_screen.dart';
import 'package:store_go_app/view/screen/product_screen/add_rating_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-EDITORS — the two screens a merchant TYPES into.
/// =================================================================================================
///
/// Forms are where the four combinations earn their keep: a label that fits in English wraps in
/// Arabic, a field that reads left-to-right has to flip, and a hint that is legible on white can
/// vanish on the dark surface. None of that is visible from a mount test.
///
/// **`AddRatingScreen` registers its own controller** (`:39` calls `Get.put` in a field
/// initialiser) so it is built inside a `Builder` and this test registers nothing for it.
/// **`AddNewProductScreen` does the opposite** — `:79` calls `Get.find<AddProductController>()`,
/// so the controller must already exist or the screen throws `"AddProductController" not found`,
/// which reads like a harness bug rather than a missing registration.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  for (final combination in kFourCombinations) {
    testWidgets('add rating renders its form in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        Builder(
          builder: (_) => const AddRatingScreen(
            categoryId: '3',
            productId: '41',
            id: '41',
            isUpdate: false,
          ),
        ),
        api: api,
        combination: combination,
      );

      await pumpFrames(tester, frames: 14);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'add rating threw in ${combination.name}');

      final context = tester.element(find.byType(AddRatingScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'add rating rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'add rating rendered the wrong brightness in ${combination.name}',
      );

      // A form with no field is a form that did not build.
      expect(find.byType(TextField).evaluate().length + find.byType(TextFormField).evaluate().length,
          greaterThan(0),
          reason: 'add rating rendered no input at all');

      final captured = await captureScreen(tester, captureName('flutter-add-rating', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the add-rating capture is suspiciously small');
      }
    });

    testWidgets('the product editor renders its create form in ${combination.name}',
        (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        Builder(builder: (_) => const AddNewProductScreen(isUpdate: false)),
        api: api,
        combination: combination,
        register: () {
          // `Get.find`, not `Get.put`, at add_new_product_screen.dart:79 -- and
          // AddProductController's own constructor does `Get.find<ProductController>()` at
          // add_product_controller.dart:17, so the dependency chain has to be registered from
          // the bottom up. Registered in the wrong order the failure reads
          // `"ProductController" not found`, which points at a screen that never mentions it.
          Get.put(ProductController());
          Get.put(AddProductController());
        },
      );

      await pumpFrames(tester, frames: 16);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'the product editor threw in ${combination.name}');

      final context = tester.element(find.byType(AddNewProductScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'the product editor rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'the product editor rendered the wrong brightness in ${combination.name}',
      );

      expect(find.byType(TextField).evaluate().length + find.byType(TextFormField).evaluate().length,
          greaterThan(0),
          reason: 'the product editor rendered no input at all');

      final captured =
          await captureScreen(tester, captureName('flutter-product-editor', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the product editor capture is suspiciously small');
      }
    });
  }
}
