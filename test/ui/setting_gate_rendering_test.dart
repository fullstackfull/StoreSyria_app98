// WS K. The six permission gates on the Settings grid, PUMPED rather than read.
//
// `setting_screen.dart` hides five cards and the store-setting entry behind
// `MerchantPermissions.current.mayOffer(...)`, so an employee with orders-only
// access is not offered Analytics, Shipping, Customers, Delivery Men or
// Coupons. Nothing broke: the collection-`if`s work as written. What was missing
// was any test that BUILDS the screen — the existing coverage proves the
// permission model answers correctly (`merchant_permissions_test`) and that the
// endpoint list is gated (`permission_gated_endpoints_test`), neither of which
// can see whether the widget tree actually omits a card.
//
// So this is regression cover for a gate that works today, which is the point:
// the six gates are the only thing between an orders-only employee and five
// screens the server will refuse them, and a collection-`if` is one careless
// edit away from becoming unconditional.
//
// ------------------------------------------------------------------------
// WHY THIS PUMPS `SettingScreen` STANDALONE AND NOTHING ELSE.
//
// An adversarial review of the originally proposed approach rejected two thirds
// of it, and both rejections shaped this file:
//
//   * An `_InertOrderController` with an overridden `onInit` would have been
//     INERT for the hazard it named. `OrderScreen` fires `getTopOrderData()`,
//     `_fetchInitialData()` and `getDeliveryBoysData()` itself, in `initState`
//     and a post-frame callback — an `onInit` override touches none of them, the
//     calls reach the network, and their failure toasts leave GetX timers
//     pending so `pumpAndSettle` hangs for reasons unrelated to any gate.
//
//   * Making the grid observable by wrapping it in `Obx` over
//     `HomeController.permissions` would have BROKEN this file. `HomeController`
//     is registered in exactly one place — a `_HomeScreenState` field
//     initialiser — and in no binding, so `SettingScreen` built on its own would
//     throw "HomeController not found". It survives in production only by the
//     ordering coincidence that HomeScreen is index 0 of the same IndexedStack.
//
// `SettingScreen` itself needs no controller registration: it builds through
// `GetBuilder<ThemeController>(init: ThemeController())`, which constructs its
// own. That is what makes a standalone pump safe here and not elsewhere.
//
// `persist()` writes through `Prefs`, so GetStorage is initialised against a
// temp directory the same way `permission_store_switch_test` does it.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/core/permissions/merchant_permissions.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/screen/setting_screen/setting_screen.dart';

void main() {
  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    storageDir = Directory.systemTemp.createTempSync('store_go_gate_render');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();

    Get.addTranslations({'en': en, 'ar': ar});
  });

  tearDownAll(() {
    try {
      storageDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  setUp(() {
    Get.locale = const Locale('en', 'US');
    MerchantPermissions.forget();
  });

  tearDown(() {
    MerchantPermissions.forget();
    Get.reset();
  });

  /// Put `names` in force as the current permission set.
  void holding(List<String> names) {
    MerchantPermissions.fromJson(<String, dynamic>{
      'permissions': names,
      'type': 'staff',
    }).persist();
  }

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => GetMaterialApp(
          translations: null,
          locale: const Locale('en', 'US'),
          home: const SettingScreen(isBack: false),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The five gated cards, by the title each renders.
  const gated = <String, String>{
    'analytics': Permissions.manageStoreAnalytics,
    'shipping': Permissions.manageShipping,
    'customers': Permissions.manageCustomer,
    'delivery_men': Permissions.manageDeliveryboy,
    'coupon': Permissions.manageCoupon,
  };

  group('an employee is offered only what they hold', () {
    testWidgets('holding one permission shows that card and hides the rest', (
      tester,
    ) async {
      holding(<String>[Permissions.manageShipping]);
      await pumpSettings(tester);

      expect(
        find.text('shipping'.tr),
        findsOneWidget,
        reason:
            'the card for a permission the employee HOLDS is missing, so '
            'the gate is hiding a screen they may use',
      );

      for (final entry in gated.entries) {
        if (entry.value == Permissions.manageShipping) continue;

        expect(
          find.text(entry.key.tr),
          findsNothing,
          reason:
              'the ${entry.key} card is offered to an employee who does '
              'not hold ${entry.value}. The server will refuse them, so the '
              'card is an invitation to a dead end.',
        );
      }
    });

    // ONE CASE PER GATE, NOT ONE LOOP OVER ALL FIVE.
    //
    // The loop version pumped the same `GetMaterialApp` five times with
    // different permissions in between, and failed on the second iteration with
    // "withholding Manage Shipping did not hide the shipping card" — Flutter
    // reuses the element tree when the widget configuration is identical, so the
    // grid never rebuilt and the second assertion read the FIRST pump's output.
    // A fresh tester per gate is what makes each one measure its own state, and
    // it names the offending card when it fails.
    //
    // Hold everything EXCEPT one, so a grid hidden wholesale cannot pass.
    for (final withheld in gated.entries) {
      testWidgets('withholding ${withheld.value} hides only the '
          '${withheld.key} card', (tester) async {
        holding(gated.values.where((p) => p != withheld.value).toList());

        await pumpSettings(tester);

        expect(
          find.text(withheld.key.tr),
          findsNothing,
          reason:
              'withholding ${withheld.value} did not hide the '
              '${withheld.key} card, so that gate is not doing anything',
        );

        for (final shown in gated.entries) {
          if (shown.value == withheld.value) continue;

          expect(
            find.text(shown.key.tr),
            findsOneWidget,
            reason:
                'withholding ${withheld.value} also hid the '
                '${shown.key} card, so the gates are not independent',
          );
        }
      });
    }
  });

  group('the gate fails OPEN, which is deliberate', () {
    testWidgets('a server that sends no permission list offers everything', (
      tester,
    ) async {
      // `mayOffer` is `isEmpty || may(...)`: a backend that has not been
      // updated sends no list, and gating strictly on an empty set would empty
      // this grid for every merchant. The screen's own comment says so; this
      // pins it so nobody "tightens" it into a blank Settings page.
      MerchantPermissions.forget();
      await pumpSettings(tester);

      for (final entry in gated.entries) {
        expect(
          find.text(entry.key.tr),
          findsOneWidget,
          reason:
              'an empty permission set emptied the Settings grid. '
              'mayOffer fails open on purpose — a server that sends no list '
              'must not lock every merchant out of their own settings.',
        );
      }
    });

    testWidgets('and a full permission set offers everything too', (
      tester,
    ) async {
      holding(gated.values.toList());
      await pumpSettings(tester);

      for (final entry in gated.entries) {
        expect(find.text(entry.key.tr), findsOneWidget);
      }
    });
  });
}
