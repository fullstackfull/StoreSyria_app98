# Route 1, waves 4–5 — WHOLE SCREENS, as golden CANDIDATES awaiting human review

**These sixteen images are candidates, not approved baselines.** Nothing in this directory is
compared against on any push. A candidate becomes a baseline only when a person has looked at it
and copied it into `test/golden/goldens/`; from that moment the ordinary blocking `flutter test`
compares pixels against it on every push, for ever. `.gitignore:97` is untouched.

`CONTACT-SHEET.png` is all sixteen at a glance. The individual originals are beside it at full size.

| file | surface | language | direction | theme |
|---|---|---|---|---|
| `customers-screen.light-ltr.png` | Customers screen | English | LTR | Light |
| `customers-screen.light-rtl.png` | Customers screen | العربية | RTL | Light |
| `customers-screen.dark-ltr.png` | Customers screen | English | LTR | Dark |
| `customers-screen.dark-rtl.png` | Customers screen | العربية | RTL | Dark |
| `products-screen.light-ltr.png` | Products screen | English | LTR | Light |
| `products-screen.light-rtl.png` | Products screen | العربية | RTL | Light |
| `products-screen.dark-ltr.png` | Products screen | English | LTR | Dark |
| `products-screen.dark-rtl.png` | Products screen | العربية | RTL | Dark |
| `orders-screen.light-ltr.png` | Orders screen | English | LTR | Light |
| `orders-screen.light-rtl.png` | Orders screen | العربية | RTL | Light |
| `orders-screen.dark-ltr.png` | Orders screen | English | LTR | Dark |
| `orders-screen.dark-rtl.png` | Orders screen | العربية | RTL | Dark |
| `coupons-screen.light-ltr.png` | Coupons screen | English | LTR | Light |
| `coupons-screen.light-rtl.png` | Coupons screen | العربية | RTL | Light |
| `coupons-screen.dark-ltr.png` | Coupons screen | English | LTR | Dark |
| `coupons-screen.dark-rtl.png` | Coupons screen | العربية | RTL | Dark |

Sources: `lib/view/screen/customers/customer_screen.dart`,
`lib/view/screen/product_screen/products_screen.dart`,
`lib/view/screen/order_screen/order_screen.dart`,
`lib/view/screen/coupon_screen/coupon_screen.dart`.

**Wave 5 added the last two.** The orders list is the screen a merchant lives on, and the one
whose status vocabulary this project has measured as a *catalogue* (`order-status-badge-column`,
all ten chips in a column) but never seen in a real row beside a price and a date. The coupons
list is the card repaired in `01a9a09` — which had no boundary at all in light mode — in the list
it actually ships in.

---

## What is new here, and why it is a different kind of picture

`GAP-062`/`P02-K15` carries the next action *"Render a whole screen rather than a component, which
needs route 2 (the emulator) or a screen-level widget harness."* **There is no emulator in these
containers**, so this is the other branch of that sentence.

Every golden surface before this one is a COMPONENT in a bare `Scaffold` — wave 1's two list cards,
wave 2's badge catalogues and transaction card, wave 3's eleven shared states, controls and card
families. `5b3c6bb` said so in its own message: *"Still component-level only: no full SCREEN is
rendered as a golden."* These two are **real merchant screens**: the real `CustomerController` and
`ProductController`, their real `initState` fetches, the real app bar, search row, item count, list
and grid — with only the HTTP client replaced.

**Why that is worth a separate picture from the cards it contains.** `3727efc` found both list
cards stretching to fill any bounded box — a `Column` with no `mainAxisSize` inside a `Container`
with no height — and recorded that *"the app looked right for a reason that is not these widgets'
doing: both render inside a scrolling list where the main axis is UNBOUNDED."* A component baseline
cannot hold an opinion about that. A screen baseline beside it can.

**How they were produced.**

