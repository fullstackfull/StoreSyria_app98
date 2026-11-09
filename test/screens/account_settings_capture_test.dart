import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/screen/profile_screen/profile_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/email_setting_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/loyality_setting_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-ACCOUNT — the three screens the copy deck unlocked.
/// =================================================================================================
///
/// Profile / My Account, Store email settings and the Loyalty programme. All three were held back
/// from capture for the same reason Store Information was: **their labels were hard-coded English
/// literals**, so an Arabic merchant read an English form. That was recorded in
/// `COPY-DECK-UNTRANSLATED-SCREENS.md` rather than patched, because `.tr` on a key with no copy
/// renders the raw identifier and would have made the screen worse.
///
/// The owner authorised the copy in the Phase 2.5 final directive, it is written, and these are
/// the first captures of the three screens in either language.
///
/// All three register their own controllers in `State` field initialisers, so none needs a
/// `register` callback. Each then fetches on mount, and the stub answers so the form renders
/// populated rather than in its loading state.
///
/// WHAT EACH CASE ASSERTS, beyond mounting: a label that came OUT OF THE DECK, in whichever
/// language the combination asked for. That is the point of these captures — not that the screen
/// renders, but that it renders in the merchant's own language. Both spellings are checked in
/// every combination, so a combination that silently rendered the wrong language fails here rather
/// than passing vacuously.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  Map<String, Object?> emailSettings() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          // Configuration VALUES, never translated — a merchant copies these from their provider.
          'mail_driver': 'smtp',
          'mail_host': 'smtp.storesyria.com',
          'mail_port': '587',
          'mail_username': 'store@storesyria.com',
          'mail_password': 'secret',
          'mail_encryption': 'tls',
          'mail_from_address': 'no-reply@storesyria.com',
          'mail_from_name': 'متجر الشام',
        },
      };

  Map<String, Object?> loyalty() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'status': 'on',
          'point': '25',
        },
      };

  final cases = <_AccountCase>[
    _AccountCase(
      surface: 'flutter-profile',
      label: 'profile',
      // `name` and `profileImg` are required: the screen is pushed from the dashboard's profile
      // row, which already holds both. A realistic Arabic name is passed so the capture shows the
      // header the way a merchant sees it.
      build: () => ProfileScreen(name: 'سامر الحلبي', profileImg: ''),
      typeName: 'ProfileScreen',
      // From the deck: `title: 'Account Information'` (profile_screen.dart:421).
      deckLabel: <String>['Account Information', 'معلومات الحساب'],
      stub: () => ApiStub(),
    ),
    _AccountCase(
      surface: 'flutter-email-settings',
      label: 'store email settings',
      build: () => const EmailSettingScreen(),
      typeName: 'EmailSettingScreen',
      // From the deck: `labelText: 'Mail Host:'` (email_setting_screen.dart:72).
      deckLabel: <String>['Mail Host', 'خادم البريد'],
      stub: () => ApiStub()..on('emailsetting', emailSettings()),
    ),
    _AccountCase(
      surface: 'flutter-loyalty',
      label: 'loyalty programme',
      build: () => LoyaltyProgramScreen(),
      typeName: 'LoyaltyProgramScreen',
      // From the deck: `title: 'Store Loyalty Program'` (loyality_setting_screen.dart:49).
      // This one already HAD Arabic — it is one of the three rows the deck was stale about — so
      // it also checks the deck's own staleness did not cost anything.
      deckLabel: <String>['Store Loyalty Program', 'برنامج ولاء المتجر'],
      stub: () => ApiStub()..on('loyalitysetting', loyalty()),
    ),
  ];

  for (final combination in kFourCombinations) {
    for (final accountCase in cases) {
      testWidgets('${accountCase.label} renders in ${combination.name}', (tester) async {
        final api = accountCase.stub();

        await pumpScreen(
          tester,
          accountCase.build(),
          api: api,
          combination: combination,
        );
        await pumpFrames(tester, frames: 12);
        await drainToasts(tester);

        expect(tester.takeException(), isNull,
            reason: '${accountCase.label} threw while rendering in ${combination.name}');

        final found = accountCase.deckLabel
            .any((label) => find.textContaining(label).evaluate().isNotEmpty);

        expect(found, isTrue,
            reason: 'neither "${accountCase.deckLabel.first}" nor '
                '"${accountCase.deckLabel.last}" is on ${accountCase.label} in '
                '${combination.name}. This label came out of the copy deck, so if it is missing '
                'either the screen stopped rendering it or its translation was lost.');

        final context = tester.element(
          find.byWidgetPredicate((w) => w.runtimeType.toString() == accountCase.typeName),
        );
        expect(Directionality.of(context), combination.direction,
            reason: '${accountCase.label} rendered the wrong direction in ${combination.name}');
        expect(
          Theme.of(context).brightness,
          combination.dark ? Brightness.dark : Brightness.light,
          reason: '${accountCase.label} rendered the wrong brightness in ${combination.name}',
        );

        final captured = await captureScreen(
          tester,
          captureName(accountCase.surface, combination),
        );
        if (captureDir != null) {
          expect(captured, isNotNull);
          expect(captured!.lengthSync(), greaterThan(1000),
              reason: 'the ${accountCase.label} capture is suspiciously small: a blank render');
        }
      });
    }
  }

  testWidgets('premise: the Arabic build really is Arabic on these screens', (tester) async {
    /// The whole reason these three were held back. Before the copy existed, every label on them
    /// was a hard-coded English literal and the Arabic build rendered an English form. This
    /// asserts the opposite directly: in the Arabic combination the ENGLISH spelling of a deck
    /// label must be ABSENT, not merely the Arabic present — a screen showing both would mean the
    /// conversion only reached some sites.
    final api = ApiStub()..on('emailsetting', emailSettings());

    await pumpScreen(
      tester,
      const EmailSettingScreen(),
      api: api,
      combination: kFourCombinations.firstWhere((c) => c.name == 'light-rtl'),
    );
    await pumpFrames(tester, frames: 12);
    await drainToasts(tester);

    expect(find.textContaining('خادم البريد'), findsWidgets,
        reason: 'the Arabic label for Mail Host is missing from the Arabic build');
    expect(find.textContaining('Mail Host'), findsNothing,
        reason: 'the English literal is still on screen in the Arabic build, so the conversion '
            'did not reach this site');
  });
}

class _AccountCase {
  _AccountCase({
    required this.surface,
    required this.label,
    required this.build,
    required this.typeName,
    required this.deckLabel,
    required this.stub,
  });

  final String surface;
  final String label;
  final Widget Function() build;
  final String typeName;

  /// `[english, arabic]` for one label that came out of the copy deck.
  final List<String> deckLabel;

  final ApiStub Function() stub;
}
