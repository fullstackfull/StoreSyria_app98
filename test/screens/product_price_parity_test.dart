import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/view/screen/product_screen/products_screen.dart';

import '../support/screen_harness.dart';

/// P2.5-FLUTTER-PRICE — FIXED. The product list shows the same price the merchant web shows.
/// =================================================================================================
///
/// **THIS FILE USED TO RECORD THE DEFECT. IT NOW GUARDS THE FIX**, which is what its earlier header
/// asked for: "the day it is fixed this test fails and names itself. Do not simply delete it."
///
/// THE DEFECT, for the record. The screen built the card's price from `salePrice` alone, and
/// `sale_price` is the optional DISCOUNT — `->default(0)` in the products migration, validated
/// `nullable|numeric|min:0|lte:price` (`Api/DashboardController.php:2869`). It is `0` for every
/// product nobody has discounted, which is the default state of every product, and the card renders
/// `displayPrice > 0 ? price : '—'`. So an ordinary catalogue showed **no prices at all** in the
/// app while the web printed them correctly.
///
/// THE FIX IS TO READ THE FIELD THE SERVER ALREADY RESOLVES. `ProductList` sends `final_price`
/// beside `price` and `sale_price`, and sets it from the product's own `price`: it strips the
/// expensive `final_price` append and falls back through
/// `getRawOriginal('final_price') ?? getRawOriginal('price')`, where the first is null because
/// `final_price` is an accessor on `Product` and a column only on `orders`. That is the same number
/// the merchant web prints (`ProductDataTable.php:68`, `product/list.blade.php:138`).
///
/// So the two surfaces now agree **by reading the same field**, no pricing calculation changed, and
/// no API contract changed — the field was already there.
///
/// `tests/Feature/Api/ProductListPriceContractTest.php` in the Laravel repository pins the server
/// half, so the field cannot quietly stop being sent or stop equalling `price`.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// One product priced 150 with NO discount — `sale_price: 0`, the column's default and therefore
  /// the state of every product nobody has discounted. `final_price` carries the resolved display
  /// price, exactly as the server sends it.
  Map<String, Object?> product({
    required Object price,
    required Object salePrice,
    required Object finalPrice,
  }) =>
      <String, Object?>{
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
              'price': price,
              'sale_price': salePrice,
              'final_price': finalPrice,
              'product_stock': 12,
              'track_stock': 1,
              'status': 1,
              'is_active': 1,
              'variant_product': 0,
            },
          ],
        },
      };

  Future<ProductController> pumpProducts(WidgetTester tester, Map<String, Object?> body) async {
    final api = ApiStub()..on('productlist', body);
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
    return controller;
  }

  testWidgets('an UNDISCOUNTED product shows its price, not an em dash', (tester) async {
    /// The case the defect was about: the default state of every product.
    final controller = await pumpProducts(
      tester,
      product(price: 150, salePrice: 0, finalPrice: 150),
    );

    // The premise: the fixture really does carry a price and really has no discount.
    expect(controller.productList.first.price, '150',
        reason: 'premise: the regular price did not parse');
    expect(controller.productList.first.salePrice, anyOf('0', '0.00', '', isNull),
        reason: 'premise: the fixture carries no discount');

    expect(find.textContaining('150'), findsWidgets,
        reason: 'an undiscounted product shows no price. The card reads `final_price`, which the '
            'server resolves from the product\'s own price — the same number the merchant web '
            'prints. If this fails, the screen has gone back to reading `sale_price`, or the '
            'server stopped sending `final_price`.');

    expect(find.text('—'), findsNothing,
        reason: 'the em dash is back on a product that has a price');
  });

  testWidgets('a DISCOUNTED product shows the resolved price the web shows', (tester) async {
    /// Parity, not cleverness. The merchant web prints `$product->price` on both its list and its
    /// grid even when a discount exists, and `ProductList` resolves `final_price` from that same
    /// `price`. So a discounted product shows **150** on both surfaces, and the app must not
    /// invent a struck-through treatment that would make the two disagree again — differently.
    final controller = await pumpProducts(
      tester,
      product(price: 150, salePrice: 120, finalPrice: 150),
    );

    expect(controller.productList.first.salePrice, '120',
        reason: 'premise: the discount did not parse');

    expect(find.textContaining('150'), findsWidgets,
        reason: 'the card no longer shows the resolved display price for a discounted product');
    expect(find.textContaining('120'), findsNothing,
        reason: 'the card is showing the DISCOUNT as the price. `sale_price` is the discount, and '
            'the merchant web shows the regular price; showing 120 here puts the two surfaces back '
            'into disagreement.');
  });

  testWidgets('the card still falls back to an em dash when there really is no price',
      (tester) async {
    /// The control, and the reason the em dash exists at all. `displayPrice > 0 ? price : '—'`
    /// is correct behaviour for a product with no price; the defect was never the card, it was
    /// which field the card was handed.
    await pumpProducts(tester, product(price: 0, salePrice: 0, finalPrice: 0));

    expect(find.text('—'), findsWidgets,
        reason: 'a product with no price at all should still render the em dash rather than a '
            'bare currency symbol');
  });
}
