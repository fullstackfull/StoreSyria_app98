# The admin app shows no price for any product that has no discount

**Status: a MEASURED finding with a one-line fix, deliberately NOT applied.** It changes which
number a merchant sees on the product list, and the owner's standing constraints reserve "material
changes to prices" for an owner decision. Found 2026-11-09 by the Phase 2.5 screen harness, on the
first populated capture of the products screen.

The executable half is `test/screens/product_price_parity_test.dart`, which demonstrates the
behaviour and fails the day it is fixed.

---

## What was measured

The products screen builds the card's price string from **`salePrice` alone**
(`lib/view/screen/product_screen/products_screen.dart:697`):

```dart
price: "${product.salePrice?.toString() ?? ""}  ${productController.currencySymbol.value}",
```

and the card renders (`lib/view/screen/product_screen/product_widget.dart:330`):

```dart
displayPrice > 0 ? price : '—'
```

with `displayPrice = parsePriceSafe(price)`.

**`sale_price` is the optional DISCOUNT, not the selling price.** On the Laravel side:

| evidence | file |
|---|---|
| `$table->float('sale_price')->default(0)` | `database/migrations/2023_12_26_092822_create_products_table.php:32` |
| `'sale_price' => 'nullable\|numeric\|min:0\|lte:price'` | `app/Http/Controllers/Api/DashboardController.php:2869` |
| the host resolves the effective price as *"sale_price when set, otherwise price"* | `app/Models/Product.php:323-324` |

So `sale_price` is `0` for every product nobody has discounted — which is the default state of
every product.

### The two surfaces disagree

| surface | what it prints | source |
|---|---|---|
| merchant **web** list | `$product->price` | `app/DataTables/ProductDataTable.php:68` |
| merchant **web** grid | `$product->price` | `resources/views/product/list.blade.php:138` |
| **Flutter** list | `salePrice` | `products_screen.dart:697` |

For an undiscounted product the web shows the price and the app shows an **em dash**.

## Why it matters

A dash is not a rounding difference or a formatting quibble. It is the absence of the single most
important number on a product card, on the screen a merchant opens to check their catalogue — and
it is the DEFAULT state, not an edge case. A merchant who has never set a discount sees no prices
at all in the app while the web shows them correctly.

**The card is not at fault.** The control in the test file proves it: give the same product a
`sale_price` of 120 and the card renders `120`. The defect is *which field the screen reads*.

## The shape of a fix, and why it is not applied here

The host's own rule is already written down (`Product.php:323-324`): the effective price is
`sale_price` when it is set, and `price` otherwise. The screen would read the same way —

```dart
final effective = (product.salePrice != null && (double.tryParse(product.salePrice!) ?? 0) > 0)
    ? product.salePrice!
    : (product.price ?? '');
```

— or, better, the API would send one resolved field and both clients would read that, which is how
the two surfaces stop being able to disagree at all.

**Not applied, for three reasons.**

1. It changes a price a merchant reads, which the owner's constraints reserve.
2. "sale_price when set, otherwise price" is the HOST's rule; whether the admin app should show the
   effective price, the regular price, or both (struck-through) is a product decision, not an
   engineering one. The web currently shows the regular price even when a discount exists, so the
   two surfaces would still disagree after the obvious fix — just differently.
3. The right repair may be on the server, and that is a public API change.

## What is already in place

* `test/screens/product_price_parity_test.dart` — two tests: the recorded defect, and the control
  proving the card works when given a price. The first fails the day the defect is fixed, and says
  so in its failure message rather than being silently deleted.
* The capture that raised it: `flutter-products-list_*` under
  `docs/development/phase-2.5/evidence/flutter-harness-2026-11-09/after/` in the Laravel
  repository. The em dash is visible on both cards.