```
flutter test --tags golden --update-goldens test/golden/screen_golden_test.dart
cp test/golden/goldens/{customers-screen,products-screen}.*.png \
   docs/evidence/route-1-screen-candidates/
python3 tool/contact_sheet.py \
  --images-dir docs/evidence/route-1-screen-candidates \
  --out docs/evidence/route-1-screen-candidates/CONTACT-SHEET.png \
  --page-margin 10 \
  --surface "customers-screen|Customers screen|lib/view/screen/customers/customer_screen.dart" \
  --surface "products-screen|Products screen|lib/view/screen/product_screen/products_screen.dart"
```

Flutter 3.47.7, the version `.github/workflows/ci.yml` pins as `FLUTTER_VERSION`. The capture was
run twice and the eight files compared byte for byte: identical.

**The harness is the existing one, extended rather than duplicated.**
`test/support/screen_harness.dart` already pumped these screens for the `test/screens/*_capture_test.dart`
evidence captures; what it never did was produce a COMPARABLE artefact, because `captureScreen()`
writes a PNG only when `SS_CAPTURE_DIR` is set. `test/golden/screen_golden_test.dart` joins that
pump to `golden_harness.dart`'s baseline discipline. The two list fixtures moved to
`test/support/list_page_fixtures.dart` so the capture tests and the golden tests cannot drift apart
— the same move `sample_cards.dart` records, made for the same reason.

---

## A defect these pictures found, and it is fixed

**The product card's stock pill was unreadable in light mode.** Measured off
`products-screen.light-ltr.png` rather than off a constant: the chip `#E7F7FA` with `#0EAED1` ink,
**2.39:1**, where a 9.5 sp w700 label (7.1 pt — small text) needs 4.5:1 under SC 1.4.3.

`product_widget.dart` derived one colour and spent it twice — the fill at 10 % alpha and the label
opaque — so the label was painted in the same saturated hue as its own tint. That is the defect
`status_pill.dart` was already repaired for, in a different file. **And the repository's own source
already forbade it:** `store_syria_brand.dart:34` declares the cyan *"an accent and a dark-surface
brand, **never light-mode text**"*, and light mode sets `AppColor.themeGreenColor` to exactly that
cyan.

Only the combinations that FAIL moved; the tint hue is unchanged, which is the decision
`order_status_badge.dart:40-44` already records. Replacements come from the design system's
per-theme semantic foregrounds, already transcribed into this app at
`common_snak_bar_widget.dart:127-145`.

| state | theme | label before | was | label after | is |
|---|---|---|---|---|---|
| in stock | light | `#0EAED1` | 2.39:1 | `#15558F` `--ss-blue-800` | 7.00:1 |
| in stock | dark | `#22C7EA` | 6.19:1 | unchanged | 6.19:1 |
| on backorder | light | `#F59E0B` | 1.99:1 | `#5D3F04` `--ss-amber-900` | 8.92:1 |
| on backorder | dark | `#F59E0B` | 5.99:1 | unchanged | 5.99:1 |
| out of stock | light | `#EF4444` | 3.29:1 | `#8C1D17` `--ss-red-800` | 7.98:1 |
| out of stock | dark | `#EF4444` | 3.70:1 | `#F3A9A4` dark danger fg | 7.31:1 |

Pinned by `test/a11y/product_stock_pill_contrast_test.dart`, six states × the tint guard. The
images in this directory are the ones captured **after** the repair, and the 7.00:1 and 7.98:1
figures above were re-measured off those PNGs.

---

## Two more defects these pictures found, and both are fixed

**The coupons screen's app bar was hard-coded English.** `coupons-screen.dark-rtl.png` showed
`Coupon` and `Add Coupon` in Latin script above an otherwise Arabic page: `coupon_screen.dart:169`
and `:171` passed literals that `simpleAppBar` renders verbatim, so neither string ever reached
GetX. Every sibling screen already passes a key — `customer_screen.dart:95` is `"customers".tr`,
`products_screen.dart:493` is `"products".tr` — so this screen was the odd one out. **No copy was
written:** both keys already existed with text on both sides, and both English values are
byte-identical to the literals they replaced, which is the governing rule
`converted_labels_render_arabic_test.dart` records. Pinned by adding the two sites to that file's
own table.

