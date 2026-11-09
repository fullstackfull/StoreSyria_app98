import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/view/screen/product_screen/products_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-PRICE — a product with no discount shows NO PRICE in the admin app.
/// =================================================================================================
///
/// **THIS FILE RECORDS CURRENT BEHAVIOUR. IT DOES NOT ENDORSE IT.** The repair changes which number
/// a merchant sees on the product list, and the owner's standing constraints reserve "material
/// changes to prices" for an owner decision. The finding is written up in
/// `docs/design/PRODUCT-PRICE-PARITY.md`; this is the executable half, so that whoever takes the
/// decision can see it happen rather than take it on trust, and so the day it is fixed this test
/// fails and names itself.
///
/// WHAT WAS MEASURED.
///
/// The product card is handed its price by the screen, and the screen builds that string from
/// `salePrice` alone (`products_screen.dart:697`):
///
///     price: "${product.salePrice?.toString() ?? ""}  ${productController.currencySymbol.value}"
///
/// The card then renders `displayPrice > 0 ? price : '—'` (`product_widget.dart:330`), where
/// `displayPrice = parsePriceSafe(price)`.
///
/// `sale_price` IS THE OPTIONAL DISCOUNT, NOT THE SELLING PRICE. On the Laravel side it
/// `->default(0)` (`2023_12_26_092822_create_products_table.php:32`) and is validated
/// `nullable|numeric|min:0|lte:price` (`Api/DashboardController.php:2869`), and the host resolves
/// the effective price as "sale_price when set, otherwise price"
/// (`app/Models/Product.php:323-324`).
///
/// SO THE TWO SURFACES DISAGREE. The merchant WEB product list and grid print `$product->price`
/// (`ProductDataTable.php:68`, `product/list.blade.php:138`). The Flutter list prints `sale_price`.
/// For every product without a discount — which is the default state of every product — the web
/// shows the price and the app shows an em dash.
///
/// A dash is not a rounding difference or a formatting quibble: it is the absence of the single
/// most important number on a product card, on the screen a merchant uses to check their catalogue.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// One product priced 150 with NO discount — `sale_price: 0`, which is the column's default and
  /// therefore the state of every product nobody has discounted.
  Map<String, Object?> undiscountedProduct() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'currency_symbol': r'$',
          'current_page': 1,
          'last_page': 1,
          'per_page': 10,
          'total': 1,
          'data': <Object?>[
            <String, Object?>{
              'id': 1,
              'name': 'قميص قطن دمشقي',
              'product_code': 'SS-1001',
              'price': 150,
              'sale_price': 0,
              'final_price': 150,
              'product_stock': 12,
              'track_stock': 1,
              'status': 1,
              'is_active': 1,
              'variant_product': 0,
            },
          ],
        },
      };

  testWidgets('RECORDED DEFECT: an undiscounted product renders an em dash instead of its price',
      (tester) async {
    final api = ApiStub()..on('productlist', undiscountedProduct());
    final controller = ProductController();

    await pumpScreen(
      tester,
      const ProductsScreen(isBack: false),
      api: api,
      register: () {
        Get.put(controller);
      },
    );

    await pumpUntil(
      tester,
      () => controller.productList.isNotEmpty,
      reason: 'the product never loaded, so nothing about its price was measured',
    );

    await drainToasts(tester);

    expect(tester.takeException(), isNull);

    // The premise: the product really does carry a price, and really has no discount.
    expect(controller.productList.first.price, '150',
        reason: 'premise: the fixture\'s regular price parsed');
    expect(
      controller.productList.first.salePrice,
      anyOf('0', '', isNull),
      reason: 'premise: the fixture carries no discount',
    );

    // And the card shows neither.
    expect(
      find.text('—'),
      findsWidgets,
      reason: 'the em dash is gone — if the card now shows the price, this recorded defect is '
          'FIXED and this test should be replaced with one asserting the correct number. Do not '
          'simply delete it: the point is that the fix is deliberate and noticed.',
    );

    expect(
      find.textContaining('150'),
      findsNothing,
      reason: 'the price 150 is now rendered somewhere on the card. See above — this test exists '
          'to notice exactly that change.',
    );
  });

  testWidgets('and a DISCOUNTED product does show its discounted price', (tester) async {
    /// The control. Without it, "the card shows a dash" could be read as "the card never shows a
    /// price at all", which would be a different and larger defect. The card works; what it is
    /// given is wrong.
    final discounted = undiscountedProduct();
    final rows = ((discounted['data']! as Map<String, Object?>)['data']! as List).cast<Map<String, Object?>>();
    rows.first['sale_price'] = 120;

    final api = ApiStub()..on('productlist', discounted);
    final controller = ProductController();

    await pumpScreen(
      tester,
      const ProductsScreen(isBack: false),
      api: api,
      register: () {
        Get.put(controller);
      },
    );

    await pumpUntil(tester, () => controller.productList.isNotEmpty,
        reason: 'the discounted product never loaded');

    await drainToasts(tester);

    expect(find.textContaining('120'), findsWidgets,
        reason: 'the card does render a price when sale_price carries one, so the defect is in '
            'WHICH field the screen reads, not in the card');
  });
}
