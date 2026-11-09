# Copy deck — the untranslated merchant screens (Phase 2.5, P2.5-B-12 slice two)

> ## RESOLVED — 2026-11-09
>
> The owner authorised the copy in the Phase 2.5 final directive and it is written. **All 68
> unique strings across the five screens below are translated**, at 76 call sites, and the keys
> are in `lib/translations/ar.dart` and `en.dart`.
>
> Terminology follows the Laravel side's `resources/lang/ar.json` wherever that file already had
> the term — Email, Mobile, City, Country, Zipcode, Full Name, Save Changes, Password — so the two
> surfaces say the same word for the same thing.
>
> **`State` is the one entry where both surfaces had to move.** `ar.json` carried `الدولة`, which
> means *country* and collides with `البلد`, so an Arabic merchant saw two differently-labelled
> address fields meaning the same thing. Both now use **`المحافظة`**, the Syrian administrative
> term, guarded by `tests/Unit/Localisation/AddressTerminologyTest.php` in the Laravel repository.
>
> Three rows below were already translated by the time the copy was written — this deck was
> slightly stale on `Store Email Setting`, `Send Test Mail` and `Store Loyalty Program` — and their
> established values were kept rather than replaced.
>
> Verified in the rendered UI, not only in the files: see §"What the merchant currently sees".
> `Store information` is now **REDESIGNED AND VERIFIED** in the coverage matrix.
>
> The table below is kept as the record of what was asked for and what it was asked against.

**This was a request for Arabic copy, not an engineering task.** Slice one is shipped: the
nine labels whose Arabic already existed now render in Arabic. The strings below have **no
Arabic copy anywhere in `lib/translations/ar.dart`**, and they cannot be converted without it.

## Why these were not just translated

`'some_key'.tr` renders **the raw identifier** when the key is absent from the active map
(GetX `internacionalization.dart:96-111` falls through to `return this`). So converting a site
whose Arabic does not exist replaces a readable English label with `store_loyalty_program`.
That is worse than the defect it would be closing, which is why this deck exists instead of a
bigger diff. Each string is quoted **verbatim from source**, including punctuation, so the
Arabic can be written against what the merchant actually sees.

## What is needed

One Arabic string per row. Keep the English column as-is — it is the current UI text.

## What the merchant currently sees (added 2026-11-09)

Until now this deck listed strings. There are now **captures of the screens they are on**, taken
through the Phase 2.5 screen harness, so the Arabic can be written against the real layout rather
than against a table of line numbers:

`syriastore98/docs/development/phase-2.5/evidence/flutter-store-settings-2026-11-09/after/`

* `flutter-store-info_ar_rtl_light.png` / `_ar_rtl_dark.png` — the Arabic build of Store
  Information. The section heading reads **معلومات المتجر** and every field label under it reads
  **Store Name**, **Email**, **Store URL**, **Created At**, **Owner Information**, **Owner Name**,
  **Owner Email**. That mix is what the deck is asking to fix.
* `flutter-language-currency_ar_rtl_*.png` — for contrast, the sibling screen with its Arabic
  complete: **لغة المتجر والعملات**, **اللغات**, **العملات**, **أسعار الصرف**. Nothing on it is in
  this deck.

**Consequence for the coverage matrix:** `Store information` is held at **PENDING** for this
reason, with its four captures already taken and sitting beside the language screen's. It is not
waiting on engineering or on evidence — only on the Arabic in the empty column above. The moment
that column is filled it can be converted and promoted in one small change.


### Store Information

`store_info_screen.dart`

| line | parameter | English, verbatim | Arabic needed |
|---|---|---|---|
| 82 | `message:` | `No store information available` | |
| 130 | `title:` | `Store Name` | |
| 131 | `hint:` | `Enter store name` | |
| 142 | `title:` | `Email` | |
| 143 | `hint:` | `Enter store email` | |
| 156 | `title:` | `Store URL` | |
| 157 | `hint:` | `Enter store URL` | |
| 170 | `title:` | `Created At` | |
| 171 | `hint:` | `Created at` | |
| 186 | `title:` | `Owner Information` | |
| 190 | `title:` | `Owner Name` | |
| 191 | `hint:` | `Enter owner name` | |
| 202 | `title:` | `Owner Email` | |
| 203 | `hint:` | `Enter owner email` | |
| 216 | `title:` | `Mobile` | |
| 217 | `hint:` | `Enter mobile number` | |
| 242 | `hint:` | `Enter city` | |
| 254 | `title:` | `Country` | |
| 255 | `hint:` | `Enter country` | |
| 266 | `title:` | `State` | |
| 267 | `hint:` | `Enter state` | |
| 279 | `hint:` | `Enter store address` | |
| 290 | `title:` | `Zipcode` | |
| 291 | `hint:` | `Enter zipcode` | |
| 304 | `title:` | `Full Address` | |
| 305 | `hint:` | `Full address` | |
| 330 | `title:` | `Media` | |
| 336 | `title:` | `Invoice Logo` | |
| 349 | `title:` | `Store Image` | |

### Store Email Setting

`email_setting_screen.dart`