**The Arabic item count printed the singular at every count.** `3 عنصر` and `2 عنصر` — Arabic
takes the plural of paucity for 3–10 and an obligatory DUAL for 2. There was no pluralisation path
in the app to reuse (`trPlural`, `Intl.plural` and the word `plural` appear in zero files), and
GetX's own `.trPlural` takes two forms, so it cannot express a dual. `lib/utils/plural.dart` now
selects a CLDR category and resolves one key family; the five call sites that built the label by
hand go through it. The screens now read `3 عناصر` and `عنصران`, visible in the images here.
**Exactly four of the sixteen images moved, all of them RTL** — every English image is byte-identical,
which is what proves the change is Arabic-only.

---

## Findings reported and NOT fixed

Each is recorded with its measurement so it is a decision somebody takes rather than something
that quietly went unnoticed.

1. **The product card's secondary text is below AA in light mode.** `#8A8F98` on the white card is
   **3.25:1** at 10.5 sp — the "Stock: 12" row, the placeholder icon and the untracked note. Dark
   mode is fine (`#A9B8D0` on `#18263F` is 7.53:1). Not fixed because `subTextColor` is spent at
   eight sites in that one widget and darkening it to the design system's `--ss-grey-700`
   (`#434D4C`, already transcribed in `error_empty_state.dart:299`) repaints the whole secondary
   layer of every product card. That is a palette decision, not a documented rule being broken.

2. **The Arabic item count does not agree with its number.** Both screens print `3 عنصر` and
   `2 عنصر`, the SINGULAR, where Arabic takes the plural for 3–10 and the dual for 2. The app has
   one key and no plural rules, so this is a copy and i18n decision rather than a one-line fix.

3. **Every order in the list shows `12:00 AM`.** Visible in `orders-screen.light-ltr.png`: both
   rows read `08 Nov 12:00 AM`. `order_screen.dart:412` formats `order.orderDate` with
   `FormatType.dateTime2`, which is `"dd MMM hh:mm a"` (`helper.dart:51-54`) — a format that
   includes a TIME — while the fixture's `order_date` is date-only (`2026-11-08`), so it parses to
   midnight. `OrderModel` carries `createdAt` as well (`order_model.dart:140`), which does hold a
   time. **Not fixed, and the reason is that it cannot be settled from here:** if the server sends
   a time in `order_date` there is no defect at all and the fixture is what is wrong instead.
   Changing which field a merchant's order time comes from is a data decision that needs the live
   payload, not a UI tidy-up.

4. **The currency symbol follows the number in English.** The price reads `150  $`, built by
   `products_screen.dart:714` as `"<final_price>  <currency_symbol>"`. The platform has a
   `site_currency_symbol_position` setting that `lang_widget.dart:334` names and this screen does
   not read. **Deliberately untouched:** anything that changes how a price is displayed is an
   owner decision on this project, not a UI tidy-up.

---

## What to look for when reviewing

- the Arabic screens read right-to-left as ONE layout — app bar, search row, count, list — not a
  mirrored shell around an unmirrored body;
- the back control, the "add" button and the search field's submit arrow all sit on the correct
  edge and point the correct way in each direction;
- the three customer cards are content-height with the page colour visible between them, not
  stretched (that is the regression `3727efc` repaired);
- the inactive customer's pill and the out-of-stock product's pill are legible in BOTH themes;
- every label is in the right language — no raw keys, no English left in the Arabic;
- nothing is clipped, ellipsised or overflowing at 360 × 800.

**Passing tests do not make these images correct.** The stock-pill defect above was found by
measuring a picture, after every assertion in the suite had gone green.

---

**THESE SIXTEEN REMAIN UN-REVIEWED AND UN-APPROVED.** No human has looked at them, nothing has been
copied into `test/golden/goldens/`, and all eight golden cases still skip with their own printed
reason. Route 1 step 2 is outstanding.
