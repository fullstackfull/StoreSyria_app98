import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/screen/setting_screen/app_settings.dart';
import 'package:store_go_app/view/screen/setting_screen/setting_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-SETTINGS — the "More" grid and the app-settings screen, standalone.
/// =================================================================================================
///
/// Two surfaces, and deliberately captured **standalone** rather than taken from the shell batch.
/// `flutter-shell-more_*` shows this grid with the navigation bar over it, as the fifth
/// destination; these are the screens on their own. The owner's constraints forbid using one
/// picture as evidence for two surfaces, so each row in the inventory gets captures that are its
/// own — and `check-distinct-surface-captures.py` would catch it if they were not.
///
/// NEITHER NEEDS A `register` CALLBACK, and for two different reasons worth keeping straight:
///
/// * `SettingScreen` is a `StatelessWidget` that builds through
///   `GetBuilder<ThemeController>(init: ThemeController())` (`setting_screen.dart:27`), so it
///   constructs its own. It is the ONE screen the project could pump before the harness existed,
///   and `test/ui/setting_gate_rendering_test.dart` records why.
/// * `AppSettingsScreen` puts both of its controllers in `State` field initialisers
///   (`app_settings.dart:24-25`), which run inside `pumpWidget` and therefore inside the client
///   zone.
///
/// THE GRID IS PERMISSION-GATED, with `mayOffer` rather than `may`
/// (`setting_screen.dart:73, :85, :97, ...`): a server that has not been updated sends no
/// permission list, and `mayOffer` returns true for an EMPTY set so the client never hides a
/// surface merely because the backend is older than it is. A fresh harness has no permissions, so
/// every card is offered — which is the state these captures show, and the right one for a visual
/// review of the grid.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  for (final combination in kFourCombinations) {
    testWidgets('the More grid renders every card in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        const SettingScreen(isBack: false),
        api: api,
        combination: combination,
      );
      await pumpFrames(tester, frames: 12);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'the More grid threw while rendering in ${combination.name}');

      /// Four cards by name, in whichever language the combination asked for. Checking BOTH
      /// spellings in every combination rather than branching on direction means a combination
      /// that silently rendered the wrong language fails here instead of passing vacuously.
      for (final pair in <List<String>>[
        <String>['Analytics', 'التحليلات'],
        <String>['Shipping', 'الشحن'],
        <String>['Customers', 'العملاء'],
        <String>['Wallet', 'المحفظة'],
      ]) {
        final found = pair.any((label) => find.textContaining(label).evaluate().isNotEmpty);
        expect(found, isTrue,
            reason: 'neither "${pair.first}" nor "${pair.last}" is on the More grid in '
                '${combination.name}, so a card a merchant reaches every other surface through is '
                'missing from this capture');
      }

      final context = tester.element(find.byType(SettingScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'the More grid rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'the More grid rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-more-grid', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the More grid capture is suspiciously small: a blank render');
      }
    });

    testWidgets('app settings renders in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        AppSettingsScreen(),
        api: api,
        combination: combination,
      );
      await pumpFrames(tester, frames: 12);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'app settings threw while rendering in ${combination.name}');

      final context = tester.element(find.byType(AppSettingsScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'app settings rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'app settings rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-app-settings', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the app settings capture is suspiciously small: a blank render');
      }
    });
  }
}
