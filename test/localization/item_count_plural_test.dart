// P06-WS8-I18N — the list-count label, which printed the Arabic SINGULAR at every count.
// =================================================================================================
//
// FOUND BY READING A RENDERED SCREEN, not the source. `customers-screen.light-rtl.png` prints
// `3 عنصر` and `products-screen.dark-rtl.png` prints `2 عنصر`. Five screens built that label as
// `'$n ${'items'.tr}'`, and `ar.dart` maps `items` to the bare singular `عنصر`.
//
// THIS IS A GRAMMAR ERROR, NOT A COPY PREFERENCE. Arabic counted nouns take six forms and the
// DUAL is obligatory — `2 عنصر` is not a stylistic choice, it is wrong:
//
//     0          لا عناصر
//     1          عنصر واحد      the numeral is not written
//     2          عنصران         DUAL — English has no equivalent
//     3 – 10     ٣ عناصر        جمع قلة
//     11 – 99    ١١ عنصرًا       تمييز منصوب: singular, accusative, with tanwīn
//     100 +      ١٠٠ عنصر       singular again
//
// Those boundaries are exactly Unicode CLDR's `zero / one / two / few / many / other` for Arabic,
// which is why the key suffixes use CLDR's names.
//
// THERE WAS NO PLURALISATION PATH TO REUSE, measured rather than assumed: `trPlural`,
// `Intl.plural` and the word `plural` appear in ZERO files under `lib/` and `test/`. GetX ships
// `.trPlural(key, keyPlural, count)`, but it takes exactly TWO forms, so it cannot express the
// dual or the 11–99 accusative — it would have been a mechanism that looks like a fix and still
// prints `عنصران` as `عناصر`. **So the general mechanism is absent and this does not supply it:**
// `lib/utils/plural.dart` selects a category and resolves one key family, with no gender, no
// ordinals, no compact numbers and `{0}` as its only placeholder.
//
// WHY ENGLISH CARRIES ALL SIX KEYS when it has two forms: `translation_keys_test.dart` fails any
// key defined on one side only, and that invariant is not weakened for this. `pluralCategory()`
// never returns `two`, `few`, `many` or `zero` for English, so those four are unreachable copy
// that exists to keep the maps symmetrical — asserted below so they cannot rot into junk.
//
// `items` ITSELF IS UNTOUCHED in both maps. Another workstream owns those files; this change only
// APPENDS, and the old key stays exactly as it was.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/utils/plural.dart';
import 'package:store_go_app/view/new_widgets/date_filter.dart';

import '../support/golden_harness.dart';
import '../support/source_tree.dart';

/// Every category a key family must supply for Arabic.
const _categories = <String>['zero', 'one', 'two', 'few', 'many', 'other'];

