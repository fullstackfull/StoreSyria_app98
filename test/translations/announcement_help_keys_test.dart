import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';

/// SUPPORT-002 — THE NEW COPY IS IN BOTH LANGUAGES, AND ITS PLACEHOLDERS MATCH.
/// ===========================================================================
///
/// GetX's `.tr` returns the KEY ITSELF when a translation is missing, so a key
/// in one map and not the other shows the merchant a raw identifier like
/// `help_surface_unknown` — in the language that is this app's DEFAULT and
/// FALLBACK. `translation_keys_test.dart` already refuses a one-sided key
/// anywhere in the app, so the first group here is belt over braces and cheap.
///
/// THE SECOND GROUP IS NOT COVERED ANYWHERE ELSE, and it is the one that can
/// really ship broken. `trParams` substitutes `@from` and `@until` by NAME: a
/// translation that spells one of them differently — or drops it — renders the
/// literal `@until` to the merchant, or silently loses the end of the
/// maintenance window. Nothing about that fails at build time and nothing in
/// this suite looked for it before.
///
/// SCOPED TO THIS SLICE'S KEYS DELIBERATELY. A census over all ~596 keys would
/// be the better instrument and is a separate change: it would be measuring
/// copy nobody in this slice wrote, and a ratchet whose first run reddens on
/// somebody else's drift gets suppressed rather than read.
void main() {
  // Every key SUPPORT-002 added. Listed by hand rather than derived, because a
  // list derived from one of the maps cannot notice a key missing from it.
  const keys = <String>[
    'announcements',
    'no_announcements',
    'announcements_failed',
    'notice',
    'urgent',
    'happening_now',
    'ended',
    'announcement_window',
    'announcement_window_until',
    'announcement_window_from',
    'help',
    'help_for_this_screen',
    'no_help_for_this_screen',
    'help_surface_unknown',
    'help_not_in_your_language',
    'help_failed',
  ];

  // key -> the placeholders `trParams` will be asked to substitute.
  const placeholders = <String, List<String>>{
    'announcement_window': ['@from', '@until'],
    'announcement_window_until': ['@until'],
    'announcement_window_from': ['@from'],
  };

  group('SUPPORT-002 copy exists in both languages', () {
    test('every key is declared in en.dart AND ar.dart', () {
      final missingEn = keys.where((k) => !en.containsKey(k)).toList();
      final missingAr = keys.where((k) => !ar.containsKey(k)).toList();

      expect(missingEn, isEmpty,
          reason: 'missing from en.dart, so `.tr` renders the raw key: '
              '$missingEn');
      expect(missingAr, isEmpty,
          reason: 'missing from ar.dart, so an Arabic merchant — this app\'s '
              'DEFAULT and FALLBACK locale — reads the raw key: $missingAr');
    });

    test('no value is blank, and no Arabic value is left as its English', () {
      for (final key in keys) {
        expect(en[key]!.trim(), isNotEmpty, reason: 'en.dart[$key] is blank');
        expect(ar[key]!.trim(), isNotEmpty, reason: 'ar.dart[$key] is blank');

        // A value identical in both maps is almost always a forgotten
        // translation. The window strings are the legitimate exception: they
        // are mostly punctuation and placeholders, so they are checked for
        // placeholder parity below instead.
        if (placeholders.containsKey(key)) continue;

        expect(ar[key], isNot(en[key]),
            reason: 'ar.dart[$key] is byte-identical to the English, which is '
                'what a forgotten translation looks like');
      }
    });
  });

  group('the window placeholders survive translation', () {
    test('both languages carry exactly the placeholders the screen passes', () {
      placeholders.forEach((key, expected) {
        for (final entry in {'en': en[key]!, 'ar': ar[key]!}.entries) {
          for (final token in expected) {
            expect(entry.value, contains(token),
                reason: '${entry.key}.dart[$key] does not contain $token, so '
                    'trParams substitutes nothing and the merchant reads a '
                    'window with a missing end');
          }
        }
      });
    });

    test('neither language carries a placeholder the screen does NOT pass', () {
      // The other direction, and the one that renders a literal `@until` on a
      // merchant's screen. `announcement_window_from` is the case: it is
      // reached only when `ends_at` is null, so an `@until` in it can never be
      // substituted.
      final pattern = RegExp(r'@[a-z_]+');

      placeholders.forEach((key, expected) {
        for (final entry in {'en': en[key]!, 'ar': ar[key]!}.entries) {
          final found = pattern
              .allMatches(entry.value)
              .map((m) => m.group(0)!)
              .toSet();

          expect(found.difference(expected.toSet()), isEmpty,
              reason: '${entry.key}.dart[$key] carries a placeholder the '
                  'screen never passes, so it renders literally: '
                  '${found.difference(expected.toSet())}');
        }
      });
    });
  });
}
