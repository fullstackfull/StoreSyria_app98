// GAP-270 / GAP-271 — the wallet transaction's TYPE and STATUS, which never reached GetX.
// =================================================================================================
//
// GAP-270. `transactions_widget.dart:216-221`, `_formatType()`, splits the wire value on `_`,
// capitalises each word and rejoins. **There is no `.tr` in it.** An Arabic merchant on /finance
// read `Order` and `Manual Withdrawal` in Latin script, which both Arabic captures show.
//
// GAP-271. `:189` is `isCompleted ? 'completed'.tr : status`. The host column is
// `enum('status', ['pending','completed','cancelled'])`, so **two of the three reachable values
// bypass translation entirely** and print the raw server token — the Arabic captures show
// `مكتمل` above a lowercase `pending`.
//
// ── WHY NOT THE PLURAL MECHANISM ────────────────────────────────────────────────────────────────
//
// `lib/utils/plural.dart` exists now and selects a CLDR category by COUNT. These are type and
// status NAMES: there is no number, nothing to agree with, and no category to select. Reaching for
// it here would be using a plural selector as a general lookup — a mechanism that fits the shape
// of the problem and not its content. The right mechanism is the one the rest of the app uses, a
// key per value, and **every key this needs already exists in both maps**:
//
//     manual_deposit · order_paid · order_payment_reversed · manual_withdrawal
//     pending · completed · cancelled
//
// So no copy is written here. For the four TYPES the English values are byte-identical to what
// `_formatType` already produced, which is the governing rule
// `converted_labels_render_arabic_test.dart` records — the English screen does not move by a
// character, and the test below asserts that rather than assuming it. For the STATUS, English does
// move, from the raw lowercase `pending` to `Pending`; that is not a re-wording, because a raw
// server token was never copy in the first place.
//
// ── THE FALLBACK IS THE POINT, NOT A DETAIL ─────────────────────────────────────────────────────
//
// GetX returns THE KEY ITSELF when a lookup misses, so a naive `type.tr` turns an unmapped value
// into a raw identifier on screen — strictly worse than the English it replaced, and exactly what
// `english_placeholder_strings_test.dart` exists for. The host can add a type or a status at any
// time. `sampleTransaction()` already carries one: its type is `'order'`, which has NO key, so the
// credit fixture exercises the fallback and the debit fixture exercises the translation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/wallet_model.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/new_widgets/transactions_widget.dart';

import '../support/golden_harness.dart';
import '../support/sample_cards.dart';

/// What `_formatType` produced before this change, reproduced here so the English values can be
/// compared against it rather than against a remembered string.
String titleCased(String raw) => raw
    .split('_')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

WalletTransaction txWith({required String type, required String status}) =>
    WalletTransaction.fromJson(<String, dynamic>{
      'id': 9,
      'type': type,
      'direction': 'debit',
      'amount': '10.00',
      'currency_code': 'SYP',
      'balance_before': '20.00',
      'balance_after': '10.00',
      'description': 'وصف',
      'status': status,
      'created_at': '2026-11-07 16:45:00',
    });

Future<void> pumpTx(WidgetTester tester, WalletTransaction tx, {required bool arabic}) async {
  pinGoldenSurface(tester);

  await tester.pumpWidget(goldenHost(
    dark: false,
    direction: arabic ? TextDirection.rtl : TextDirection.ltr,
    child: Builder(
      builder: (context) => transactionCard(tx: tx, currency: 'SYP', isDark: false),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  group('the copy this needs already exists, on both sides', () {
    const types = <String>[
      'manual_deposit',
      'order_paid',
      'order_payment_reversed',
      'manual_withdrawal',
    ];
    const statuses = <String>['pending', 'completed', 'cancelled'];

    for (final key in <String>[...types, ...statuses]) {
      test('$key is translated in both maps', () {
        expect(en.containsKey(key), isTrue, reason: '$key is missing from en.dart');
        expect(ar.containsKey(key), isTrue, reason: '$key is missing from ar.dart');
        expect(ar[key], isNot(key), reason: '$key is its own key text in ar.dart');
      });
    }

    for (final type in types) {
      test('the English for $type is byte-identical to what _formatType produced', () {
        // THE GOVERNING RULE, executable. If these ever differ, routing the type through `.tr`
        // would silently re-word the English screen, and the conversion would need a decision
        // rather than a commit.
        expect(en[type], titleCased(type),
            reason: 'converting $type to a key would change the English from '
                '"${titleCased(type)}" to "${en[type]}"');
      });
    }
  });

  group('what an Arabic merchant reads', () {
    testWidgets('the TYPE is Arabic, not Latin script', (tester) async {
      await pumpTx(tester, sampleWithdrawalTransaction(), arabic: true);

      expect(find.text('سحب يدوي'), findsOneWidget,
          reason: 'the transaction type still renders in English on an Arabic screen — this is '
              'GAP-270, and _formatType has no translation path at all');
      expect(find.text('Manual Withdrawal'), findsNothing);
    });

    testWidgets('the STATUS is Arabic for a value that is not `completed`', (tester) async {
      await pumpTx(tester, sampleWithdrawalTransaction(), arabic: true);

      expect(find.text('قيد الانتظار'), findsOneWidget,
          reason: 'a status other than `completed` still prints the RAW server token — this is '
              'GAP-271, and two of the three reachable enum values take that branch');
      expect(find.text('pending'), findsNothing);
    });

    testWidgets('`completed` keeps the Arabic it already had', (tester) async {
      await pumpTx(tester, sampleTransaction(), arabic: true);

      expect(find.text('مكتمل'), findsOneWidget);
    });
  });

  group('what an English merchant reads', () {
    testWidgets('the TYPE is unchanged, character for character', (tester) async {
      await pumpTx(tester, sampleWithdrawalTransaction(), arabic: false);

      expect(find.text('Manual Withdrawal'), findsOneWidget,
          reason: 'the English type moved, which the governing rule forbids');
    });

    testWidgets('the STATUS stops being a raw server token', (tester) async {
      await pumpTx(tester, sampleWithdrawalTransaction(), arabic: false);

      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('pending'), findsNothing,
          reason: 'the lowercase wire value is still being printed to an English merchant');
    });
  });

  group('a value with no key falls back instead of printing an identifier', () {
    testWidgets('an unmapped TYPE renders title-cased, in both languages', (tester) async {
      // `sampleTransaction()`'s type is `order`, which has no key — the fixture already covers
      // this branch, which is why it is used rather than an invented value.
      for (final arabic in <bool>[true, false]) {
        await pumpTx(tester, sampleTransaction(), arabic: arabic);

        expect(find.text('Order'), findsOneWidget,
            reason: 'an unmapped type must keep the old title-cased rendering; GetX returns the '
                'key itself on a miss, so a bare `.tr` would print `order` to the merchant');
      }
    });

    testWidgets('an unmapped STATUS renders title-cased too', (tester) async {
      await pumpTx(tester, txWith(type: 'manual_withdrawal', status: 'refunded'), arabic: true);

      expect(find.text('Refunded'), findsOneWidget,
          reason: 'the host can add a status at any time; an unmapped one must not reach the '
              'merchant as a lowercase wire token or as a raw key');
      expect(find.text('refunded'), findsNothing);
    });
  });
}
