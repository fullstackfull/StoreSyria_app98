// Localization completeness — measured, not assumed.
//
// SCOPE NOTE. Visual redesign is explicitly out of scope, so this file does
// NOT change a single screen and does not touch RTL layout. It measures two
// things that silently degrade the Arabic build and locks the measurements in
// as a ratchet.
//
// WHAT WAS MEASURED when these baselines were taken, and RE-MEASURED this
// phase with this file's own `_declaredKeys` / `_usedKeys` helpers. Three of
// the five totals had drifted while the ratchet itself stayed intact, so they
// are corrected here rather than left to be quoted:
//
//                                             then    now
//   en.dart                                    640    646
//   ar.dart                                    642    648
//   distinct literal `.tr` keys used in lib/    523    527
//   used but defined in NEITHER map              47     47
//   defined on one side only                      2      2
//
// The gap did not grow: both baselines below are exactly as large as they
// were, and the two one-sided keys are still `add_delivery_men` and
// `price_label`. Ten keys of copy were added and four new `.tr` sites landed,
// all of them translated -- which is the ratchet working, not slipping.
//
// GetX's `.tr` returns the KEY ITSELF when a translation is missing, so each of
// those 47 keys shows the merchant a raw identifier like `cost_price`, or an
// untranslated English fragment like `Please fill all field`, in BOTH languages.
// It is not a crash and it is not a security problem, which is why it is a
// ratchet rather than a hard failure: filling the gap needs real Arabic and
// English copy, which is the owner's to approve, not something to invent in a
// security pass.
//
// HOW THE RATCHET WORKS. The baselines below are the gap as it stood. These
// tests fail if the gap GROWS -- a newly added `.tr` key with no translation,
// or a key added to one map and not the other. They do not fail on the
// existing gap. As copy is supplied, delete entries from the baselines; the
// tests then hold the smaller gap. Do not add to these lists to make a test
// pass.
//
// ALSO MEASURED, and reported rather than changed:
//   * `flutter_localizations` is declared in pubspec.yaml but GetMaterialApp
//     (lib/store_go.dart) sets neither `localizationsDelegates` nor
//     `supportedLocales`, so the Material/Cupertino/Widgets delegates are
//     never installed. Framework-supplied strings stay English and
//     `Directionality` resolves LTR from DefaultWidgetsLocalizations.
//   * RTL is handled ad hoc instead: four screens wrap themselves in
//     `Directionality` and six places force `TextDirection.ltr`.
//   Wiring the delegates in would mirror every screen in Arabic at once. That
//   is a visual change across the whole app, so it belongs to a UI pass with
//   the owner, not here.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

/// Keys used via `.tr` that are defined in NEITHER en.dart nor ar.dart.
/// This list may only ever shrink.
const Set<String> knownUntranslatedKeys = <String>{
    'Add attachment...',
    'Charges Type',
    'Discount',
    'Enter Description',
    'Enter Return Order Duration',
    'Last 7 days',
    'Most visited links',
    'Name',
    'No data',
    'No_payment_methods_available',
    'Other',
    'Overview',
    'Page views over the selected period',
    'Please fill all field',
    'Return Order Duration',
    'Top links',
    'Total page views',
    'Unique visitors',
    'change2',
    'confirm',
    'cost_price',
    'enter_name',
    'enter_product_weight',
    'enter_shipping_id',
    'enter_tax_id',
    'failed_to_create_order',
    'final_price',
    'invalid_price',
    'invalid_product_weight',
    'invalid_url',
    'leave_empty_to_keep_current_password',
    'no_currencies_found',
    'no_delivery_boy_name',
    'not trending',
    'order_created_successfully',
    'order_id_copied',
    'payment',
    'please_enter_amount',
    'pricing',
    'product_settings',
    'search_failed',
    'shipping_and_tax',
    'shipping_id',
    'stock_status',
    'tax_id',
    'tax_status',
    'track_stock',
};

