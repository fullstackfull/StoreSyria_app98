import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/stock/stock_state.dart';

/// P2-07-10 / WS K9 — the app and the web must agree about "out of stock".
///
/// THE DEFECT, measured in both repositories before anything was written. The web reads
/// `products.stock_status` only when `track_stock == 0`; for a TRACKED product it ignores that
/// column and compares the live quantity to a per-store threshold
/// (`resources/views/product/list.blade.php:115-129`). The app read `stock_status`
/// unconditionally.
///
/// What makes that consequential rather than cosmetic: `products.stock_status` is written ONLY
/// from merchant input at create and update — `ProductController:701`, `:1744`, and the admin
/// API's `:2503`/`:2647` — and is **never recomputed when stock drains through an order**. So a
/// tracked product created `in_stock` and sold down to zero still carries `in_stock`. The web
/// showed "Out of stock". The app showed "In stock". A merchant acting on the app would promote
/// something they cannot ship.
void main() {
  group('a tracked product is decided by its quantity', () {
    /// THE CASE THAT WAS WRONG. Sold out, with a stale `in_stock` column.
    test('sold out with a stale in_stock column reads out of stock', () {
      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: true,
          productStock: 0,
          stockStatus: 'in_stock', // stale: never recomputed when the stock drained
        ),
        StockState.outOfStock,
        reason: 'the app called a sold-out product In stock because it trusted a column the web '
            'ignores for tracked products',
      );
    });

    test('stock above the threshold reads in stock', () {
      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: true,
          productStock: 5,
          stockStatus: 'out_of_stock', // equally stale, in the other direction
        ),
        StockState.inStock,
      );
    });

    /// THE THRESHOLD IS A PER-STORE SETTING, so a store that set it to 5 calls 5 units out of
    /// stock. Hardcoding 0 client-side would be right only for stores that never changed it.
    test('the per-store threshold is honoured', () {
      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: true,
          productStock: 5,
          stockStatus: 'in_stock',
          outOfStockThreshold: 5,
        ),
        StockState.outOfStock,
        reason: 'the web uses `<=`, so a quantity equal to the threshold is out of stock',
      );

      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: true,
          productStock: 6,
          stockStatus: 'in_stock',
          outOfStockThreshold: 5,
        ),
        StockState.inStock,
      );
    });

    /// `<=`, not `<`. The web is `$product->product_stock <= $settings['out_of_stock_threshold']`
    /// (list.blade.php:124), and off-by-one here is a product the merchant thinks they can sell.
    test('a quantity equal to the threshold is out of stock, matching the web', () {
      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: true,
          productStock: 0,
          stockStatus: 'in_stock',
          outOfStockThreshold: 0,
        ),
        StockState.outOfStock,
      );
    });

    /// AN OLDER SERVER sends no threshold. 0 is the setting's own default
    /// (`Utility.php:113`), so the behaviour is unchanged rather than guessed.
    test('a missing threshold falls back to the settings default of 0', () {
      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: true,
          productStock: 1,
          stockStatus: 'out_of_stock',
          outOfStockThreshold: null,
        ),
        StockState.inStock,
      );
    });

    test('a null quantity is treated as none, not as unknown-and-therefore-fine', () {
      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: true,
          productStock: null,
          stockStatus: 'in_stock',
        ),
        StockState.outOfStock,
        reason: 'a product whose quantity the server did not send must not be offered as sellable',
      );
    });
  });

  group('an untracked product is decided by its stored status', () {
    test('each stored value maps to its state', () {
      for (final pair in const <List<Object>>[
        ['in_stock', StockState.inStock],
        ['out_of_stock', StockState.outOfStock],
        ['0', StockState.outOfStock],
        ['on_backorder', StockState.onBackorder],
      ]) {
        expect(
          resolveStockState(
            hasVariant: false,
            trackStock: false,
            productStock: 0, // ignored: stock is not tracked
            stockStatus: pair[0] as String,
          ),
          pair[1],
          reason: 'stored status "${pair[0]}"',
        );
      }
    });

    /// THE QUANTITY MUST NOT LEAK IN. An untracked product with zero recorded stock is still
    /// in stock if the merchant said so — that is what "do not track stock" means.
    test('a zero quantity does not override the merchant declaration', () {
      expect(
        resolveStockState(
          hasVariant: false,
          trackStock: false,
          productStock: 0,
          stockStatus: 'in_stock',
          outOfStockThreshold: 10,
        ),
        StockState.inStock,
      );
    });

    test('an unknown or empty stored value is treated as in stock, as the web does', () {
      for (final value in const <String?>[null, '', 'something else']) {
        expect(
          resolveStockState(
            hasVariant: false,
            trackStock: false,
            productStock: 3,
            stockStatus: value,
          ),
          StockState.inStock,
          reason: 'list.blade.php falls through to In stock for any value but the two it names',
        );
      }
    });
  });

  /// A VARIANT PRODUCT IS NEITHER, on both surfaces. The parent's `product_stock` is not its
  /// stock, and the real quantities live in `product_variants` rows the list endpoint does not
  /// send. The web prints "-" and "In Variant"; the app matches rather than inventing a number.
  group('a variant product', () {
    test('is reported as in-variant whatever else is set', () {
      for (final tracked in const <bool>[true, false]) {
        expect(
          resolveStockState(
            hasVariant: true,
            trackStock: tracked,
            productStock: 0,
            stockStatus: 'out_of_stock',
            outOfStockThreshold: 99,
          ),
          StockState.inVariant,
          reason: 'trackStock: $tracked',
        );
      }
    });
  });
}
