// ROUTE 1 · the wallet transaction card — the third card this project measures, and the first
// picture of it.
// =================================================================================================
//
// WHY THIS SURFACE WAS CHOSEN, and the first reason is that the repository had already chosen it
// and then stopped. `test/support/sample_cards.dart` carries `sampleTransaction()` under the
// heading "A wallet transaction for the THIRD CARD this project measures", with its Arabic-plus-
// Latin description written deliberately "because that is the real shape on /finance and the one
// that exercises the bidi run". Two test files consume that fixture — `card_intrinsic_height_test`
// and `rich_text_font_inheritance_test` — and both MEASURE it. Neither had ever LOOKED at it. The
// fixture was reviewed, correct and unrendered.
//
// SELF-CONTAINED, which was the constraint. `transactionCard` is a top-level function taking a
// model, a currency string and an `isDark` flag. It binds no GetX controller, so it needs no
// `Get.put` and no mocked network layer — `balance_card.dart`, the obvious neighbour, needs a live
// `WalletController` and is therefore the wrong second pick.
//
// AND FOUR THINGS ABOUT IT CAN ONLY BE SEEN, NOT ASSERTED:
//
//  1. IT IS THE ONLY CARD IN THE SET THAT PAINTS A `RichText`, and that `RichText` has already
//     shipped broken. `transactions_widget.dart:144-148` records it: `RichText` does not inherit
//     `DefaultTextStyle`, so both child spans resolved `fontFamily: null` — measured as
//     `[null, null]` — and the transaction amount, the largest number on the row, rendered in the
//     platform font beside Tajawal. The repair is a `fontFamily` on the root span. Whether the
//     amount is now in the SAME typeface as the rest of the card is a question about shapes, and
//     the only honest answer to it is a picture.
//
//  2. IT IS THE ONLY CARD THAT FORMATS A DATE. `dateFormatted` goes through `intl` with the
//     merchant's own locale, because `DateFormat(format)` with no locale always resolves `MMM` to
//     an English abbreviation and an Arabic screen printed `Nov` (`helper.dart:21-26`). The Arabic
//     baseline is the only artefact that can show the Arabic month name actually arriving.
//
//     MEASURED, and it corrects something worth recording: this file needs NO
//     `initializeDateFormatting()` call of its own, although `screen_harness.dart:117` makes one
//     and `helper.dart:25` warns that `DateFormat(fmt, 'ar')` throws without it. The reason is that
//     `goldenHost` passes `TranslationService.localizationsDelegates`, and
//     `GlobalMaterialLocalizations.delegate` initialises the `intl` date symbols for the locale it
//     loads. The harness's docstring credits those delegates only with fixing `textDirection`; they
//     are also what makes a date format in Arabic at all. Verified by capturing without the call
//     and reading the Arabic month off the image.
//
//  3. `isDark` IS A PARAMETER HERE, NOT `Theme.of(context)`. `transactionCard` is handed its
//     brightness by the caller (`:17`, `:27-32`) and picks its own card fill, primary text and
//     secondary text from it. A caller that passes the wrong value gets a light card on a dark page
//     and no assertion in this suite would notice. The four-combination set is the check.
//
//  4. THE LIGHT CARD'S FILL IS THE PAGE'S FILL. `LightThemeColor.cBackGround` is `0xffFFFFFF` and
//     this card's light fill is `Colors.white` (`transactions_widget.dart:22-28`), so the only
//     thing separating card from page is a 1px `cBorder` hairline and a shadow at alpha .03. That
//     repair is recent and it is a one-pixel edge: a diff of one pixel is precisely what a golden
//     sees and a colour assertion does not.
//
// TWO ROWS, NOT ONE, for the same reason the badge catalogues are columns: the card is a switch
// with two sides and the existing fixture only drives the green one. The second row is a DEBIT with
// a status that is not `completed`, which is the only way to reach the red amount colour, the
// upward arrow, a named `_iconForType` case, a snake_case `_formatType` and the `_statusBadge`
// branch that prints the server's status string raw. See `sampleWithdrawalTransaction()` for the
// value-by-value reasoning.
//
// THE GAP BETWEEN THE TWO ROWS IS THE ONLY SCAFFOLDING. The cards stay flush to the horizontal
// edges, which is the framing `docs/design/GOLDEN-BASELINE-FRAMING.md` settled on for the other
// three card surfaces: content-height, real theme background, no invented page padding.
//
// NOTHING IS ASSERTED UNTIL A HUMAN HAS LOOKED. Each case skips while its baseline is absent.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/new_widgets/transactions_widget.dart';

import '../support/golden_harness.dart';
import '../support/sample_cards.dart';

void main() {
  setUpAll(loadAppFonts);

  // See trap 2 in golden_harness.dart: ThemeController.theme mutates the process-global AppColor,
  // and this card reads `LightThemeColor.cBorder` for its light hairline, so a dark case that did
  // not restore would give the next light capture a border colour the app never draws.
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  // Runtime skip, not `skip:` — `testWidgets`'s `skip` is `bool?`, so a reason string cannot be
  // passed to it. `markTestSkipped` puts the reason in the run output. See
  // customer_card_golden_test.dart for the eight silently-skipped cases that established this.
  bool skipUnlessCaptured(String surface, GoldenCombination combination) {
    if (goldenReady(surface, combination)) return false;
    markTestSkipped(goldenSkipReason(surface, combination));
    return true;
  }

  for (final combination in kFourCombinations) {
    testWidgets(
      'the wallet transaction card renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('transaction-card', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          // Built inside a Builder: the card sizes itself with .w/.h/.sp/.r throughout, so it must
          // be constructed under the ScreenUtilInit subtree. Constructing it eagerly outside throws
          // LateInitializationError before an expectation can run.
          child: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                transactionCard(
                  tx: sampleTransaction(),
                  currency: 'SYP',
                  isDark: combination.dark,
                ),
                SizedBox(height: 10.h),
                transactionCard(
                  tx: sampleWithdrawalTransaction(),
                  currency: 'SYP',
                  isDark: combination.dark,
                ),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('transaction-card', combination)),
        );
      },
      tags: const <String>['golden'],
    );
  }
}
