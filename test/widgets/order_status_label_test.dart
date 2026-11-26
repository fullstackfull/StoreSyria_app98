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

  // ===========================================================================
  // P2.5-WAVE-5 -- THE DARK SET.
  //
  // MEASURED before any of it was written: every LIGHT badge background sits
  // between 12.49:1 and 14.24:1 against the dark card `#18263F`. They were
  // near-white tiles on a dark page, on every order list, order detail,
  // notification, top-orders and payment surface in the shipped app, because
  // `order_status_badge.dart` contained no `Theme.of(context)`, no `isDark`
  // and no `Brightness` reference at all.
  //
  // Three constraints, each asserted separately below so a failure names which
  // one broke rather than just "the badge is wrong".
  // ===========================================================================

  double channel(double srgb) =>
      srgb <= 0.03928 ? srgb / 12.92 : math.pow((srgb + 0.055) / 1.055, 2.4) as double;

  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  double ratio(Color a, Color b) {
    final l1 = luminance(a);
    final l2 = luminance(b);
    return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
  }

  /// `DarkThemeColor.cCardBackground`, which is what a badge actually sits on.
  const darkCard = Color(0xFF18263F);

  test('PREMISE: the light set really is unusable on the dark card', () {
    // Without this the dark set below could be identical to the light one and
    // every assertion after it would still pass.
    final glaring = <String>[];
    for (final status in _allStatuses) {
      final light = StatusBadgeHelper.getOrderConfig(status);
      if (ratio(light.backgroundColor, darkCard) < 7.0) {
        glaring.add('status $status: only '
            '${ratio(light.backgroundColor, darkCard).toStringAsFixed(2)}:1');
      }
    }
    expect(glaring, isEmpty,
        reason: 'the light badges no longer glare on the dark card, so the dark '
            'set below may be solving a problem that is gone:\n${glaring.join('\n')}');
  });

  test('the dark set is actually different from the light set', () {
    for (final status in _allStatuses) {
      final light = StatusBadgeHelper.getOrderConfig(status);
      final dark = StatusBadgeHelper.getOrderConfig(status, isDark: true);
      expect(dark.backgroundColor, isNot(equals(light.backgroundColor)),
          reason: 'status $status returns the light background in dark mode');
    }
  });

  test('every dark status badge clears WCAG AA for small text', () {
    final failures = <String>[];
    for (final status in _allStatuses) {
      final c = StatusBadgeHelper.getOrderConfig(status, isDark: true);
      final r = ratio(c.textColor, c.backgroundColor);
      if (r < 4.5) {
        failures.add('status $status: ${r.toStringAsFixed(2)}:1 '
            '(text ${c.textColor} on ${c.backgroundColor})');
      }
    }
    expect(failures, isEmpty, reason: 'dark pairs below AA:\n${failures.join('\n')}');
  });

  test('every dark badge border reaches 3:1 against the dark card', () {
    // SC 1.4.11. The BORDER identifies the chip in dark mode, because a fill
    // strong enough to read as a chip on a near-black page is the glare this
    // whole package removes.
    final failures = <String>[];
    for (final status in _allStatuses) {
      final c = StatusBadgeHelper.getOrderConfig(status, isDark: true);
      final r = ratio(c.borderColor, darkCard);
      if (r < 3.0) {
        failures.add('status $status: border ${r.toStringAsFixed(2)}:1');
      }
    }
    expect(failures, isEmpty,
        reason: 'dark badge boundaries below SC 1.4.11:\n${failures.join('\n')}');
  });

  test('every dark badge fill is visible as a surface without glaring', () {
    final failures = <String>[];
    for (final status in _allStatuses) {
      final c = StatusBadgeHelper.getOrderConfig(status, isDark: true);
      final r = ratio(c.backgroundColor, darkCard);
      if (r < 1.25) {
        failures.add('status $status: fill only ${r.toStringAsFixed(2)}:1 - invisible');
      }
      if (r > 4.0) {
        failures.add('status $status: fill ${r.toStringAsFixed(2)}:1 - glaring');
      }
    }
    expect(failures, isEmpty, reason: 'dark fills:\n${failures.join('\n')}');
  });

  // ===========================================================================
  // GAP-269 -- THE LIGHT HALF, AND THE ASYMMETRY WAS IN THIS FILE.
  //
  // Wave 2 measured the light badge borders at 1.29-1.65:1 against the white
  // card while the dark set sits at 3.00-3.16:1, and asked why. The answer is
  // three tests up: `every dark badge border reaches 3:1` and `every dark badge
  // fill is visible` have NO light equivalent, and the only light assertion is
  // `every status badge clears WCAG AA for small text`, which measures TEXT.
  // So the light boundary was never checked by anything, and an asymmetry that
  // looks like a palette decision was really a missing test.
  //
  // THE HOST IS THE WHITE CARD, for the same reason `darkCard` is the host
  // above: a badge sits on a list row, and the rows are white in light mode
  // (orders, notifications, top orders, order detail). The page behind the row
  // is a light grey, but the page is not what the chip is adjacent to.
  //
  // SC 1.4.11 APPLIES BECAUSE THE CHIP IS A CONTROL, not decoration:
  // `order_detail_screen.dart:535` and `:1172` give the detail-shape badge an
  // `onTap` and a chevron that opens the status sheet.
  // ===========================================================================

  /// What a badge really sits on in light mode: the list row, which is white.
  const lightCard = Color(0xFFFFFFFF);

  test('every LIGHT badge border reaches 3:1 against the white card', () {
    // The exact twin of the dark assertion above. Its absence is GAP-269.
    final failures = <String>[];
    for (final status in [..._allStatuses, 99]) {
      final c = StatusBadgeHelper.getOrderConfig(status);
      final r = ratio(c.borderColor, lightCard);
      if (r < 3.0) {
        failures.add('status $status: border ${r.toStringAsFixed(2)}:1');
      }
    }
    expect(failures, isEmpty,
        reason: 'light badge boundaries below SC 1.4.11:\n${failures.join('\n')}');
  });

  test('the PAYMENT badge has a light boundary too, by the same rule', () {
    /// FOUND BY RECAPTURING EVERY BASELINE AND READING THE DIFF, which is the only reason it is
    /// here. A `sed` used to bite-check the order table had no `g` flag but still matched every
    /// LINE, so restoring one value also rewrote the paid payment badge's border -- an edit
    /// nobody asked for, invisible in the test run, and visible the moment
    /// `payment-status-badge-column.light-*.png` moved.
    ///
    /// It is kept rather than reverted, because the payment badge is the same component family on
    /// the same white rows and had the SAME defect: paid 1.34:1, unpaid 1.41:1. The accident
    /// half-fixed it; this finishes it and pins both, so the next change is deliberate.
    final failures = <String>[];
    for (final paid in <String>['paid', 'unpaid']) {
      final c = StatusBadgeHelper.getPaymentConfig(paid);
      final r = ratio(c.borderColor, lightCard);
      if (r < 3.0) {
        failures.add('payment "$paid": border ${r.toStringAsFixed(2)}:1');
      }

      final lf = luminance(c.backgroundColor);
      final lt = luminance(c.textColor);
      final lb = luminance(c.borderColor);
      if (lb >= lf || lb <= lt) {
        failures.add('payment "$paid": the border is not derived from its own badge');
      }
    }
    expect(failures, isEmpty,
        reason: 'light payment badge boundaries below SC 1.4.11:\n${failures.join('\n')}');
  });

  test('every LIGHT border is derived from that badge\'s own two colours', () {
    /// WHY THIS EXISTS AND WHAT IT STOPS. Raising ten borders to 3:1 invites an
    /// arbitrary palette. The rule used instead introduces no hue at all: each
    /// border is the badge's OWN text colour blended 75% over its OWN fill, so
    /// a chip's outline is the colour its label already is, only lighter. This
    /// asserts the property that rule guarantees -- the border lies between the
    /// fill and the text in luminance -- so a later hand-picked colour that
    /// happens to clear 3:1 still fails here unless it belongs to the badge.
    final failures = <String>[];
    for (final status in [..._allStatuses, 99]) {
      final c = StatusBadgeHelper.getOrderConfig(status);
      final lf = luminance(c.backgroundColor);
      final lt = luminance(c.textColor);
      final lb = luminance(c.borderColor);

      if (lb >= lf || lb <= lt) {
        failures.add('status $status: border luminance ${lb.toStringAsFixed(3)} is not '
            'between the text ${lt.toStringAsFixed(3)} and the fill ${lf.toStringAsFixed(3)}');
      }
    }
    expect(failures, isEmpty,
        reason: 'a light border no longer comes from its own badge:\n${failures.join('\n')}');
  });

  test('the light FILLS are deliberately left faint, and that is why the border carries it', () {
    /// THE TEST THE DARK SET HAS AND THE LIGHT SET MUST NOT. `every dark badge
    /// fill is visible as a surface without glaring` holds the dark fills to
    /// >=1.25:1, because on a near-black page a tint IS the chip. In light the
    /// fills are near-white tints by design -- status 6 measures 1.06:1 on the
    /// white card -- and raising them would repaint every order list in the
    /// shipped app for a requirement SC 1.4.11 does not make of a fill when the
    /// BORDER carries the boundary. This records that as a decision rather than
    /// an oversight, and fails if somebody "finishes the job" by darkening them.
    final strong = <String>[];
    for (final status in _allStatuses) {
      final c = StatusBadgeHelper.getOrderConfig(status);
      if (ratio(c.backgroundColor, lightCard) > 1.25) {
        strong.add('status $status: fill ${ratio(c.backgroundColor, lightCard).toStringAsFixed(2)}:1');
      }
    }
    expect(strong, isEmpty,
        reason: 'a light badge fill has been darkened into a surface. That is a palette change '
            'across every order list, and the border is what SC 1.4.11 asks for '
            'here:\n${strong.join('\n')}');
  });

  test('the payment badge follows the theme too', () {
    for (final paid in ['paid', 'unpaid']) {
      final light = StatusBadgeHelper.getPaymentConfig(paid);
      final dark = StatusBadgeHelper.getPaymentConfig(paid, isDark: true);
      expect(dark.backgroundColor, isNot(equals(light.backgroundColor)),
          reason: 'payment badge "$paid" keeps its light background in dark mode');
      expect(ratio(dark.textColor, dark.backgroundColor), greaterThanOrEqualTo(4.5),
          reason: 'payment badge "$paid" is below AA in dark mode');
    }
  });

  test('a grey status stays grey in dark mode', () {
    // Statuses whose LIGHT source is near-neutral have no meaningful hue. A
    // naive derivation gave the default badge a saturation floor and turned it
    // RED; this is the assertion that caught it.
    final c = StatusBadgeHelper.getOrderConfig(99, isDark: true); // the default arm
    expect(c.backgroundColor.r, closeTo(c.backgroundColor.g, 0.02),
        reason: 'the default (grey) badge has gained a hue in dark mode');
    expect(c.backgroundColor.g, closeTo(c.backgroundColor.b, 0.02),
        reason: 'the default (grey) badge has gained a hue in dark mode');
  });
}
