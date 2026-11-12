import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/screen/plans/my_plan_screen.dart';

import '../support/golden_harness.dart';
import '../support/nested_fixtures.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-MYPLAN — the merchant's subscription, its limits and its expiry.
/// =================================================================================================
///
/// **The screen registers its own controller** (`my_plan_screen.dart:19` does
/// `Get.put(PlanController())` in a field initialiser), so this test registers nothing — and must
/// build the screen inside the pump rather than constructing it early, which is the trap that
/// `StoreSettingScreen` already taught this suite.
///
/// **The model is forgiving, which is the hazard.** Every field in `my_plan_model.dart` is read as
/// `json['x'] ?? default` and every nested object through `jsonMap(...)`, so a payload missing
/// `limits` does not throw — it renders `0 / 0 products`, which looks like a real answer about a
/// real plan. That is why the fixture is written out in full and why the assertions below name a
/// figure from it rather than merely checking that something rendered.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  for (final combination in kFourCombinations) {
    testWidgets('my plan renders the plan, its usage and its expiry in ${combination.name}',
        (tester) async {
      final api = ApiStub()..on('indexAllPlan', currentPlanResponse());

      await pumpScreen(
        tester,
        // Built inside a Builder: the screen's `Get.put(PlanController())` runs in a field
        // initialiser, so constructing it outside the pump registers the controller before the
        // harness has set up its bindings.
        Builder(builder: (_) => const MyPlanScreen()),
        api: api,
        combination: combination,
      );

      await pumpUntil(
        tester,
        () => api.sawRequestFor('indexAllPlan'),
        reason: 'the plan endpoint was never called. Recorded: ${api.calls}',
      );
      await pumpFrames(tester, frames: 14);
      await drainToasts(tester);

      expect(tester.takeException(), isNull, reason: 'my plan threw in ${combination.name}');

      // A FIGURE FROM THE FIXTURE, not merely "something rendered". The model defaults every
      // missing field to zero, so a screen reading `0` is what a wrong payload looks like.
      expect(find.textContaining('Growth'), findsWidgets,
          reason: 'the plan name is not on the plan screen, so the payload did not reach it');

      final context = tester.element(find.byType(MyPlanScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'my plan rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'my plan rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-my-plan', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the my-plan capture is suspiciously small');
      }
    });
  }

  /// An expired plan must render, because that is the state the screen exists to warn about and
  /// the one a merchant is most likely to be looking at when something has gone wrong.
  testWidgets('an expired plan renders without throwing', (tester) async {
    final api = ApiStub()..on('indexAllPlan', expiredPlanResponse());

    await pumpScreen(tester, Builder(builder: (_) => const MyPlanScreen()), api: api);
    await pumpFrames(tester, frames: 16);
    await drainToasts(tester);

    expect(tester.takeException(), isNull,
        reason: 'an expired plan threw rather than rendering its expiry notice');
  });
}
