import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/screen/home_screen/tax_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-TAX-LABEL — the tax list called a tax rate a "Discount", in dollars, under an
/// untranslated header.
/// =================================================================================================
///
/// Found by the first populated capture of the tax screen (`flutter-tax-list_*`, under
/// `evidence/flutter-ops-2026-11-09/` in the Laravel repository). Three separate defects were
/// visible in one row, and each was then confirmed in the source rather than read off the pixels:
///
/// 1. **`"Name".tr` has no Arabic entry.** `lib/translations/ar.dart` carries `Amount` and `Action`
///    but not `Name`, so GetX falls back to the key and the Arabic column header rendered the
///    English word **"Name"** between "القيمة" and "الإجراء". The Laravel side has had
///    `"Name": "الاسم"` all along (`resources/lang/ar.json`), so the two surfaces disagreed on a
///    word the merchant web has translated for the same table.
///
/// 2. **A tax rate was labelled a discount.** `tax_screen.dart:274` built the amount as
///    `"${tax.taxAmount}% ${'Discount'.tr}"`, so an 11% VAT row read **"11% Discount"** — and since
///    `Discount` has no Arabic entry either, it read "Discount ١١٪" in Arabic too. A merchant
///    checking their tax classes was being told each one was a discount. The column is already
///    headed `Amount`/`القيمة` on a screen already headed `Tax`/`الضريبة`, so the word carried no
///    information even where it was not actively wrong.
///
/// 3. **A hard-coded dollar sign.** The fixed-amount branch built `"\$${tax.taxAmount} ..."`. The
///    `taxlist` endpoint (`Api/DashboardController::TaxList`) returns the paginator and nothing
///    else — **no currency field** — and nothing in this app stores the store's currency locally;
///    every `currencySymbol` in it comes from the response of the screen's own endpoint. So the
///    `$` was not a default that happened to be wrong for Syrian stores, it was invented. Showing
///    no symbol is strictly better than showing the wrong one; showing the RIGHT one needs the
///    server to send it, which is a public API change and is recorded in
///    `docs/design/TAX-CURRENCY-SYMBOL.md` rather than made here.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// Taken from the canonical list rather than re-declared, so these can never drift from the four
  /// combinations every other screen test in this repository uses.
  GoldenCombination named(String name) =>
      kFourCombinations.firstWhere((c) => c.name == name);

  final englishLight = named('light-ltr');
  final arabicLight = named('light-rtl');
  final arabicDark = named('dark-rtl');

  Map<String, Object?> taxes() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          // P2.5-TAX-CURRENCY: sent beside the pagination keys by TaxList.
          'currency_symbol': 'ل.س',
          'current_page': 1,
          'last_page': 1,
          'per_page': 10,
          'total': 2,
          'data': <Object?>[
            <String, Object?>{
              'id': 1,
              'tax_name': 'ضريبة القيمة المضافة',
              'tax_type': 'percentage',
              'tax_amount': 11,
              'status': 1,
              'store_id': 1,
            },
            <String, Object?>{
              'id': 2,
              'tax_name': 'Municipality fee',
              'tax_type': 'fixed',
              'tax_amount': 25,
              'status': 1,
              'store_id': 1,
            },
          ],
        },
      };

  Future<void> pumpTax(WidgetTester tester, {required GoldenCombination combination}) async {
    final api = ApiStub()..on('taxlist', taxes());
    await pumpScreen(tester, const TaxScreen(), api: api, combination: combination);
    await pumpUntil(
      tester,
      () => find.textContaining('Municipality fee').evaluate().isNotEmpty,
      reason: 'the tax rows never rendered, so nothing about their labels was measured',
    );
    await drainToasts(tester);
    expect(tester.takeException(), isNull);
  }

  testWidgets('the Arabic tax list translates its Name column', (tester) async {
    await pumpTax(tester, combination: arabicLight);

    expect(find.text('الاسم'), findsOneWidget,
        reason: 'the Arabic column header is still the untranslated key "Name". The Laravel side '
            'has translated this exact column since Phase 01 (resources/lang/ar.json).');
    expect(find.text('Name'), findsNothing,
        reason: 'the English key is still on screen in the Arabic build');
  });

  testWidgets('a percentage tax is not called a discount', (tester) async {
    await pumpTax(tester, combination: englishLight);

    expect(find.textContaining('11%'), findsOneWidget,
        reason: 'the rate itself must still be shown');
    expect(find.textContaining('Discount'), findsNothing,
        reason: 'an 11% VAT row still reads "11% Discount". A tax is not a discount, and telling a '
            'merchant their tax class is a discount is the kind of wrong that gets acted on.');
  });

  testWidgets('a fixed tax shows the STORE\'s currency, not an invented dollar sign',
      (tester) async {
    /// P2.5-TAX-CURRENCY, owner-approved. `taxlist` now sends `currency_symbol`, resolved from
    /// the store's active currency rate, so the row can print the real unit. The `$` this test
    /// originally forbade is still forbidden — it was never a default, it was invented.
    await pumpTax(tester, combination: englishLight);

    expect(find.textContaining('25'), findsOneWidget,
        reason: 'the amount itself must still be shown');
    expect(find.textContaining('25 ل.س'), findsOneWidget,
        reason: 'the fixed-amount row is not showing the store currency the response carries. '
            'The symbol is read from `currency_symbol`; nothing in this app caches a store '
            'currency, so if this fails the field is not reaching the screen.');
    expect(find.textContaining(r'$'), findsNothing,
        reason: 'the hard-coded US dollar sign is back');
  });

  testWidgets('a PERCENTAGE tax shows no currency, because a rate has no currency',
      (tester) async {
    /// The control that keeps the fix honest. A percentage is dimensionless; appending a currency
    /// to it would be a new wrong unit in place of the old one.
    await pumpTax(tester, combination: englishLight);

    expect(find.textContaining('11%'), findsOneWidget);
    expect(find.textContaining('11% ل.س'), findsNothing,
        reason: 'a percentage rate is being given a currency symbol');
  });

  testWidgets('an older server that sends no currency shows the number alone', (tester) async {
    /// BACKWARD COMPATIBILITY, and the reason there is no fallback. The field is additive, so a
    /// server that predates it sends no key. The row then prints the bare amount rather than
    /// guessing — a wrong symbol on a money figure is worse than no symbol, which is the whole
    /// lesson of the `$`.
    final withoutSymbol = taxes();
    (withoutSymbol['data']! as Map<String, Object?>).remove('currency_symbol');

    final api = ApiStub()..on('taxlist', withoutSymbol);
    await pumpScreen(tester, const TaxScreen(), api: api, combination: englishLight);
    await pumpUntil(
      tester,
      () => find.textContaining('Municipality fee').evaluate().isNotEmpty,
      reason: 'the tax rows never rendered',
    );
    await drainToasts(tester);

    expect(find.text('25'), findsOneWidget,
        reason: 'with no currency in the response the row should print the bare amount');
    expect(find.textContaining(r'$'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Arabic build is free of both English labels', (tester) async {
    /// The two defects above compound in Arabic: an untranslated header AND an untranslated word
    /// inside every row, so a third of the screen's text stayed English in the Arabic build.
    await pumpTax(tester, combination: arabicDark);

    expect(find.textContaining('Discount'), findsNothing);
    expect(find.text('Name'), findsNothing);
  });
}
