/// P2-07-10 / WS K9 — the one rule both surfaces use to decide "in stock".
///
/// THE APP AND THE WEB DISAGREED, and the app was the one that was wrong.
///
/// The web reads `products.stock_status` ONLY when `track_stock == 0`. For a tracked product it
/// ignores that column and derives the badge from the live quantity:
/// `$product->product_stock <= $settings['out_of_stock_threshold']` → Out of stock
/// (`resources/views/product/list.blade.php:115-129`). The app read `stock_status`
/// unconditionally.
///
/// THAT IS NOT A COSMETIC DIFFERENCE, because of a measured fact about the schema:
/// `products.stock_status` is written ONLY from merchant input at create and update
/// (`ProductController:701`, `:1744`, and the admin API's own handlers) and is **never recomputed
/// when stock drains through an order**. So a tracked product created "in_stock" and sold down to
/// zero still carries `in_stock` in that column — and the app told the merchant it was In stock
/// while the web told them it was Out of stock. A merchant acting on the app would promote
/// something they cannot ship.
///
/// The threshold is a per-store SETTING rather than a constant, so it is read from the response
/// (`out_of_stock_threshold`, added additively to `productlist`) and falls back to 0 — the
/// setting's own default — when an older server does not send it.
enum StockState {
  inStock,
  outOfStock,
  onBackorder,

  /// A variant product. Neither surface reports a quantity or a status for one: the parent's
  /// `product_stock` is not its stock, and the real quantities live in `product_variants` rows
  /// that the list endpoint does not send. The web prints "-" and "In Variant"; the app matches.
  inVariant,
}

/// The web's rule, in one place.
///
/// [stockStatus] is the stored column, consulted only when stock is not tracked.
StockState resolveStockState({
  required bool hasVariant,
  required bool trackStock,
  required int? productStock,
  required String? stockStatus,
  int? outOfStockThreshold,
}) {
  if (hasVariant) return StockState.inVariant;

  // NOT TRACKED: the stored column is the merchant's own declaration and is all there is.
  if (!trackStock) {
    switch (stockStatus) {
      case 'out_of_stock':
      case '0':
        return StockState.outOfStock;
      case 'on_backorder':
        return StockState.onBackorder;
      default:
        return StockState.inStock;
    }
  }

  // TRACKED: the quantity decides, and the stored column is ignored exactly as the web ignores
  // it. `<=`, not `<`, matching list.blade.php:124.
  final threshold = outOfStockThreshold ?? 0;
  final stock = productStock ?? 0;

  return stock <= threshold ? StockState.outOfStock : StockState.inStock;
}
