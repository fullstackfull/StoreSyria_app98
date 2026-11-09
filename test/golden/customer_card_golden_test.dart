// ROUTE 1 · the first pixel baselines in this repository — the customer and delivery-man cards.
// =================================================================================================
//
// WHY THESE TWO SURFACES FIRST, and it is not arbitrary. `test/rtl/customer_card_direction_test.dart`
// records a defect these exact widgets shipped with: the card's header row was wrapped in
// `Directionality(textDirection: TextDirection.ltr, ...)` while the three info rows beneath it were
// not, so **in Arabic the name sat flush against the physical left edge and the city, order count
// and phone all began at the physical right** — one card reading as two layouts stacked.
//
// That defect was invisible to every assertion in this suite until somebody wrote a test that asked
// the built tree which direction a specific `Text` resolved under. **A pixel baseline would have
// shown it at a glance**, in the picture, without anyone having to guess which widget to interrogate
// first. That is the whole argument for route 1, and these are the widgets that make it concretely
// rather than in the abstract.
//
// It also means these baselines are worth more than usual as a regression guard: the repair is
// recent, the layout is direction-sensitive by nature, and the suite's existing coverage of it is
// one resolved-direction assertion per widget.
//
// FOUR COMBINATIONS PER SURFACE — Arabic (RTL) and English (LTR), light and dark — because that is
// what this project requires of any UI change, and because the defect above existed in exactly one
// of the four. A baseline set that covered only light-LTR would have been green through it.
//
// NOTHING IS ASSERTED UNTIL A HUMAN HAS LOOKED. Each case skips while its baseline is absent and
// says in its skip reason how to capture it. See `test/support/golden_harness.dart` for why a
// baseline committed by the agent that wrote the test is worth nothing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';
import 'package:store_go_app/view/new_widgets/customer_widget.dart';
import 'package:store_go_app/view/new_widgets/delivery_boy_widget.dart';

import '../support/golden_harness.dart';
import '../support/sample_cards.dart';

void main() {
  setUpAll(loadAppFonts);

  // See trap 2 in golden_harness.dart: ThemeController.theme mutates the process-global AppColor,
  // so without this a dark case leaves every later light case rendering dark values.
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  // THE TWO FIXTURES MOVED TO ../support/sample_cards.dart, and the move is the point.
  //
  // `test/ui/card_intrinsic_height_test.dart` measures the same two cards, and two copies of a
  // fixture that has ALREADY BEEN WRONG TWICE -- `email` nested inside `customer_info` where the
  // API puts it at the root, and `mobile` instead of `contact` on the delivery man -- is how two
  // files come to measure different widgets while reporting the same name. Both mistakes produced
  // a green run and a wrong picture; the reasons are kept verbatim beside the data.

  // THE SKIP IS AT RUNTIME, NOT `skip:`, and the first version of this file got that wrong in a way
  // worth keeping. `testWidgets`'s `skip` is typed `bool?` — NOT `dynamic` like `test()`'s — so a
  // String reason cannot be passed to it and does not compile. The consequence was that
  // `goldenSkipReason()`, written and documented as "the reason attached to a skipped golden case,
  // so the skip explains itself", was NEVER CALLED: eight cases skipped in SILENCE inside a gate
  // this repository declares blocking and 100 per cent. `markTestSkipped` carries the reason into
  // the run output, which is what was intended all along. Caught by the adversarial review of this
  // change, which found the function was dead code.
  bool skipUnlessCaptured(String surface, GoldenCombination combination) {
    if (goldenReady(surface, combination)) return false;
    markTestSkipped(goldenSkipReason(surface, combination));
    return true;
  }

  for (final combination in kFourCombinations) {
    testWidgets(
      'the customer card renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('customer-card', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          // Built inside a Builder: the card sizes itself with .w/.h/.sp, so it must be constructed
          // under the ScreenUtilInit subtree. Constructing it eagerly outside throws
          // LateInitializationError before an expectation can run — recorded in
          // customer_card_direction_test.dart:66-69.
          child: Builder(
            builder: (context) => customerWidget(context: context, customer: sampleCustomer()),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('customer-card', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the delivery-man card renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('delivery-boy-card', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) =>
                deliveryBoyWidget(context: context, deliveryBoy: sampleDeliveryBoy()),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('delivery-boy-card', combination)),
        );
      },
      tags: const <String>['golden'],
    );
  }
}
