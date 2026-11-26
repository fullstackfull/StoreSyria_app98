// GAP-270 and GAP-271 — THE WALLET TRANSACTION CARD'S TYPE AND STATUS RENDER IN ENGLISH ON THE
// ARABIC SCREEN, AND THE SUITE CANNOT SEE IT.
// =================================================================================================
//
// Both were found by LOOKING at a rendered image, not by an assertion, and that is the whole
// reason this file exists. `transactions_widget.dart` had two strings that never reached GetX:
//
//   TYPE    `_formatType()` split the server's `type` on `_`, capitalised each word and rejoined.
//           No `.tr` anywhere in the chain, so `manual_withdrawal` printed `Manual Withdrawal`
//           in Latin script on an otherwise fully Arabic card.
//
//   STATUS  `_statusBadge` read `isCompleted ? 'completed'.tr : status`. The host column is
//           `enum('pending','completed','cancelled')`
//           (`2026_11_02_000200_create_store_wallet_transactions_table.php:67`), so TWO of the
//           three reachable values bypassed translation entirely — a translated `مكتمل` sat above
//           a lowercase Latin `pending` in the same list.
//
// WHY A SOURCE-ONLY ASSERTION WOULD NOT HAVE BEEN ENOUGH. This repository has already recorded a
// test passing while the string it covered rendered in English on the Arabic page. So every
// claim below is driven through the real widget in the real shell, in all four combinations, and
// the Arabic cases assert BOTH that the Arabic arrived AND that the English did not.
//
// ------------------------------------------------------------------------------------------------
//  THE TYPE SET IS CENSUSED FROM THE SERVER, NOT CHOSEN BY EYE
// ------------------------------------------------------------------------------------------------
//
// `store_wallet_transactions.type` is `string(50)`, NOT an enum, so the migration cannot answer
// what values arrive. The answer is the write sites. Censused in the Laravel repository on
// 2026-11-26 — eleven `StoreWalletTransaction::create(...)` calls, nine distinct types:
//
//     order_paid                OrderFinancialService.php:193, :525
//     order_payment_reversed    OrderFinancialService.php:698
//     order_cancelled           OrderEntitlementReversal.php:280 (TRANSACTION_TYPES, REASON_CANCELLED)
//     order_refunded            OrderEntitlementReversal.php:280 (TRANSACTION_TYPES, REASON_REFUNDED)
//     manual_deposit            StoreFinanceController.php:1265, :2577
//     manual_withdrawal         StoreFinanceController.php:1397, :2771
//     withdrawal_request        StoreFinanceController.php:1563
//     withdrawal_refund         StoreFinanceController.php:1980
//     withdrawal_paid           StoreFinanceController.php:2187
//
// Four of the nine ALREADY had copy in both maps — `manual_deposit`, `manual_withdrawal`,
// `order_paid`, `order_payment_reversed` — written for the /finance type FILTER and never asked
// for by the card. That is the same shape as the status half: the string was available and simply
// not requested. The other five were missing from both maps and are added by this change.
//
// `sampleTransaction()` carries `'type': 'order'`, AND NO WRITE SITE IN THE LARAVEL REPOSITORY
// PRODUCES THAT VALUE — it is a fixture artefact, which is why the Arabic baseline images show a
// Latin `Order`. It is deliberately NOT given copy here: inventing a label for a value the
// product never emits would be worse than the fallback. The unknown-type case below pins the
// fallback instead, so an unmapped type degrades to the old humanised English rather than to a
// raw snake_case identifier.
//
// ------------------------------------------------------------------------------------------------
//  THE ENGLISH SCREEN MUST NOT CHANGE, AND THAT IS ASSERTED RATHER THAN HOPED FOR
// ------------------------------------------------------------------------------------------------
//
// `converted_labels_render_arabic_test.dart` establishes this project's rule for converting a
// hard-coded literal to a `.tr` key: the existing English value must be BYTE-IDENTICAL to the
// literal being replaced, or the repair is a silent English copy change wearing a translation's
// clothes. Here the "literal" is computed, so the rule becomes: every type key's English copy
// must equal what `_formatType` would have produced for it. All nine do, and
// `test_every_type_english_copy_is_byte_identical_to_the_humanised_form` keeps it that way.
//
// THE ONE DELIBERATE EXCEPTION IS THE STATUS, AND IT IS AN IMPROVEMENT RATHER THAN A DRIFT. The
// English card used to print a translated `Completed` above a raw lowercase `pending` — the two
// branches disagreed with each other. Routing all three through `.tr` makes English read
// `Pending` / `Completed` / `Cancelled`. That is asserted explicitly below so it is a recorded
// decision and not an accident.
//
// ------------------------------------------------------------------------------------------------
//  WHAT THIS FILE DELIBERATELY DOES NOT DO
// ------------------------------------------------------------------------------------------------
//
// GAP-271's colour half and GAP-272 are carried with GAP-269 as ONE palette decision for the
// owner, so nothing here repaints anything. The status pill keeps `warning` for both `pending`
// and `cancelled`, and the amount colours are untouched. The measurements are reported in the
// workstream report, not converted into a repair.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/wallet_model.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/view/new_widgets/transactions_widget.dart';

