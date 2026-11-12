import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/store_setting_controller.dart';
import 'package:store_go_app/view/screen/setting_screen/language_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/store_info_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-STORE-SETTINGS — store information, and language & currencies.
/// =================================================================================================
///
/// The two screens a merchant configures their store from, and the two that share
/// `StoreSettingController`. Both do `Get.find` for it, so the test registers it once and both
/// screens take the same instance — exactly as they do in the running app, where the More grid
/// leads to each of them in turn.
///
/// WHAT IS DIFFERENT ABOUT THESE TWO:
///
/// 1. **They fan out across several endpoints.** Language & currencies calls three in its
///    `initState` — `getCurrenciesData`, `getStoreCurrencyLangData`, `getCurrencyRatesData`
///    (`language_screen.dart:28-30`) — and re-calls two of them lazily when a section is expanded.
///    Store information calls one. A fixture that answers only the first leaves the rest on the
///    stub's fallback, which is a valid empty envelope, so nothing crashes and nothing shows: the
///    screens would capture as blank and look finished.
/// 2. **The store-info status gate accepts BOTH shapes** — `status == 'success' || status == 1`
///    (`store_setting_controller.dart:204`) — which is unusual in this API and worth pinning,
///    because a fixture using the int while the server sends the string (or the reverse) would
///    still pass through one of the two branches and hide a real mismatch.
/// 3. **`getCurrenciesData` short-circuits on a VALID CACHE.** It returns early while the cached
///    copy is still inside its 24-hour window (`store_setting_controller.dart:28`), and
///    `CacheService` writes under the `cache_*` prefix that `resetScreenHarness` clears — so each
///    test here really does fetch rather than reading the previous test's currencies.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  Map<String, Object?> storeInfo() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'store': <String, Object?>{
            'id': 1,
            'name': 'متجر الشام',
            'slug': 'sham',
            'email': 'hello@sham.example',
            'default_language': 'ar',
            'store_url': 'https://storesyria.com/sham',
            'created_at': '2026-01-04 10:00:00',
          },
          'owner': <String, Object?>{
            'id': 7,
            'name': 'سامر الحلبي',
            'email': 'samer@example.com',
          },
          'address': <String, Object?>{
            'address': 'شارع بغداد',
            'city': 'دمشق',
            'country': 'Syria',
          },
          'media': <String, Object?>{'logo': '', 'banner': ''},
          'social_media': <String, Object?>{'facebook': '', 'instagram': ''},
          'settings': <String, Object?>{'currency': 'SYP', 'timezone': 'Asia/Damascus'},
        },
      };

  Map<String, Object?> currencies() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'store_id': 1,
          'current_currency': <String, Object?>{
            'code': 'SYP',
            'name': 'Syrian Pound',
            'symbol': 'ل.س',
            'rate_per_usd': 13000,
            'is_active': true,
          },
          'currencies': <Object?>[
            <String, Object?>{
              'code': 'SYP',
              'name': 'Syrian Pound',
              'symbol': 'ل.س',
              'rate_per_usd': 13000,
              'is_active': true,
            },
            <String, Object?>{
              'code': 'USD',
              'name': 'US Dollar',
              'symbol': r'$',
              'rate_per_usd': 1,
              'is_active': true,
            },
          ],
        },
      };

  Map<String, Object?> languageAndCurrency() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'current_language': <String, Object?>{
            'code': 'ar',
            'name': 'العربية',
            'flag': '🇸🇾',
          },
          'languages': <Object?>[
            <String, Object?>{'code': 'ar', 'name': 'العربية', 'flag': '🇸🇾'},
            <String, Object?>{'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
          ],
          'current_currency': <String, Object?>{
            'code': 'SYP',
            'name': 'Syrian Pound',
            'symbol': 'ل.س',
            'rate_per_usd': 13000,
            'is_active': true,
          },
        },
      };

  /// Every endpoint both screens reach. The ORDER MATTERS: `on()` matches in insertion order and
  /// against the whole URL, and `getCurrentLanguageAndCurrency` contains neither
  /// `getCurrenciesApi` nor `getStoreInfo`, so the three are unambiguous — but
  /// `getCurrenciesApi` would also match a rule keyed on the shorter `Currenc`, which is why each
  /// rule names its endpoint in full.
  ApiStub settingsStub() => ApiStub()
    ..on('getStoreInfo', storeInfo())
    ..on('getCurrentLanguageAndCurrency', languageAndCurrency())
    ..on('getCurrenciesApi', currencies());

  for (final combination in kFourCombinations) {
    testWidgets('store information renders its store in ${combination.name}', (tester) async {
      final api = settingsStub();

      await pumpScreen(
        tester,
        const StoreInfoScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(StoreSettingController());
        },
      );

      final controller = Get.find<StoreSettingController>();

      await pumpUntil(
        tester,
        () => controller.storeInfoData.value != null,
        reason: 'the store never loaded, so the screen rendered its empty state and the capture '
            'would have frozen that. Recorded calls: ${api.calls}',
      );
      await pumpFrames(tester, frames: 10);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'store information threw while rendering in ${combination.name}');
      expect(api.sawRequestFor('getStoreInfo'), isTrue,
          reason: 'the store-info endpoint was never called. Recorded: ${api.calls}');

      /// The store's own name, which `_fillControllers()` pushes into the form. Checking the
      /// PARSED value as well as the call means a response that arrived but did not map is not
      /// mistaken for one that never arrived.
      expect(controller.storeInfoData.value?.store?.name, 'متجر الشام',
          reason: 'the store name did not survive parsing');

      final context = tester.element(find.byType(StoreInfoScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'store information rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'store information rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-store-info', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the store-info capture is suspiciously small: a blank render');
      }
    });

    testWidgets('language & currencies renders its options in ${combination.name}',
        (tester) async {
      final api = settingsStub();

      await pumpScreen(
        tester,
        const LanguageCurrenciesScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(StoreSettingController());
        },
      );

      final controller = Get.find<StoreSettingController>();

      await pumpUntil(
        tester,
        () => controller.currencies.isNotEmpty,
        reason: 'the currencies never loaded. Recorded calls: ${api.calls}',
      );
      await pumpFrames(tester, frames: 10);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'language & currencies threw while rendering in ${combination.name}');

      /// BOTH of its first two endpoints, not just the one the needle waited on. The screen fans
      /// out across three calls in `initState` and a fixture answering one would leave the others
      /// on the stub's empty fallback — which renders as a screen with nothing selected and looks
      /// like a finished screen with no data.
      expect(api.sawRequestFor('getCurrenciesApi'), isTrue,
          reason: 'the currencies endpoint was never called. Recorded: ${api.calls}');
      expect(api.sawRequestFor('getCurrentLanguageAndCurrency'), isTrue,
          reason: 'the language endpoint was never called. Recorded: ${api.calls}');

      expect(controller.currencies.length, 2,
          reason: 'the currency list did not parse into two options: '
              '${controller.currencies.map((c) => c.code).toList()}');

      final context = tester.element(find.byType(LanguageCurrenciesScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'language & currencies rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'language & currencies rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-language-currency', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the language capture is suspiciously small: a blank render');
      }
    });
  }

  testWidgets('premise: the store-info gate really does accept both status shapes',
      (tester) async {
    /// `status == 'success' || status == 1` is unusual in this API, where every other handler
    /// gates on the int alone. Pinning it means a server that switches from one to the other
    /// cannot silently blank this screen, and it documents that the fixtures above are not
    /// relying on an accident.
    for (final status in <Object>['success', 1]) {
      final body = storeInfo();
      body['status'] = status;

      final api = ApiStub()..on('getStoreInfo', body);

      await pumpScreen(tester, const StoreInfoScreen(), api: api, register: () {
        Get.put(StoreSettingController());
      });

      final controller = Get.find<StoreSettingController>();
      await pumpUntil(
        tester,
        () => controller.storeInfoData.value != null,
        reason: 'the store-info gate refused status $status, so one of its two accepted shapes '
            'no longer works',
      );
      await drainToasts(tester);

      resetScreenHarness();
    }
  });
}
