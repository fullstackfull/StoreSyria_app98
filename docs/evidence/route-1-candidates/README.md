# Route 1 — golden CANDIDATES awaiting human review

**These eight images are candidates, not approved baselines.** Nothing in this directory is
compared against on any push. A candidate becomes a baseline only when a person has looked at it
and copied it into `test/golden/goldens/`; from that moment the ordinary blocking `flutter test`
compares pixels against it on every push, for ever.

`CONTACT-SHEET.png` is all eight at a glance. The individual originals are beside it at full size.

| file | surface | language | direction | theme |
|---|---|---|---|---|
| `customer-card.light-ltr.png` | Customer card | English | LTR | Light |
| `customer-card.light-rtl.png` | Customer card | العربية | RTL | Light |
| `customer-card.dark-ltr.png` | Customer card | English | LTR | Dark |
| `customer-card.dark-rtl.png` | Customer card | العربية | RTL | Dark |
| `delivery-boy-card.light-ltr.png` | Delivery-man card | English | LTR | Light |
| `delivery-boy-card.light-rtl.png` | Delivery-man card | العربية | RTL | Light |
| `delivery-boy-card.dark-ltr.png` | Delivery-man card | English | LTR | Dark |
| `delivery-boy-card.dark-rtl.png` | Delivery-man card | العربية | RTL | Dark |

Sources: `lib/view/new_widgets/customer_widget.dart`, `lib/view/new_widgets/delivery_boy_widget.dart`.
Captured with `flutter test --tags golden --update-goldens` on Flutter 3.47.7.

---

## Defects corrected BEFORE asking for acceptance

An earlier set of candidates existed and **every one of them carried a defect**. They are listed
because the point of step 2 is that a plausible-looking image can be wrong, and because these were
found only by looking.

1. **The customer card never showed the customer's e-mail.** The row carried
   `Icons.email_outlined` and rendered `city` beside it — an e-mail icon labelling a place name —
   while `CustomerData.email` went unread. With no city in the fixture the row rendered a literal
   `--`, so all four customer candidates showed a dash where the address belongs. The merchant web
   card shows identity first, name then e-mail (`customer/grid.blade.php:159`), and the
   delivery-man card in the same folder already paired the e-mail icon with the e-mail. This card
   was the odd one out.
2. **The fixture put `email` inside `customer_info`,** where the model does not read it
   (`CustomerInfo` carries only name and mobile). The API puts it beside that object. So the
   fixture exercised neither path — the same class of mistake as the `mobile`/`contact` one fixed
   in the previous round.
3. **`'--'` rows on both cards.** A row that costs a line and says nothing. Every optional row is
   now conditional; the orders count stays unconditional because zero orders is a real answer.
4. **Three English strings were their own lowercase keys.** `'commission:' -> 'commission:'`,
   `'disabled' -> "disabled"`, `'enabled' -> "enabled"` — so the English delivery-man card read
   `commission: 0%` and `disabled` beside a customer card reading `Active`. The Arabic had been
   written properly in all three cases, so this was visible only in English.
   `test/localization/english_placeholder_strings_test.dart` now fails if a key a screen renders is
   still its own lowercase text.

## One change that was proposed and then measured away

The e-mail and phone rows were briefly given `textDirection: TextDirection.ltr`, reasoning from the
web card's `dir="ltr"`. `test/rtl/customer_card_direction_test.dart` forbids
`TextDirection.ltr` in these two files, because an earlier version of them pinned the whole card
header LTR and broke the Arabic layout.

Rather than argue with the guard, both variants were captured and compared byte for byte: the four
LTR images were **identical**, and the RTL pair differed only sub-pixel with no visible change —
the Unicode bidi algorithm already lays a Latin address and a digit run out correctly inside an
Arabic paragraph. **The pin bought nothing and the guard was right.** It was removed.

## What to look for when reviewing

- the Arabic images read right-to-left as one layout, not two stacked ones;
- the e-mail and the phone number read correctly inside the Arabic text;
- every label is in the right language — no raw keys, no English left in the Arabic;
- no row shows a dash, a blank or a placeholder;
- the icon beside each row matches what the row contains;
- the status pill is legible in both themes.

**Passing tests do not make these images correct.** Four of the defects above were found by a
person looking at a picture, after every assertion in the suite had gone green.
