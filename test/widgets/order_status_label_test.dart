// P2-07-6 -- the app does not say "unknown" about a status the database knows.
//
// THREE DEFECTS, ALL IN `StatusBadgeHelper`, all presentational and none of
// them needing an API change:
//
//   1. `getOrderLabel` handles 0..6 and falls through to `'unknown'.tr` for
//      **7 (Partially Paid) and 8 (Pre Order)**. Those two values are real and
//      live: `orders.delivered_status` carries nine values, and 7 and 8 sit in
//      the same column while not being fulfilment states at all (ledger F0).
//      The web dashboard was given an honesty pass that names them; the app
//      said "unknown", which is worse than saying nothing -- it tells a
//      merchant the app cannot read their own order.
//
//   2. `'unknown'` HAS NO TRANSLATION KEY in either `en.dart` or `ar.dart`.
//      GetX returns the key itself when a lookup misses, so the badge rendered
//      the literal lowercase string `unknown` in both languages.
//
//   3. `getOrderLabel(2)` asks for `'cancel'`, but the status key in `en.dart`
//      is `'cancelled'`. So in English the badge read the literal `cancel`,
//      and in Arabic `'cancel'` resolves to "إلغاء" -- the VERB on a button,
//      not the state of an order. The same wrong-sense class of bug as the
//      web's "Stock" rendering as "الأسهم" (financial shares).
//
// WHY THE LABELS ARE NOT ASSERTED AS ENGLISH LITERALS: the point is not that a
// particular word appears, it is that the KEY RESOLVES. A test comparing
// `getOrderLabel(2)` to `'Cancelled'` would pass just as well if somebody
// hardcoded the English and deleted the lookup. Asserting that the result does
// NOT still look like a key is what catches a miss, because GetX hands back
// the key -- and every key in this app is lower_snake_case while every value
// is human text.
//
// The real translation maps are registered rather than stubs, for the same
// reason: a stub would prove the helper asks for *a* key, not that the key
// exists in the files that ship.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/new_widgets/order_status_badge.dart';

/// Every `delivered_status` value the host writes. Nine, not seven.
///
/// Read from the host's own `OrderDataTable` status map and `HomeController`'s
/// status constants, which both enumerate 0..8.
const _allStatuses = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8];

final _arabic = RegExp(r'[؀-ۿ]');

/// A string that still looks like one of this app's translation keys.
final _looksLikeAKey = RegExp(r'^[a-z0-9_.]+$');

