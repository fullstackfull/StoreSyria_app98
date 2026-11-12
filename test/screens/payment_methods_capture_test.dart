import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/screen/setting_screen/payment_setting_screen/payment_setting_screen.dart';

import '../support/golden_harness.dart';
import '../support/nested_fixtures.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-PAYMENTMETHODS — the gateways a store accepts.
/// =================================================================================================
///
/// **The screen registers its own controller** in a field initialiser
/// (`payment_setting_screen.dart:26-27`), so it is built inside a `Builder` and this test
/// registers nothing.
///
/// **The payload nests one level deeper than it looks.** The list is `data.active_methods`, not
/// `data`, and the controller reads it through `jsonList(...)` — a tolerant helper that answers an
/// empty list for a Map or a null rather than throwing. A fixture that puts the array one level
/// too high therefore renders "no payment methods" instead of failing, and that is a sentence a
/// merchant would believe about their own store.
///
/// **This surface is where P2.5-SET-03 is visible in the app.** Those gateway names are the ones
/// whose Arabic mistranslations were removed (`Stripe` had been `الشريط`, "the ribbon"), so the
/// Arabic captures here show the corrected labels.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  for (final combination in kFourCombinations) {
    testWidgets('store payment methods render the active gateways in ${combination.name}',
        (tester) async {
      final api = ApiStub()..on('getActivePaymentMethods', activePaymentMethodsResponse());

      await pumpScreen(
        tester,
        Builder(builder: (_) => const PaymentSettingScreen()),
        api: api,
        combination: combination,
      );

      await pumpUntil(
        tester,
        () => api.sawRequestFor('getActivePaymentMethods'),
        reason: 'the active-methods endpoint was never called. Recorded: ${api.calls}',
      );
      await pumpFrames(tester, frames: 14);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'payment methods threw in ${combination.name}');

      // A gateway NAME from the fixture. An empty list renders a tidy "nothing configured"
      // screen, so asserting that something rendered would pass against exactly the failure
      // this test exists to catch.
      expect(find.textContaining('Stripe'), findsWidgets,
          reason: 'no gateway name reached the screen, so active_methods did not parse');

      final context = tester.element(find.byType(PaymentSettingScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'payment methods rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'payment methods rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-payment-methods', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the payment-methods capture is suspiciously small');
      }
    });
  }

  testWidgets('a store with no active gateways renders without throwing', (tester) async {
    final api = ApiStub()..on('getActivePaymentMethods', noActivePaymentMethodsResponse());

    await pumpScreen(tester, Builder(builder: (_) => const PaymentSettingScreen()), api: api);
    await pumpFrames(tester, frames: 16);
    await drainToasts(tester);

    expect(tester.takeException(), isNull,
        reason: 'a store with every gateway switched off threw rather than saying so');
  });
}