void main() {
  setUpAll(loadAppFonts);
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  group('the CLDR category boundaries for Arabic', () {
    // Each of these is a boundary, not a sample: the pairs straddle the point where the grammar
    // changes, which is where an off-by-one in a rule set actually lands.
    const expectations = <int, PluralCategory>{
      0: PluralCategory.zero,
      1: PluralCategory.one,
      2: PluralCategory.two,
      3: PluralCategory.few,
      10: PluralCategory.few,
      11: PluralCategory.many,
      99: PluralCategory.many,
      100: PluralCategory.other,
      // 101 IS NOT `one` AND 102 IS NOT `two`. CLDR's `one` and `two` are the exact integers 1 and
      // 2, while `few` and `many` are modulo 100 — a rule set written from the plain-language
      // summary "1 is singular, 2 is dual" gets these three wrong and nothing else catches it.
      101: PluralCategory.other,
      102: PluralCategory.other,
      103: PluralCategory.few,
      110: PluralCategory.few,
      111: PluralCategory.many,
      200: PluralCategory.other,
      203: PluralCategory.few,
    };

    expectations.forEach((count, category) {
      test('$count is ${category.name}', () {
        expect(pluralCategory('ar', count), category);
      });
    });
  });

  group('every other language falls back to English\'s two forms', () {
    test('English is one for 1 and other for everything else', () {
      expect(pluralCategory('en', 1), PluralCategory.one);
      for (final n in <int>[0, 2, 3, 11, 100, 101]) {
        expect(pluralCategory('en', n), PluralCategory.other,
            reason: 'English has two grammatical forms; $n must take the plural');
      }
    });

    test('an unknown language is not given Arabic\'s rules', () {
      // The failure this prevents is subtle: a third locale added later would silently inherit a
      // dual and a 11–99 accusative it does not have.
      expect(pluralCategory('fr', 2), PluralCategory.other);
      expect(pluralCategory('tr', 11), PluralCategory.other);
    });
  });

  group('the copy exists on both sides, and is not a placeholder', () {
    for (final category in _categories) {
      test('items_count_$category is defined in both maps', () {
        final key = 'items_count_$category';

        expect(ar.containsKey(key), isTrue, reason: '$key is missing from ar.dart');
        expect(en.containsKey(key), isTrue, reason: '$key is missing from en.dart');
        expect(ar[key], isNot(key),
            reason: '$key is its own key text in ar.dart, which GetX renders raw to the merchant');
        expect(en[key], isNot(key), reason: '$key is its own key text in en.dart');
      });
    }

    test('the Arabic forms are six DIFFERENT strings', () {
      // The whole point is that Arabic distinguishes them. Six keys all carrying `{0} عنصر` would
      // satisfy every other assertion here and change nothing a merchant reads.
      final forms = _categories.map((c) => ar['items_count_$c']).toSet();

      expect(forms, hasLength(6),
          reason: 'two or more Arabic plural forms are identical, so the dual or the 11–99 '
              'accusative has been lost: ${_categories.map((c) => ar['items_count_$c']).toList()}');
    });

    test('the dual and the singular do not carry the numeral, and the rest do', () {
      // `2 عنصران` and `1 عنصر واحد` are both wrong: Arabic does not write the numeral beside its
      // own dual or its singular. The other four forms must carry `{0}` or the count disappears.
      expect(ar['items_count_one'], isNot(contains('{0}')));
      expect(ar['items_count_two'], isNot(contains('{0}')));
      expect(ar['items_count_zero'], isNot(contains('{0}')));

      for (final c in <String>['few', 'many', 'other']) {
        expect(ar['items_count_$c'], contains('{0}'),
            reason: 'the Arabic `$c` form drops the number entirely');
      }
    });

    test('the four English forms English never selects are still English', () {
      // They exist only because translation_keys_test.dart requires both maps to hold the same
      // keys. Unreachable copy rots, so it is pinned rather than left to drift into a placeholder.
      for (final c in <String>['zero', 'two', 'few', 'many']) {
        expect(en['items_count_$c'], '{0} Items',
            reason: 'en items_count_$c is unreachable through pluralCategory("en", n) and must '
                'simply be the English plural');
      }
      expect(en['items_count_one'], '{0} Item');
      expect(en['items_count_other'], '{0} Items');
    });
  });

  group('what a merchant actually reads, rendered through the real widget', () {
    /// The label is built inside `sectionHeaderWithFilterWidget`, which is the single widget all
    /// five screens pass their count to. Pumping it rather than calling `itemCountLabel` directly
    /// is what proves the locale plumbing agrees: `goldenHost` sets the app's own locale on a
    /// `GetMaterialApp`, which is the same thing `.tr` reads at runtime.
    Future<void> pumpCount(WidgetTester tester, int count, {required bool arabic}) async {
      pinGoldenSurface(tester);

      await tester.pumpWidget(goldenHost(
        dark: false,
        direction: arabic ? TextDirection.rtl : TextDirection.ltr,
        child: Builder(
          builder: (context) => sectionHeaderWithFilterWidget(
            context: context,
            num: count,
            isFilter: false,
            title: 'Heading',
            filterLabel: '',
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    const arabicExpectations = <int, String>{
      0: 'لا عناصر',
      1: 'عنصر واحد',
      2: 'عنصران',
      3: '3 عناصر',
      10: '10 عناصر',
      11: '11 عنصرًا',
      100: '100 عنصر',
    };

    arabicExpectations.forEach((count, text) {
      testWidgets('Arabic, $count rows, reads "$text"', (tester) async {
        await pumpCount(tester, count, arabic: true);

        expect(find.text(text), findsOneWidget,
            reason: 'the Arabic count label for $count is wrong. Before this change every count '
                'printed the bare singular `\$n عنصر`, which is what the rendered screen captures '
                'showed');
      });
    });

    const englishExpectations = <int, String>{
      0: '0 Items',
      1: '1 Item',
      2: '2 Items',
      11: '11 Items',
    };

    englishExpectations.forEach((count, text) {
      testWidgets('English, $count rows, reads "$text"', (tester) async {
        await pumpCount(tester, count, arabic: false);

        expect(find.text(text), findsOneWidget);
      });
    });
  });

  test('no screen builds a count label by concatenating the bare `items` key', () {
    // THE GUARD AGAINST THE DEFECT COMING BACK ONE SCREEN AT A TIME. Five call sites shared this
    // shape and every one of them was wrong in Arabic; a sixth written the same way would be
    // wrong too, and nothing else in the suite would notice, because no test asserted this copy
    // before today. `items` is deliberately still in both maps — the rule is about building a
    // COUNT from it, not about the key existing.
    final offenders = <String>[];

    // THE SHAPE, NOT THE KEY. `items` stays in both maps and a standalone `Text('items'.tr)` is a
    // perfectly good column heading; what is wrong is INTERPOLATING it after a number, which is
    // the count label and is the Arabic singular at every count except 1. So the pattern is the
    // key inside a `${...}` interpolation, which is exactly how all five call sites were written.
    for (final file in libDartFiles()) {
      final source = commentsStripped(file.readAsStringSync());

      for (final line in matchingLines(source, RegExp(r"\$\{'items'\.tr\}"))) {
        offenders.add('${relative(file)}:$line');
      }
    }

    expect(offenders..sort(), isEmpty,
        reason: 'these lines interpolate the bare `items` key into a count label, which is the '
            'Arabic SINGULAR and is wrong at every count except 1. Use `itemCountLabel(n)` from '
            'lib/utils/plural.dart. ${offenders.join(', ')}');
  });
}
