import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/screen/product_screen/product_detail_screen.dart';

import '../support/golden_harness.dart';
import '../support/nested_fixtures.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-PRODUCTDETAIL — the product a merchant opens from the catalogue.
/// =================================================================================================
///
/// **The screen takes the product and fetches only its images.** `ProductDetailScreen` receives a
/// `ProductData` the caller already has from the list, and `/viewproduct` returns the gallery —
/// `ProductDetailModel` reads `image_path`, `image_path_full_url` and `product_id`, and nothing
/// about name or price. A fixture written as "the product detail response" therefore parses to an
/// empty image list while the screen still renders the product correctly, which makes the mistake
/// invisible. The fixture file records that split.
///
/// **It registers its own controllers** (`product_detail_screen.dart:43-47` calls `Get.put` in
/// field initialisers), so the screen is built inside a `Builder` and this test registers nothing.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  ProductData product() => ProductData.fromJson(productDataJson());

  for (final combination in kFourCombinations) {
    testWidgets('product detail renders the product and its gallery in ${combination.name}',
        (tester) async {
      final api = ApiStub()..on('viewproduct', productImagesResponse());

      await pumpScreen(
        tester,
        Builder(
          builder: (_) => ProductDetailScreen(
            categoryId: '3',
            product: product(),
            productId: '41',
            id: '41',
          ),
        ),
        api: api,
        combination: combination,
      );

      await pumpUntil(
        tester,
        () => api.sawRequestFor('viewproduct'),
        reason: 'the gallery endpoint was never called. Recorded: ${api.calls}',
      );
      await pumpFrames(tester, frames: 14);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'product detail threw in ${combination.name}');

      // The product's own name, so the constructor argument really reached the screen rather
      // than the screen rendering a placeholder.
      expect(find.textContaining('Aleppo Laurel Soap'), findsWidgets,
          reason: 'the product name is not on its own detail screen');

      final context = tester.element(find.byType(ProductDetailScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'product detail rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'product detail rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-product-detail', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the product detail capture is suspiciously small');
      }
    });
  }

  /// A product with no gallery must render rather than crash — and it is the ordinary state for
  /// a product whose images have not been uploaded yet.
  testWidgets('a product with no images renders without throwing', (tester) async {
    final api = ApiStub()..on('viewproduct', productNoImagesResponse());

    await pumpScreen(
      tester,
      Builder(
        builder: (_) => ProductDetailScreen(
          categoryId: '3',
          product: product(),
          productId: '41',
          id: '41',
        ),
      ),
      api: api,
    );

    await pumpFrames(tester, frames: 16);
    await drainToasts(tester);

    expect(tester.takeException(), isNull,
        reason: 'a product with an empty gallery threw rather than rendering its cover image');
  });
}