| line | parameter | English, verbatim | Arabic needed |
|---|---|---|---|
| 47 | `title:` | `Store Email Setting` | |
| 62 | `labelText:` | `Mail Driver:` | |
| 63 | `hintText:` | `Enter Mail Driver` | |
| 72 | `labelText:` | `Mail Host:` | |
| 73 | `hintText:` | `Mail Driver` | |
| 83 | `labelText:` | `Mail Port:` | |
| 84 | `hintText:` | `Enter Mail Driver` | |
| 93 | `labelText:` | `Mail Username:` | |
| 94 | `hintText:` | `Enter Mail Driver` | |
| 104 | `labelText:` | `Mail Password:` | |
| 105 | `hintText:` | `Enter Password` | |
| 114 | `labelText:` | `Mail Encryption:` | |
| 115 | `hintText:` | `Enter Encryption` | |
| 124 | `labelText:` | `Mail From Address:` | |
| 125 | `hintText:` | `Enter From Address` | |
| 135 | `labelText:` | `Mail From Name:` | |
| 136 | `hintText:` | `Enter Mail Driver` | |
| 148 | `title:` | `Send Test Mail` | |
| 195 | `labelText:` | `Email:` | |
| 196 | `hintText:` | `Enter Email` | |
| 223 | `title:` | `Send` | |
| 252 | `title:` | `Save changes` | |

### My Account / Profile

`profile_screen.dart`

| line | parameter | English, verbatim | Arabic needed |
|---|---|---|---|
| 57 | `title:` | `My Account` | |
| 421 | `title:` | `Account Information` | |
| 422 | `subtitle:` | `Update your personal information` | |
| 429 | `title:` | `Full Name` | |
| 430 | `hint:` | `Enter name` | |
| 438 | `hint:` | `Enter email` | |
| 446 | `text:` | `Save Changes` | |
| 475 | `title:` | `Security` | |
| 476 | `subtitle:` | `Keep your account password secure` | |
| 483 | `title:` | `Current Password` | |
| 500 | `title:` | `New Password` | |
| 538 | `text:` | `Update Password` | |

### Store Loyalty Program

`loyality_setting_screen.dart`

| line | parameter | English, verbatim | Arabic needed |
|---|---|---|---|
| 49 | `title:` | `Store Loyalty Program` | |
| 87 | `labelText:` | `Reward points on orders of \$1000` | |
| 88 | `hintText:` | `Enter reward` | |
| 96 | `title:` | `Save changes` | |

### Social media block (shared)

`social_widget.dart`

| line | parameter | English, verbatim | Arabic needed |
|---|---|---|---|
| 91 | `hint:` | `Facebook link` | |
| 107 | `hint:` | `Twitter / X link` | |
| 123 | `hint:` | `Instagram link` | |
| 139 | `hint:` | `WhatsApp link` | |
| 155 | `hint:` | `Telegram link` | |

## Three of these are decisions, not translations

1. **`Reward points on orders of $1000`** (`loyality_setting_screen.dart`) hard-codes a
   currency amount into the label, while the API carries a bare `reward_point`. Translating the
   sentence preserves the hard-coded `$1000`. Should the amount come from the API, and should
   the currency follow the store's?
2. **The nine `Mail *:` labels** are SMTP transport jargon (`Mail Driver`, `Mail Encryption`,
   `Mail From Address`) on a form that writes live mail credentials. They may be better left in
   English than translated loosely — mistranslated SMTP fields produce a silently broken mail
   configuration. Owner's call.
3. **`WhatsApp`** — `ar.dart:616` already carries a transliteration. The other four brand names
   (Facebook, Twitter / X, Instagram, Telegram) are deliberately left as Latin brand marks; if
   WhatsApp should match them, the existing transliteration should go.

## Casing and punctuation inconsistencies to settle while you are here

These are pre-existing English inconsistencies. They are *not* bugs, but the Arabic will
inherit whatever is chosen, so it is cheaper to settle them now than to re-translate later.

| where | current English | note |
|---|---|---|
| `store_info_screen.dart` | `Created At` | `en.dart` already has the key `created_at` = "Created**a**t" (lower-case *a*). Converting would silently re-word the English screen, so it was left alone. |
| `loyality_setting_screen.dart` | `Status:` | `en.dart` has `status` = "Status" with **no colon**. Same reason. |
| `email_setting_screen.dart` vs `profile_screen.dart` | `Save changes` vs `Save Changes` | the same button, two casings, on two screens. |
| `store_info_screen.dart` | `Saving...` | ellipsis as three dots; Arabic convention may differ. |
| `store_info_screen.dart` | `Address` (×2) | one is a section heading, one a field label. Slice one translated both, so the Arabic screen repeats the word — as the English one already does. Re-word if that reads badly. |

## One limitation this copy will not fix

`AppTextField` wires `Semantics(label: semanticLabel ?? title)`, so the **profile** and
**store info** fields gain a real announced Arabic name. `AddProductTextField` has no
`Semantics` at all and renders `Text(labelText!)` as a sibling, so the nine **email** fields and
the **loyalty** field stay nameless to a screen reader whatever language they are in.
Translating them changes the sentence beside the field, not the field's name. That is a
separate repair, already tracked.
