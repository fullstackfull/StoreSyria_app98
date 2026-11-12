// THE ENGLISH SIDE OF A TRANSLATION FILE CAN BE A PLACEHOLDER AND LOOK FINE.
// =================================================================================================
//
// `lib/translations/en.dart` maps a key to the English text. When an entry is added as
// `'commission:': 'commission:'` the lookup succeeds, no test fails, and the merchant reads the KEY
// — lowercase, with its trailing punctuation — beside properly written labels. The Arabic side had
// been written (`'العمولة:'`), so the defect was visible only in English.
//
// Found by LOOKING at the English golden captures of the delivery-man card: the commission row read
// `commission: 0%` and its pill read `disabled`, both lowercase, next to a customer card whose pill
// read `Active`. Three entries were placeholders:
//
//     'commission:' -> 'commission:'     now 'Commission:'
//     'disabled'    -> "disabled"        now "Disabled"
//     'enabled'     -> "enabled"         now "Enabled"
//
// WHY THIS TEST IS SCOPED TO KEYS THAT ARE ACTUALLY USED. Two more entries have the same shape --
// `'by'` and `'password:'` -- and neither is referenced by any `.tr` call in `lib/`. They are dead
// entries, not visible defects, and failing on them would push the next author to either invent
// English for a string nobody renders or delete an entry this test had no business policing. If
// one of them is ever wired up, this test fires then, which is the right moment.
//
// A UNIT TEST reading source: no widgets pumped, no app booted.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // `'key': 'value',` with either quote style on either side.
  final entry = RegExp(r"""['"]([^'"]+)['"]\s*:\s*['"]([^'"]*)['"]\s*,""");

  test('no English string a screen renders is still its own lowercase key', () {
    final en = File('lib/translations/en.dart').readAsStringSync();
    final lib = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.contains('/translations/'))
        .map((f) => f.readAsStringSync())
        .join('\n');

    final placeholders = <String>[];

    for (final m in entry.allMatches(en)) {
      final key = m.group(1)!;
      final value = m.group(2)!;

      if (key != value) continue;
      // A properly-cased identity entry is fine: 'Active': 'Active' is real English.
      if (!RegExp(r'^[a-z]').hasMatch(key)) continue;
      // Only the ones a screen can actually render.
      if (!lib.contains("'$key'.tr") && !lib.contains('"$key".tr')) continue;

      placeholders.add(key);
    }

    expect(
      placeholders,
      isEmpty,
      reason: 'lib/translations/en.dart gives these keys their own lowercase text as the English '
          'translation, and a screen renders each one — so the merchant reads the key. Write the '
          'English, as `commission:`, `disabled` and `enabled` needed: $placeholders',
    );
  });

  test('premise: the parser and the usage scan both really find things', () {
    // Without this, an empty `placeholders` above could mean "the regex matched nothing" or
    // "lib/ was read as empty", and the assertion would pass for the wrong reason — the failure
    // mode this project has hit more than once.
    final en = File('lib/translations/en.dart').readAsStringSync();
    expect(entry.allMatches(en).length, greaterThan(500),
        reason: 'the entry regex no longer parses en.dart, so the guard above is vacuous');

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .length;
    expect(files, greaterThan(100),
        reason: 'the lib/ scan found almost no Dart files, so the "is it used" filter would '
            'exclude everything and the guard would pass whatever en.dart said');

    // And a known-good properly-cased entry must NOT be reported, or the filter is too wide.
    expect(en.contains("'Active'"), isTrue,
        reason: 'premise: en.dart still carries the properly-cased entries this guard must ignore');
  });
}
