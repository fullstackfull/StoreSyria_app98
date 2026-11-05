// P2.5-B-12, SLICE ONE -- the nine merchant-facing labels that could be translated TODAY.
//
// THE DEFECT. store_info_screen.dart, email_setting_screen.dart, profile_screen.dart and
// loyality_setting_screen.dart carry 87 hard-coded English strings between them, passed as
// `title:` / `labelText:` / `hint:` parameters that the receiving widget renders VERBATIM
// (common_appbar_widget.dart:11, app_txt_field.dart:11-12, product_widget.dart:459-460). They
// never reach GetX, so an Arabic merchant reads "Store Information", "Email Address", "Confirm
// Password" and "Save Changes" in English, and -- because EmptyState is a liveRegion whose
// visible Text is what gets announced -- a screen reader says them in English too.
//
// WHY THIS COMMIT CONVERTS NINE SITES AND NOT EIGHTY-SEVEN. `'some_key'.tr` on a key with no
// copy in the active map renders THE RAW IDENTIFIER (get-4.7.3 internacionalization.dart:96-111
// falls through to `return this`). So converting a site whose Arabic does not yet exist replaces
// readable English with `store_loyalty_program` -- strictly worse than the defect. 34 of the
// needed keys have no Arabic copy at all, and writing it is a CONTENT decision (SMTP transport
// jargon, loyalty-programme wording, a hard-coded "$1000"), not an engineering one. Those are in
// the copy deck at docs/development/phase-2.5/COPY-DECK-UNTRANSLATED-SCREENS.md, awaiting the
// owner. This file is the governing rule in executable form:
//
//     CONVERT A CALL SITE ONLY IF ITS KEY ALREADY HAS COPY IN BOTH en.dart AND ar.dart,
//     AND THE EXISTING ENGLISH VALUE IS BYTE-IDENTICAL TO THE LITERAL BEING REPLACED.
//
// THE SECOND CLAUSE IS NOT PEDANTRY -- it is what keeps this from being a silent copy change.
// Two candidates fail it and are deliberately left in English, each asserted below:
//   'Created At' vs en.dart's "Created at"   -- a case change
//   'Status:'    vs en.dart's "Status"       -- drops the colon
// Converting those would quietly re-word the English screen while "fixing" the Arabic one.
//
// KNOWN AND ACCEPTED: store_info_screen.dart:225 is a section HEADING 'Address' and :268 is a
// FIELD LABEL 'Address'. Both now render العنوان, so the Arabic screen repeats the word -- but the
// English screen already repeats "Address", so this is a faithful translation of existing copy,
// not a new defect. Re-wording belongs with the copy deck.
//
// THE LIMIT, STATED PLAINLY. AppTextField wires `Semantics(label: semanticLabel ?? title)`
// (app_txt_field.dart:184-186), so the profile and store-info fields converted here gain a real
// ANNOUNCED Arabic name. AddProductTextField has no Semantics at all and renders `Text(labelText!)`
// as a sibling (product_widget.dart:522), so the nine email fields and the loyalty field remain
// NAMELESS to a screen reader regardless of language; translating them would change the sentence
// beside the field, not the field's name. That is a separate repair.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/translation_service.dart';

const _ar = Locale('ar', 'AE');
const _en = Locale('en', 'US');

/// key -> the English literal it replaced, byte-for-byte.
const converted = <String, String>{
  'store_information': 'Store Information',
  'retry': 'Retry',
  'city': 'City',
  'address': 'Address',
  'email': 'Email Address',
  'confirm_password': 'Confirm Password',
  'close': 'Close',
};

/// file -> (key, how many call sites in that file now use it)
const sites = <String, Map<String, int>>{
  'lib/view/screen/setting_screen/store_info_screen.dart': {
    'store_information': 2, // :49 app bar, :116 section heading
    'retry': 1, // :77
    'city': 1, // :231
    'address': 2, // :225 section heading, :268 field label -- see the note above
  },
  'lib/view/screen/profile_screen/profile_screen.dart': {
    'email': 1, // :437
    'confirm_password': 1, // :517
  },
  'lib/view/screen/setting_screen/email_setting_screen.dart': {
    'close': 1, // :209
  },
};

String read(String path) => File(path).readAsStringSync();