import '../support/golden_harness.dart';

/// Every `store_wallet_transactions.type` the server writes, mapped to the English the card
/// rendered BEFORE this change — i.e. what `_formatType` produces for it.
const Map<String, String> kServerWrittenTypes = <String, String>{
  'order_paid': 'Order Paid',
  'order_payment_reversed': 'Order Payment Reversed',
  'order_cancelled': 'Order Cancelled',
  'order_refunded': 'Order Refunded',
  'manual_deposit': 'Manual Deposit',
  'manual_withdrawal': 'Manual Withdrawal',
  'withdrawal_request': 'Withdrawal Request',
  'withdrawal_refund': 'Withdrawal Refund',
  'withdrawal_paid': 'Withdrawal Paid',
};

/// The host enum, verbatim from the migration.
const List<String> kTransactionStatuses = <String>['pending', 'completed', 'cancelled'];

/// What an English merchant must read for each status after this change.
const Map<String, String> kStatusEnglish = <String, String>{
  'pending': 'Pending',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
};

final RegExp _arabicLetter = RegExp(r'[؀-ۿ]');

/// The humanisation `_formatType` performs, reproduced so the English half can be asserted
/// against the behaviour being replaced rather than against a hand-copied string.
String humanise(String type) => type
    .split('_')
    .map((String w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

WalletTransaction txWith({
  required String type,
  required String status,
  String direction = 'debit',
}) =>
    WalletTransaction.fromJson(<String, dynamic>{
      'id': 7,
      'type': type,
      'direction': direction,
      'amount': '75.50',
      'currency_code': 'SYP',
      'balance_before': '150.00',
      'balance_after': '74.50',
      'description': 'وصف العملية',
      'status': status,
      'created_at': '2026-11-07 16:45:00',
    });

void main() {
  setUpAll(loadAppFonts);
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  Map<String, Map<String, String>> maps() => TranslationService().keys;

  group('the copy exists in both maps', () {
    test('every wallet transaction type the server writes has copy in BOTH maps', () {
      final Map<String, String> en = maps()['en']!;
      final Map<String, String> ar = maps()['ar']!;

      final List<String> missing = <String>[];
      for (final String type in kServerWrittenTypes.keys) {
        if (!en.containsKey(type)) missing.add('$type (en.dart)');
        if (!ar.containsKey(type)) missing.add('$type (ar.dart)');
      }

      expect(
        missing,
        isEmpty,
        reason: 'GetX `.tr` renders the KEY when copy is absent, so each of these would print a '
            'raw snake_case identifier to the merchant — or fall back to English on the Arabic '
            'card. Add the copy to both maps:\n${missing.join('\n')}',
      );
    });

    test('every type English copy is byte-identical to the humanised form it replaces', () {
      final Map<String, String> en = maps()['en']!;

      for (final MapEntry<String, String> entry in kServerWrittenTypes.entries) {
        expect(
          humanise(entry.key),
          entry.value,
          reason: 'the census table itself disagrees with _formatType for ${entry.key}',
        );
        expect(
          en[entry.key],
          entry.value,
          reason: 'routing ${entry.key} through .tr changed what an ENGLISH merchant reads: '
              '"${entry.value}" became "${en[entry.key]}". Converting a computed literal may not '
              'reword the English screen.',
        );
      }
    });

    test('every type Arabic copy is really Arabic', () {
      final Map<String, String> ar = maps()['ar']!;

      for (final MapEntry<String, String> entry in kServerWrittenTypes.entries) {
        final String? copy = ar[entry.key];
        expect(copy, isNotNull, reason: '${entry.key} has no Arabic copy');
        expect(copy, isNot(entry.key), reason: '${entry.key} renders its own identifier');
        expect(copy, isNot(entry.value), reason: '${entry.key} renders the English on the ar map');
        expect(
          _arabicLetter.hasMatch(copy!),
          isTrue,
          reason: '${entry.key} renders "$copy", which contains no Arabic letter',
        );
      }
    });

    test('all three host enum statuses have copy in both maps', () {
      final Map<String, String> en = maps()['en']!;
      final Map<String, String> ar = maps()['ar']!;

      for (final String status in kTransactionStatuses) {
        expect(en.containsKey(status), isTrue, reason: '$status missing from en.dart');
        expect(ar.containsKey(status), isTrue, reason: '$status missing from ar.dart');
        expect(en[status], kStatusEnglish[status]);
        expect(
          _arabicLetter.hasMatch(ar[status]!),
          isTrue,
          reason: '$status renders "${ar[status]}" on the Arabic card',
        );
      }
    });
  });

  // ===============================================================================================
  //  RENDERED, IN ALL FOUR COMBINATIONS
  // ===============================================================================================

  for (final GoldenCombination combination in kFourCombinations) {
    final bool arabic = combination.direction == TextDirection.rtl;

    testWidgets(
      'the TYPE renders translated on the card — ${combination.name}',
      (WidgetTester tester) async {
        // ONE CARD PER PUMP, not nine in a Column. The harness pins the surface to the design
        // size (360x800) and nine of these cards overflow it by 244px, which throws a layout
        // exception and fails the case for a reason that has nothing to do with the copy. The
        // real screen scrolls; a test that needs to see nine cards at once is asking the wrong
        // question of a card component.
        pinGoldenSurface(tester);

        final Map<String, String> expected = arabic ? maps()['ar']! : maps()['en']!;

        for (final MapEntry<String, String> entry in kServerWrittenTypes.entries) {
          await tester.pumpWidget(goldenHost(
            dark: combination.dark,
            direction: combination.direction,
            child: Builder(
              builder: (BuildContext context) => transactionCard(
                tx: txWith(type: entry.key, status: 'completed'),
                currency: 'SYP',
                isDark: combination.dark,
              ),
            ),
          ));
          await tester.pumpAndSettle();

          expect(
            find.text(expected[entry.key]!),
            findsOneWidget,
            reason: '${entry.key} did not render as "${expected[entry.key]}" on the '
                '${combination.name} card',
          );
          if (arabic) {
            expect(
              find.text(entry.value),
              findsNothing,
              reason: '${entry.key} rendered the English "${entry.value}" on the Arabic card',
            );
            expect(
              find.text(entry.key),
              findsNothing,
              reason: '${entry.key} rendered its own raw identifier',
            );
          }
        }
      },
    );

    testWidgets(
      'the STATUS renders translated on the pill — ${combination.name}',
      (WidgetTester tester) async {
        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (BuildContext context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final String status in kTransactionStatuses)
                  transactionCard(
                    tx: txWith(type: 'manual_withdrawal', status: status),
                    currency: 'SYP',
                    isDark: combination.dark,
                  ),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final Map<String, String> expected = arabic ? maps()['ar']! : maps()['en']!;

        for (final String status in kTransactionStatuses) {
          expect(
            find.text(expected[status]!),
            findsOneWidget,
            reason: '$status did not render as "${expected[status]}" on the ${combination.name} '
                'pill',
          );
          expect(
            find.text(status),
            findsNothing,
            reason: '$status printed the raw server string on the ${combination.name} pill',
          );
        }
      },
    );

    testWidgets(
      'an UNMAPPED type degrades to the humanised English, never to a raw identifier — '
      '${combination.name}',
      (WidgetTester tester) async {
        // `sampleTransaction()` really does carry `type: 'order'`, and no Laravel write site
        // produces it. Without a fallback, `'order'.tr` would print the bare key `order`; with
        // one it prints `Order`, which is exactly what shipped before this change.
        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (BuildContext context) => transactionCard(
              tx: txWith(type: 'order', status: 'completed', direction: 'credit'),
              currency: 'SYP',
              isDark: combination.dark,
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Order'), findsOneWidget);
        expect(find.text('order'), findsNothing);
      },
    );
  }

  testWidgets('the Arabic card carries no Latin type or status text at all', (tester) async {
    // The census above asks "is the Arabic there". This asks the complementary question —
    // "is any English LEFT" — because the defect was found by looking at a picture and seeing
    // Latin script where none belonged.
    pinGoldenSurface(tester);
    Get.locale = const Locale('ar', 'AE');

    final List<String> latin = <String>[];

    for (final String type in kServerWrittenTypes.keys) {
      await tester.pumpWidget(goldenHost(
        dark: false,
        direction: TextDirection.rtl,
        child: Builder(
          builder: (BuildContext context) => transactionCard(
            tx: txWith(type: type, status: 'pending'),
            currency: 'SYP',
            isDark: false,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      for (final Text t in tester.widgetList<Text>(find.byType(Text))) {
        final String? data = t.data;
        if (data == null) continue;
        // The id (`#7`), the amount, the currency code and the date are deliberately Latin —
        // digits and `SYP` are the same in both builds. Only alphabetic Latin RUNS are the
        // defect, and the currency code is excluded by name rather than by pattern so a new
        // English word cannot hide behind it.
        if (data == 'SYP' || data.trim().isEmpty) continue;
        for (final RegExpMatch m in RegExp(r'[A-Za-z]{3,}').allMatches(data)) {
          if (m.group(0) == 'SYP') continue;
          latin.add('$type: "$data" (Latin run: ${m.group(0)})');
        }
      }
    }

    expect(
      latin,
      isEmpty,
      reason: 'these strings render in Latin script on the Arabic transaction card:\n'
          '${latin.join('\n')}',
    );
  });
}