/// Keys defined in one translation map but not the other.
/// This list may only ever shrink.
const Set<String> knownOneSidedKeys = <String>{
    'add_delivery_men',
    'price_label',
};

Set<String> _declaredKeys(String path) {
  final source = File('${packageRoot().path}/$path').readAsStringSync();

  return RegExp(r'''^\s*['"]([^'"]+)['"]\s*:''', multiLine: true)
      .allMatches(source)
      .map((m) => m.group(1)!)
      .toSet();
}

Set<String> _usedKeys() {
  // Literal `.tr` call sites only. A key built at runtime cannot be checked
  // statically, and there is no point pretending otherwise.
  final pattern = RegExp(r'''['"]([a-zA-Z0-9_. ]+)['"]\s*\.tr\b''');
  final used = <String>{};

  for (final file in libDartFiles()) {
    for (final m in pattern.allMatches(file.readAsStringSync())) {
      used.add(m.group(1)!);
    }
  }

  return used;
}

void main() {
  late Set<String> en;
  late Set<String> ar;

  setUpAll(() {
    en = _declaredKeys('lib/translations/en.dart');
    ar = _declaredKeys('lib/translations/ar.dart');
  });

  group('translation completeness', () {
    test('both maps parse and are substantial', () {
      // Guards against a regex that silently matches nothing, which would make
      // every assertion below vacuously true.
      expect(en.length, greaterThan(500));
      expect(ar.length, greaterThan(500));
    });

    test('no NEW key is defined in only one language', () {
      final oneSided = en.difference(ar).union(ar.difference(en));
      final unexpected = oneSided.difference(knownOneSidedKeys).toList()..sort();

      expect(
        unexpected,
        isEmpty,
        reason:
            'These keys exist in one translation map but not the other. Add '
            'them to both (do NOT add them to knownOneSidedKeys):\n'
            '${unexpected.join('\n')}',
      );
    });

    test('no NEW .tr key is left without a translation', () {
      final used = _usedKeys();

      final missing = used
          .where((k) => !en.contains(k) || !ar.contains(k))
          .toSet()
          .difference(knownUntranslatedKeys)
          .toList()
        ..sort();

      expect(
        missing,
        isEmpty,
        reason:
            'These keys are used via .tr but are not defined in en.dart '
            'and/or ar.dart, so GetX will render the raw key to the merchant. '
            'Add the copy to both maps (do NOT add them to '
            'knownUntranslatedKeys):\n${missing.join('\n')}',
      );
    });

    test('the baselines are not stale', () {
      // When copy is supplied, the baseline entry must be deleted too --
      // otherwise the ratchet stops ratcheting.
      final used = _usedKeys();

      final fixed = knownUntranslatedKeys
          .where((k) => en.contains(k) && ar.contains(k))
          .toList()
        ..sort();

      expect(
        fixed,
        isEmpty,
        reason:
            'These keys now have translations and must be removed from '
            'knownUntranslatedKeys so the ratchet keeps its grip:\n'
            '${fixed.join('\n')}',
      );

      final noLongerUsed = knownUntranslatedKeys
          .where((k) => !used.contains(k))
          .toList()
        ..sort();

      expect(
        noLongerUsed,
        isEmpty,
        reason:
            'These keys are no longer used via .tr and must be removed from '
            'knownUntranslatedKeys:\n${noLongerUsed.join('\n')}',
      );
    });

    test('the error messages the network layer needs exist in both maps', () {
      // These are not cosmetic: without them a throttled or logged-out
      // merchant is shown a raw identifier instead of an explanation.
      for (final key in <String>[
        'too_many_requests',
        'too_many_requests_retry_after',
        'session_expired',
        'invalid_server_response',
        'connection_failed',
        'request_timeout',
        'no_internet_connection',
        'server_internal_error',
        'resource_not_found',
        'unexpected_error',
      ]) {
        expect(en, contains(key), reason: '$key missing from en.dart');
        expect(ar, contains(key), reason: '$key missing from ar.dart');
      }
    });
  });
}
