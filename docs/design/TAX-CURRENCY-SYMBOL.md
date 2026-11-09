# A fixed-amount tax has no currency, because the server never sends one

**Status: a MEASURED gap with a server-side fix, deliberately NOT applied.** Adding a field to a
public API response is a compatibility change, and the owner's standing constraints reserve those.
Found 2026-11-09 by the Phase 2.5 screen harness, on the first populated capture of the tax screen.

---

## What was measured

The tax list built a fixed-amount row as (`lib/view/screen/home_screen/tax_screen.dart:274`):

```dart
: "\$${tax.taxAmount} ${'Discount'.tr}";
```

A **hard-coded US dollar sign**, on a product whose stores price in Syrian pounds. The capture
`flutter-tax-list_en_ltr_light.png` shows `$25 Discount` on a municipality fee, beside a wallet
screen in the same app that correctly prints `ل.س`.

That `$` was removed in P2.5-FLUTTER-TAX-LABEL, along with the `Discount` mislabel, because showing
**no** symbol is strictly better than showing a wrong one. What remains is the gap this file
records: the amount now carries no unit at all.

## Why the app cannot simply show the right one

| question | answer | evidence |
|---|---|---|
| does `taxlist` return a currency? | **no** — it returns the paginator and nothing else | `app/Http/Controllers/Api/DashboardController.php::TaxList` |
| does the app cache the store currency? | **no** | every `currencySymbol` in `lib/` is assigned from the response of that screen's own endpoint — `product_controller.dart:69`, `wallet_controller.dart:90`, `order_controller.dart:675`, `product_detail_controller.dart:34` |

So there is no local source to read. `TaxController` has no `currencySymbol` field because there is
nothing for it to hold.

## The shape of a fix

The wallet already does the right thing: `WalletData.fromJson` reads a `currency_symbol` that the
server puts beside the data. `TaxList` would do the same —

```php
return $this->success([
    'currency_symbol' => $store->currency_symbol ?? '',
    // ... the existing paginator payload, unchanged
]);
```

— and `TaxController` would surface it the way `ProductController` does. Adding a key is
backward-compatible for the shipped client, which ignores unknown keys, so the risk is low; it is
still a change to a public response shape and therefore an owner decision.

**The same question applies to `shippinglist`**, whose rows carry an `amount` the screen does not
currently display at all. That is a separate gap and is not claimed here.

## What is already in place

* The wrong symbol is gone, and `test/screens/tax_label_correctness_test.dart` fails if it returns.
* The capture that raised it: `flutter-tax-list_*` under
  `docs/development/phase-2.5/evidence/flutter-ops-2026-11-09/after/` in the Laravel repository.