void main() {
  setUp(() {
    Get.reset();
    Get.addTranslations(TranslationService().keys);
    Get.fallbackLocale = TranslationService.fallbackLocale;
  });

  tearDown(Get.reset);

  test('every converted key resolves to real Arabic, not to its own identifier', () {
    Get.locale = _ar;
    for (final entry in converted.entries) {
      final rendered = entry.key.tr;
      expect(rendered, isNot(entry.key),
          reason: '"${entry.key}" has no Arabic copy, so .tr renders the raw identifier -- '
              'which is worse than the English it replaced');
      expect(rendered, isNot(entry.value),
          reason: '"${entry.key}" renders the English "${entry.value}" under the ar locale');
      expect(RegExp(r'[؀-ۿ]').hasMatch(rendered), isTrue,
          reason: '"${entry.key}" renders "$rendered", which contains no Arabic letter');
    }
  });

  test('every converted key still renders the EXACT English it replaced', () {
    Get.locale = _en;
    for (final entry in converted.entries) {
      expect(entry.key.tr, entry.value,
          reason: 'converting this site changed what an English merchant sees: '
              '"${entry.value}" became "${entry.key.tr}"');
    }
  });

  test('every converted key is present in BOTH maps', () {
    final maps = TranslationService().keys;
    for (final key in converted.keys) {
      expect(maps['ar']!.containsKey(key), isTrue, reason: '"$key" missing from ar');
      expect(maps['en']!.containsKey(key), isTrue, reason: '"$key" missing from en');
    }
  });

  test('the call sites really were converted, and the English literals are gone', () {
    sites.forEach((path, keys) {
      final src = read(path);
      keys.forEach((key, count) {
        expect(RegExp("'$key'\\.tr").allMatches(src).length, count,
            reason: '$path should use \'$key\'.tr at $count site(s)');

        final literal = converted[key]!;
        // The English literal must no longer be passed as a parameter value. It may still appear
        // inside a comment, so only a `: 'Literal'` / `Text('Literal')` form counts.
        final asArgument = RegExp('''[:(]\\s*['"]${RegExp.escape(literal)}['"]''');
        expect(asArgument.hasMatch(src), isFalse,
            reason: '$path still passes the raw literal "$literal" as an argument');
      });
    });
  });

  // NEGATIVE CONTROL. The two near-misses stay in English ON PURPOSE, and this is the assertion
  // that stops a later tidier from "finishing the job" and silently re-wording the English UI.
  test('the two keys whose English does not match are deliberately NOT converted', () {
    final maps = TranslationService().keys;

    expect(maps['en']!['created_at'], 'Created at');
    expect(read('lib/view/screen/setting_screen/store_info_screen.dart').contains("'Created At'"),
        isTrue,
        reason: "store_info_screen still shows 'Created At'; converting it to created_at would "
            'change the English to "Created at" -- a copy change, not a translation');

    expect(maps['en']!['status'], 'Status');
    expect(read('lib/view/screen/setting_screen/loyality_setting_screen.dart').contains('Status:'),
        isTrue,
        reason: 'loyality_setting_screen still shows "Status:"; converting it to status would '
            'drop the colon from the English screen');
  });

  // NEGATIVE CONTROL. The governing rule rests on a claim about GetX. Prove it rather than
  // asserting it: an unknown key really does render as itself, in both locales.
  test('the premise: a key with no copy renders its own identifier', () {
    const orphan = 'a_key_that_does_not_exist_anywhere';
    for (final locale in [_ar, _en]) {
      Get.locale = locale;
      expect(orphan.tr, orphan,
          reason: 'if GetX did something else here -- threw, or fell back to English -- the rule '
              'this commit is built on would not be the real constraint');
    }
  });

  // NEGATIVE CONTROL. The rest of the finding is NOT fixed, and the suite should say so rather
  // than let a closed row imply a translated app. These counts are the remaining debt; they may
  // only ever go DOWN, and the copy deck is what unblocks them.
  test('the untranslated remainder is declared, not hidden', () {
    // MEASURED after slice one, not estimated. Before it: 35 / 23 / 14 / 4.
    const remaining = <String, int>{
      'lib/view/screen/setting_screen/store_info_screen.dart': 29,
      'lib/view/screen/setting_screen/email_setting_screen.dart': 22,
      'lib/view/screen/profile_screen/profile_screen.dart': 12,
      'lib/view/screen/setting_screen/loyality_setting_screen.dart': 4,
    };

    remaining.forEach((path, declared) {
      final src = read(path)
          .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
          .replaceAll(RegExp(r'//[^\n]*'), '');
      final hits = RegExp(
        '''(?:title|label|labelText|hint|hintText|message|text|subtitle)\\s*:\\s*'''
        '''(?:const\\s+)?(?:Text\\(\\s*)?['"][A-Z][^'"]*['"]''',
      ).allMatches(src).length;

      expect(hits, lessThanOrEqualTo(declared),
          reason: '$path now has $hits hard-coded English labels, declared $declared. If you '
              'translated more, LOWER the number. This set may only ever shrink.');
    });
  });
}
