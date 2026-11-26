# Route 1, wave 2 — three more pixel surfaces, and what looking at them found

**Date** 2026-11-26 · **SDK** Flutter 3.47.7 (`.github/workflows/ci.yml`'s pinned `FLUTTER_VERSION`)
· **Register rows** `GAP-084`/`P2.5-I-02`, `GAP-062`/`P02-K15`, `GAP-066`/`P02-XC-02`

`GAP-062` says it plainly: *"No screen of this app has ever been rendered and seen, by anyone or
anything in these containers."* Wave 1 answered that for two list cards. This is wave 2 — three more
surfaces, twelve more images, and **four defects that only the pictures show**.

---

## 1. What was added

| surface | widget | what one image holds |
|---|---|---|
| `order-status-badge-column` | `CommonStatusBadge`, `StatusBadgeType.order` | all nine `delivered_status` values **plus the default branch**, each in **both shipped shapes** — 20 chips |
| `payment-status-badge-column` | `CommonStatusBadge`, `StatusBadgeType.payment` | Paid · Unpaid · a **null** status · Paid with a Latin method · Paid with an Arabic method, both shapes — 10 chips |
| `transaction-card` | `transactionCard` | a **credit/completed** row and a **debit/pending** row, which is the only way to reach the card's red side |

Four combinations each — Arabic (RTL) and English (LTR) × light and dark — so **12 new images**, and
20 in the baseline set.

**Why columns and not one badge per image.** `order_status_badge.dart` carries **nineteen hardcoded
`Color(0x…)` pairs** and no theme tokens, which is the condition under which this project keeps
finding contrast defects. One baseline per chip would be 40 files for the order type alone; one
column per type is four files in which a reviewer's eye compares the pairs against *each other*.

**Files.**

```
test/golden/status_badge_golden_test.dart        new
test/golden/transaction_card_golden_test.dart    new
test/golden/golden_infrastructure_test.dart      +3 entries in kGoldenSurfaces
test/support/sample_cards.dart                   +sampleWithdrawalTransaction()
```

**No PNG is committed and `.gitignore:97` is untouched.** The twelve images exist only as generated
output for the human review that route 1 step 2 requires. Each case **skips with a reason** until a
reviewed baseline lands — that is the designed state in which this change arrives.

---

## 2. Both states, executed

**Uncaptured** — `flutter test test/golden/` with `test/golden/goldens/*.png` removed:

```
00:01 +0 ~20: test/golden/golden_infrastructure_test.dart: the baseline set is never HALF captured
[golden] 0 of 5 surfaces have a reviewed baseline set (0 of 20 images). Route 1 step 2 is
         outstanding: run the capture job, review the PNGs, commit them.
00:01 +11 ~20: All tests passed!
```

20 skips, every one of them printing its own reason; 11 infrastructure tests pass.

**Captured** — `flutter test --tags golden --update-goldens` then `flutter test test/golden/`:

```
[golden] 5 of 5 surfaces have a reviewed baseline set (20 of 20 images). Complete.
00:02 +31: All tests passed!
```

**The whole blocking gate**, `flutter test --reporter expanded`: `01:39 +2013: All tests passed!` —
2013 tests, no failures, no skips.

**Determinism.** Re-capturing wave 1's eight baselines under the pinned SDK produced files
**byte-identical** to the ones already on disk (`cmp` on all eight). The 3.47.7 pin holds.

> `flutter pub get` under 3.47.7 rewrites `analysis_options.yaml`, adding an `analyzer: exclude:`
> block. It was reverted with `git checkout --` after every run; no tracked file outside the four
> above is modified.

---

## 3. What is in each image

**`order-status-badge-column`** — ten rows, identified by their own labels, no scaffolding text.
Every chip legible in all four. Icons render as real glyphs, not the empty squares wave 1 found.
The default row reads **"Status not recognised" / "حالة غير معروفة"**, not the bare lowercase key —
that repair is now visible. Nothing clipped, nothing ellipsised, no row overflows; the two shapes
fit on one line in every row. Height 382 px of the 800 px surface.

**`payment-status-badge-column`** — five rows. Row 3 (`paymentStatus: null`) is **pixel-identical**
to row 2 (`'Unpaid'`), so the two `?? 'Unpaid'` fallbacks agree. Rows 4 and 5 carry the bidi runs:
`Paid by Stripe` keeps "Stripe" after the English, and in Arabic `تم الدفع عبر Stripe` correctly
moves the Latin run to the left end of the line. The Arabic method name makes the pair too wide for
one line and the `Wrap` puts the second shape on its own run — visible, not a crash.

**`transaction-card`** — two rows. Credit: green, `↓`, `+ 150.00 SYP`, `Completed`. Debit: red, `↑`,
the `indeterminate_check_box` tile, `- 75.50 SYP`, `pending`. The amount's digits are **in Tajawal**,
confirming the `RichText` root-span repair (`transactions_widget.dart:144-148`) by sight.

**RTL is genuinely RTL, not a re-run of LTR.** Three independent proofs: the content bounding box
moves from `x=12…` to `…x=347`; each chip's icon and chevron swap ends; and **`Icons.undo` on the
Return badge is auto-mirrored** — it curves left in English and right in Arabic. Arabic dates render
as `٠٦ نوفمبر ١٠:٠٠ ص`, with the Arabic month name and Arabic-Indic digits, so the `intl` locale
repair at `helper.dart:21-26` works.

> **A harness fact worth recording.** This file needs no `initializeDateFormatting()` of its own,
> though `screen_harness.dart:117` makes the call and `helper.dart:25` warns that
> `DateFormat(fmt, 'ar')` throws without it. `goldenHost` passes
> `TranslationService.localizationsDelegates`, and `GlobalMaterialLocalizations.delegate`
> initialises the `intl` date symbols for the locale it loads. The harness docstring credits those
> delegates only with fixing `textDirection`; they are also what makes a date format in Arabic at
> all. Measured by capturing without the call and reading the month off the image.

---

## 4. Four defects, measured off the rendered pixels

### 4.1 The light badge set has no boundary contrast, and the dark set does — NEW

`order_status_label_test.dart` has eighteen tests. Two of them —
*"every dark badge border reaches 3:1 against the dark card"* and *"every dark badge fill is visible
as a surface without glaring"* — are **dark-only**. There is no light equivalent, and the light
docstring (`order_status_badge.dart:29-44`) discusses text contrast only.

Declared border against the measured page colour:

| | weakest | strongest | SC 1.4.11 (3:1) |
|---|---|---|---|
| dark, vs card `#18263F` | 3.00:1 | 3.16:1 | **all ten pass** |
| light, vs page `#FFFFFF` | **1.29:1** (6 Shipped) | 1.65:1 | **all ten fail** |

The faintest light chip — 6 Shipped, fill `#FFF8E1` at **1.06:1** against white inside a `#FFE082`
border at 1.29:1 — is visibly a ghost in `order-status-badge-column.light-ltr.png`. The detail-shape
badge is **interactive** (`order_detail_screen.dart:535/1172` give it `onTap` and a chevron opening
the status sheet), so 1.4.11 applies to it as a control, not merely as decoration.

Text contrast is fine and the repairs hold: measured off the raster, every light pair is
**4.56–9.56:1** and every dark pair **4.50–7.15:1**, reproducing the source's own figures exactly
(Pending 5.75, Picked Up 6.60, Shipped 5.86). Dark status 8 Pre Order sits at **exactly 4.50:1** —
passing with zero margin.

**Not fixed here.** Re-pitching ten light borders changes every order list in the shipped app; that
is a design decision, not an obvious correction. The four approved baselines will pin it either way.

### 4.2 The wallet transaction type renders in English on an Arabic screen — NEW

`transactions_widget.dart:216-221`, `_formatType()`, splits on `_`, capitalises and rejoins. **There
is no `.tr` in it.** An Arabic merchant on /finance reads `Order` and `Manual Withdrawal` in Latin
script — visible in both Arabic images. Same family as the defect
`order_status_badge.dart:236-241` already fixed for status descriptions.

### 4.3 A transaction status that is not `completed` prints the raw server string — NEW

`transactions_widget.dart:189`: `isCompleted ? 'completed'.tr : status`. The host schema declares
`enum('status', ['pending','completed','cancelled'])`
(`syriastore98/database/migrations/2026_11_02_000200_create_store_wallet_transactions_table.php:67`),
so **two of the three reachable values bypass translation entirely**. Both Arabic images show
`مكتمل` on one row and lowercase `pending` on the row below it.

And it is the worst contrast on the card: measured off the pixels, `#F59E0B` on its own 10 % tint
`#FEF5E7` is **1.99:1** — the same shape of defect as the order badge's status 6 at 1.85:1 that this
project has already repaired once. `Completed` is **2.96:1**. Both are 10 sp w600 small text.

### 4.4 The transaction card's accent text is below AA in light mode — NEW

Measured off `transaction-card.light-ltr.png`, against the white card:

| element | colour | ratio | needs |
|---|---|---|---|
| `Credit` label 11 sp w600, and `+ 150.00 SYP` 15 sp w800 | `#16A34A` | **3.30:1** | 4.5:1 |
| `Debit` label, and `- 75.50 SYP` | `#EF4444` | **3.76:1** | 4.5:1 |
| type line, description, date, 12 sp | `#777D87` | **4.14:1** | 4.5:1 |

15 sp bold is 11.25 pt — below WCAG's 14 pt-bold large-text threshold, so the amounts need 4.5:1
too. **Dark mode is the better half**: the same elements measure 4.59, 4.02 and 7.53:1 there, and
the `pending` pill climbs from 1.99:1 to 5.10:1.

Related, not a separate finding: the light card is `Colors.white` on a `#FFFFFF` page separated only
by a `#CFD9E3` hairline at **1.43:1**, and in dark the card carries **no border and no shadow at
all** (`transactions_widget.dart:38`, `:41`) with a fill 1.15:1 against the page. Both are visible
in the images as very faint card edges.

---

## 5. What is outstanding

1. **A human reviews the twelve images and commits the good ones** with
   `git add -f test/golden/goldens/<surface>.<theme>-<dir>.png`. Until then the twelve cases skip
   and assert nothing. The four findings above are reasons to review rather than reasons to delay:
   none of them is a *rendering* fault, so the baselines are faithful pictures of the current app.
2. **Dispositions for 4.1–4.4.** 4.2 and 4.3 are copy work of the kind
   `docs/development/phase-2.5/COPY-DECK-UNTRANSLATED-SCREENS.md` already ran once, and the keys
   `pending` and `cancelled` both already exist in `ar.dart`. 4.1 and 4.4 are palette decisions.
3. **`GAP-084` is still partial.** 5 surfaces of 75 now have pixel evidence, up from 2. No Flutter
   surface has a device frame and the emulator-in-CI route is still untaken; widening the widget
   harness does not close either.