void main() {
  setUp(() {
    // The language codes `TranslationService.keys` actually uses.
    Get.addTranslations({'en': en, 'ar': ar});
  });

  tearDown(() {
    Get.locale = const Locale('ar', 'AE');
  });

  group('every live status resolves to a real label', () {
    for (final status in _allStatuses) {
      test('status $status has a translated label in English', () {
        Get.locale = const Locale('en', 'US');
        final label = StatusBadgeHelper.getOrderLabel(status);

        expect(label.trim(), isNotEmpty,
            reason: 'status $status produced an empty label');

        expect(
          label,
          isNot(matches(_looksLikeAKey)),
          reason: 'status $status rendered the raw translation key "$label" '
              'instead of a label -- the key is missing from en.dart, so a '
              'merchant sees this string verbatim',
        );

        expect(
          label.toLowerCase(),
          isNot('unknown'),
          reason: 'status $status rendered "unknown". orders.delivered_status '
              'carries nine values and the database knows what this one is; '
              'telling the merchant the app does not is worse than silence',
        );
      });

      test('status $status has an Arabic label in Arabic', () {
        Get.locale = const Locale('ar', 'AE');
        final label = StatusBadgeHelper.getOrderLabel(status);

        expect(label.trim(), isNotEmpty);
        expect(label, isNot(matches(_looksLikeAKey)),
            reason: 'status $status rendered the raw key "$label" in Arabic');

        // A missing ar.dart key falls back to the English map or to the key,
        // and both are Latin script -- which is how an untranslated status
        // reaches an Arabic merchant looking perfectly fine to a reviewer.
        expect(
          _arabic.hasMatch(label),
          isTrue,
          reason: 'status $status rendered "$label" in the Arabic locale, '
              'which contains no Arabic characters at all',
        );
      });
    }
  });

  /// STATUS 2 USES THE STATE KEY, NOT THE ACTION KEY.
  ///
  /// This case exists because the bite test did NOT catch it. Reverting
  /// `'cancelled'` to `'cancel'` left every other case green, because both
  /// keys exist and both resolve to a real word -- so the "does it still look
  /// like a key" check cannot tell them apart. They mean different things:
  /// `'cancelled'` is the STATE of an order ("Cancelled" / "ملغى") and
  /// `'cancel'` is the word on a BUTTON ("Cancel" / "إلغاء").
  ///
  /// Compared against the map's own value rather than an English literal, so
  /// the test does not also have to be updated when the wording is improved --
  /// only when the KEY changes, which is the thing being pinned.
  test('a cancelled order is described by its state, not by the action', () {
    Get.locale = const Locale('en', 'US');
    expect(StatusBadgeHelper.getOrderLabel(2), en['cancelled'],
        reason: 'status 2 resolved "\${StatusBadgeHelper.getOrderLabel(2)}". If that is '
            'en["cancel"] it is the button label, not the order state');

    Get.locale = const Locale('ar', 'AE');
    expect(StatusBadgeHelper.getOrderLabel(2), ar['cancelled'],
        reason: 'status 2 must be "ملغى" (the state), not "إلغاء" (the action)');
  });

  /// And the same shape for the rest, so a key swap anywhere is caught.
  test('every status label is the value of the key it is meant to use', () {
    Get.locale = const Locale('en', 'US');

    const expected = <int, String>{
      0: 'pending',
      1: 'delivered',
      2: 'cancelled',
      3: 'return',
      4: 'confirmed',
      5: 'picked_up',
      6: 'shipped',
      7: 'partially_paid',
      8: 'pre_order',
    };

    // PREMISE: every key named above is actually in the English map. Otherwise
    // a typo here makes the comparison `null == null` for a missing key and
    // the assertion passes against a label the app never shows.
    for (final key in expected.values) {
      expect(en[key], isNotNull,
          reason: 'the key "\$key" named by this test is not in en.dart');
    }

    for (final entry in expected.entries) {
      expect(StatusBadgeHelper.getOrderLabel(entry.key), en[entry.value],
          reason: 'status \${entry.key} does not resolve en["\${entry.value}"]');
    }
  });

  test('the two non-fulfilment values are named, not hidden', () {
    Get.locale = const Locale('en', 'US');

    // 7 and 8 are not fulfilment states -- a payment state and an order type
    // sharing the column (ledger F0). Naming them is the honesty pass;
    // splitting the column is Phase 04 and an owner decision.
    expect(StatusBadgeHelper.getOrderLabel(7).toLowerCase(), contains('paid'),
        reason: 'status 7 is Partially Paid');
    expect(StatusBadgeHelper.getOrderLabel(8).toLowerCase(), contains('order'),
        reason: 'status 8 is Pre Order');
  });

  test('a value the column cannot hold still gets a safe label', () {
    Get.locale = const Locale('en', 'US');

    // The default branch has to stay: the column is an integer, and a future
    // value or a corrupt row must not crash a list. It must not read as a raw
    // key either.
    final label = StatusBadgeHelper.getOrderLabel(99);

    expect(label.trim(), isNotEmpty);
    expect(label, isNot(matches(_looksLikeAKey)),
        reason: 'the fallback label is a raw translation key');
  });

  group('the status description is translated, not hardcoded Arabic', () {
    test('an English merchant does not get an Arabic description', () {
      Get.locale = const Locale('en', 'US');

      for (final status in _allStatuses) {
        final description = StatusBadgeHelper.getOrderDescription(status);
        if (description.trim().isEmpty) continue;

        expect(
          _arabic.hasMatch(description),
          isFalse,
          reason: 'status $status describes itself as "$description" to a '
              'merchant whose locale is English. These strings were written '
              'as Arabic literals with no .tr at all',
        );
      }
    });

    test('an Arabic merchant still gets Arabic', () {
      Get.locale = const Locale('ar', 'AE');

      for (final status in _allStatuses) {
        final description = StatusBadgeHelper.getOrderDescription(status);
        if (description.trim().isEmpty) continue;

        expect(_arabic.hasMatch(description), isTrue,
            reason: 'status $status lost its Arabic description');
      }
    });

    test('a description exists for every live status', () {
      Get.locale = const Locale('en', 'US');

      // Otherwise "no Arabic in the English description" is satisfied by an
      // empty string, which is the vacuous way for the two tests above to
      // pass.
      for (final status in _allStatuses) {
        expect(StatusBadgeHelper.getOrderDescription(status).trim(), isNotEmpty,
            reason: 'status $status has no description at all');
      }
    });
  });

  test('every status has a badge config, so none renders unstyled', () {
    for (final status in _allStatuses) {
      final config = StatusBadgeHelper.getOrderConfig(status);
      expect(config.backgroundColor, isA<Color>());
      expect(config.textColor, isA<Color>());
    }
  });

  /// The badge's own text on its own background, measured.
  ///
  /// Not a theme question: these are hardcoded colour pairs inside the widget,
  /// and a pair nobody checked is exactly what the web side found twice on a
  /// new surface in this same cycle.
  test('every status badge clears WCAG AA for small text', () {
    double channel(double srgb) =>
        srgb <= 0.03928 ? srgb / 12.92 : math.pow((srgb + 0.055) / 1.055, 2.4) as double;

    double luminance(Color c) =>
        0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

    final failures = <String>[];

    for (final status in _allStatuses) {
      final config = StatusBadgeHelper.getOrderConfig(status);
      final l1 = luminance(config.textColor);
      final l2 = luminance(config.backgroundColor);
      final ratio = (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);

      if (ratio < 4.5) {
        failures.add('status $status: ${ratio.toStringAsFixed(2)}:1 '
            '(text ${config.textColor} on ${config.backgroundColor})');
      }
    }

    expect(failures, isEmpty,
        reason: 'badge colour pairs below AA:\n${failures.join('\n')}');
  });
}
