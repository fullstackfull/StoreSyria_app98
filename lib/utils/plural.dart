// PLURAL SELECTION — because Arabic has six categories and this app had none.
// =================================================================================================
//
// WHAT WAS WRONG, AND IT IS A CORRECTNESS BUG IN ARABIC RATHER THAN A COPY PREFERENCE.
// Five screens printed a count as `'$n ${'items'.tr}'`, and `ar.dart` maps `items` to the bare
// SINGULAR `عنصر`. So the customers screen rendered `3 عنصر` and the products screen `2 عنصر`,
// measured off `customers-screen.light-rtl.png` and `products-screen.dark-rtl.png`.
//
// Arabic counted nouns (العدد والمعدود) do not work that way, and the DUAL is not optional:
//
//     0          لا عناصر         there are none
//     1          عنصر واحد        singular; the numeral is not written
//     2          عنصران           DUAL — a form English does not have at all
//     3 – 10     ٣ عناصر          plural of paucity (جمع قلة)
//     11 – 99    ١١ عنصرًا         singular in the accusative, with tanwīn (تمييز منصوب)
//     100 +      ١٠٠ عنصر         singular again
//
// One key cannot express that. Six can, and they are exactly Unicode CLDR's plural categories for
// Arabic — `zero`, `one`, `two`, `few`, `many`, `other` — whose boundaries are the grammar above.
//
// THERE WAS NO PLURALISATION PATH IN THIS APP TO REUSE, and that is stated as a measurement rather
// than an impression: `trPlural`, `Intl.plural` and the word `plural` appear in ZERO files under
// `lib/` and `test/`. GetX does ship `.trPlural(key, keyPlural, count)`, but it takes exactly TWO
// forms — a singular and a plural — so it cannot express the dual, let alone 11–99. Using it would
// have been a mechanism that looks like a fix and still prints `عنصران` as `عناصر`.
//
// SO THIS IS THE NARROW CASE, DELIBERATELY. It selects a category and resolves one key family. It
// is NOT a general i18n framework: there is no gender, no ordinal, no compact-number support and
// no message parser, and `{0}` is the only placeholder it understands. Every other counted string
// in the app still prints its own way. The general mechanism is absent, and this does not supply
// it — it supplies the rule for the strings that pass through here.

import 'package:get/get.dart';

/// Unicode CLDR plural categories.
///
/// The names are CLDR's, not invented here, so a translator who knows the standard can read the
/// key suffixes without being told what they mean.
enum PluralCategory { zero, one, two, few, many, other }

/// The CLDR category of [count] in [languageCode].
///
/// ARABIC, from CLDR's own rule set:
///   zero  n = 0
///   one   n = 1
///   two   n = 2
///   few   n % 100 = 3..10      so 103 is `few` and 3 is `few`
///   many  n % 100 = 11..99     so 111 is `many`
///   other everything else      100, 101, 102, 200 — note 101 is NOT `one`
///
/// EVERY OTHER LANGUAGE falls back to English's rule set, `one` for exactly 1 and `other` for the
/// rest, because English is this app's fallback locale (`TranslationService.fallbackLocale`) and a
/// language whose rules are unknown must not be given Arabic's.
PluralCategory pluralCategory(String languageCode, int count) {
  final n = count.abs();

  if (languageCode == 'ar') {
    if (n == 0) return PluralCategory.zero;
    if (n == 1) return PluralCategory.one;
    if (n == 2) return PluralCategory.two;

    final mod100 = n % 100;

    if (mod100 >= 3 && mod100 <= 10) return PluralCategory.few;
    if (mod100 >= 11 && mod100 <= 99) return PluralCategory.many;

    return PluralCategory.other;
  }

  return n == 1 ? PluralCategory.one : PluralCategory.other;
}

/// The language `.tr` is currently resolving against.
///
/// **It must be the same source `.tr` itself reads, or the two can disagree** — a category chosen
/// from one locale and copy fetched from another produces a grammatically-correct sentence in the
/// wrong language's rules, which is harder to spot than a missing translation. GetX's `.tr` reads
/// `Get.locale` and falls back to `Get.fallbackLocale`, so this does the same, in the same order.
String _activeLanguage() =>
    Get.locale?.languageCode ?? Get.fallbackLocale?.languageCode ?? 'en';

/// Looks [key] up, returning `null` when it is not translated.
///
/// **GetX returns THE KEY ITSELF when a translation is missing**, so `'items_count_two'.tr` is the
/// literal string `items_count_two` on a map that lacks it. That is exactly the failure
/// `test/localization/english_placeholder_strings_test.dart` exists for, and a resolver that did
/// not check for it would print a raw identifier to a merchant instead of falling back.
String? _translated(String key) {
  final value = key.tr;

  return value == key ? null : value;
}

/// The copy for [baseKey] at [count], with `{0}` replaced by the number.
///
/// Resolution order: `<baseKey>_<category>`, then `<baseKey>_other`, then the bare number. The
/// middle step is what lets a language supply fewer forms than Arabic without every call site
/// having to know which.
String trPluralCount(String baseKey, int count) {
  final category = pluralCategory(_activeLanguage(), count);
  final pattern = _translated('${baseKey}_${category.name}') ??
      _translated('${baseKey}_other');

  if (pattern == null) return '$count';

  return pattern.replaceAll('{0}', '$count');
}

/// `3 عناصر` · `عنصران` · `3 Items` — the list-count label under a section heading.
///
/// Used by the five screens that print how many rows they are showing. The digits stay Western, as
/// they are everywhere else in this app's numbers (prices, stock figures); only `DateFormat` emits
/// Arabic-Indic digits, and changing that convention is a wider decision than this one string.
String itemCountLabel(int count) => trPluralCount('items_count', count);
