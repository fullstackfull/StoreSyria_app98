import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-HOME — the merchant dashboard, the first screen a merchant sees.
/// =================================================================================================
///
/// The largest surface in the admin app and the only one that renders from a SINGLE response:
/// `POST /dashboard` carries the user, the stores, the QR code, three headline totals, the top
/// products, the recent orders, the coupons, and both charts. It also carries the merchant's
/// PERMISSIONS, which the controller adopts from the fresh response only
/// (`home_controller.dart:217`).
///
/// WHAT HAD TO BE READ OUT OF THE CODE FIRST:
///
/// 1. **It needs TWO controllers registered for it, and the second one is not visible from the
///    screen file at all.** `Get.find<ThemeController>()` is a field initialiser
///    (`home_screen.dart:37`). `NotificationController` is NOT: the screen's own
///    `Get.put(NotificationController())` is **commented out** (`home_screen.dart:36`), while
///    `buildAppTitleRow` in `home_screen_widget.dart:21` still calls
///    `Get.find<NotificationController>()` — so mounting `HomeScreen` on its own throws
///    `"NotificationController" not found` from inside a `GetBuilder`, which surfaces as a blank
///    screen rather than as a thrown test. In the running app the bottom-nav shell has already
///    registered it. Measured, not assumed: the first run of this file rendered ZERO `Text`
///    widgets while the controller held the data perfectly.
///
///    The other three controllers the screen holds register THEMSELVES (`Get.put(...)` at
///    `:32-35`), one of them `permanent: true`.
/// 2. **The headline tiles are gated on the field being NON-NULL, not on its value**
///    (`home_screen.dart:397, 417, 428`): `permitted: dashboardData?.products != null`. A fixture
///    omitting `products`, `sales` or `order` renders the tile as "not permitted" rather than as
///    zero — which looks like a permissions problem and is not one. All three are present here.
/// 3. **`dashboardData` is assigned only on success**, and the screen shows an `EmptyState` while
///    it is null (`:113`). So "the dashboard rendered" and "the dashboard rendered its data" are
///    different claims, and the assertions below make the second one.
/// 4. **The response is CACHED to GetStorage** under the `cache_*` prefix
///    (`home_controller.dart:231`), which `resetScreenHarness` clears between tests.
///
/// This screen also runs a **30-second** `AnimationController` for the visitor chart
/// (`home_screen.dart:48`). That is exactly the shape of thing `pumpAndSettle` cannot survive, and
/// the reason this harness pumps a bounded number of frames instead.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  Map<String, Object?> dashboard() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'user': <String, Object?>{
            'id': 7,
            'name': 'سامر الحلبي',
            'email': 'samer@example.com',
          },
          'store': <Object?>[
            <String, Object?>{
              'id': 1,
              'name': 'متجر الشام',
              'slug': 'sham',
            },
          ],
          'qr-code': <String, Object?>{
            'url': 'https://storesyria.com/sham',
            'name': 'متجر الشام',
          },

          // The three headline totals. Present, because the tiles read `!= null` and not the
          // value -- see note 2 above.
          // `sales` is a COUNT on the server -- `Order::where('delivered_status', 1)->count()`
          // (`Api/DashboardController.php:1160`) -- not a money figure, despite the tile's
          // "Total Delivered" label. The first fixture put 1840000 here, which rendered as a
          // money-shaped number under a count label and would have made the evidence misleading.
          'products': 48,
          'sales': 37,
          'order': 126,

          'product': <Object?>[
            <String, Object?>{
              'id': 1,
              'name': 'قميص قطن دمشقي',
              'product_code': 'SS-1001',
              'price': 150,
              'sale_price': 0,
              'product_stock': 12,
              'status': 1,
            },
          ],
          'recent_order': <Object?>[
            <String, Object?>{
              'id': 1042,
              'product_order_id': 'SS-1042',
              'user_name': 'Marwan Haddad',
              // The server's own shapes, checked rather than guessed:
              // `order_date` is `date('M d, Y', ...)` and `delivery_status` is
              // `$value->delivered_status_string` — a STRING, not the integer the orders LIST
              // uses (`Api/DashboardController.php:1176-1181`). `RecentOrder.fromJson` assigns
              // `delivery_status` straight into a `String?` with no guard, so an int here throws
              // `type 'int' is not a subtype of type 'String?'` and takes down the WHOLE
              // dashboard — for a field this screen does not even render. Measured: the first
              // version of this fixture did exactly that.
              'order_date': 'Nov 08, 2026',
              'final_price': 126500,
              'delivery_status': 'Pending',
              'currency': 'ل.س',
            },
            <String, Object?>{
              'id': 1041,
              'product_order_id': 'SS-1041',
              'user_name': 'ليلى حداد',
              'order_date': 'Nov 08, 2026',
              'final_price': 85000,
              'delivery_status': 'Shipped',
              'currency': 'ل.س',
            },
          ],
          'coupons': <Object?>[
            <String, Object?>{
              'id': 3,
              'coupon_name': 'افتتاح المتجر',
              'coupon_code': 'SHAM10',
              'coupon_type': 'percentage',
              'discount_amount': 10,
            },
          ],
          'orderchart': <Object?>[
            <String, Object?>{'date': '2026-11-03', 'order': 8},
            <String, Object?>{'date': '2026-11-04', 'order': 14},
            <String, Object?>{'date': '2026-11-05', 'order': 11},
          ],
          'visitorchart': <Object?>[
            <String, Object?>{'date': '2026-11-03', 'visitor': 120},
            <String, Object?>{'date': '2026-11-04', 'visitor': 180},
          ],

          // Adopted by the controller into `MerchantPermissions`. Named explicitly rather than
          // using the `*` wildcard, which `merchant_permissions.dart:18` reserves for the PLATFORM
          // OPERATOR -- a merchant fixture carrying it would be describing the wrong principal.
          'user_type': 'admin',
          'permissions': <Object?>[
            'Manage Dashboard',
            'Manage Order',
            'Show Order',
            'Manage Products',
            'Manage Coupon',
            'Manage Store Analytics',
          ],
        },
      };

  for (final combination in kFourCombinations) {
    testWidgets('the dashboard renders its data in ${combination.name}', (tester) async {
      final api = ApiStub()..on('dashboard', dashboard());

      await pumpScreen(
        tester,
        const HomeScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(ThemeController());
          Get.put(NotificationController());
        },
      );

      /// THE SECOND CLAIM, NOT THE FIRST. A dashboard whose fetch failed still renders — as an
      /// `EmptyState` — so waiting for real content is what distinguishes the two.
      ///
      /// The needle is the merchant's NAME, which `buildProfileTitle` renders straight from
      /// `dashboardData.user.name` and which falls back to the literal "StoreSyria Admin" when
      /// there is no data (`home_screen.dart:150`). An earlier version waited for an order
      /// reference instead — and **this screen does not render the recent orders at all**, which
      /// the fixture's `recent_order` rows are kept to prove: they parse, they reach
      /// `homeController.recentOrderList`, and nothing draws them. That is a gap worth knowing
      /// about, not a defect to fix here: `Orders list (tab 1)` is the surface that shows orders,
      /// and it has its own captures.
      await pumpUntil(
        tester,
        () => find.textContaining('سامر الحلبي').evaluate().isNotEmpty,
        reason: 'the merchant name never reached the screen, so the dashboard rendered its empty '
            'state or its "StoreSyria Admin" fallback and the capture would have frozen that. '
            'Recorded calls: ${api.calls}',
      );

      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'the dashboard threw while rendering in ${combination.name}');
      expect(api.sawRequestFor('dashboard'), isTrue,
          reason: 'the dashboard endpoint was never called. Recorded: ${api.calls}');

      final context = tester.element(find.byType(HomeScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'the dashboard rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'the dashboard rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-home', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the dashboard capture is suspiciously small: a blank render');
      }
    });
  }

  testWidgets('premise: a failed dashboard renders the empty state, not stale content',
      (tester) async {
    /// The control. `dashboardData` is assigned only on success, so this is also the assertion
    /// that the capture above is not of a screen that renders its layout regardless of the data.
    final api = ApiStub()
      ..on('dashboard', <String, Object?>{'status': 0, 'message': 'nope'}, status: 200);

    await pumpScreen(tester, const HomeScreen(), api: api, register: () {
      Get.put(ThemeController());
      Get.put(NotificationController());
    });

    await pumpFrames(tester);
    await drainToasts(tester);

    expect(find.textContaining('سامر الحلبي'), findsNothing,
        reason: 'the merchant name appears although the dashboard call did not succeed, so the '
            'populated assertions prove nothing about the response');
    expect(find.text('StoreSyria Admin'), findsWidgets,
        reason: 'the no-data fallback did not render either, so it is unclear what this screen is '
            'showing');
  });

  testWidgets('premise: the headline tiles are gated on presence, not on value', (tester) async {
    /// Note 2, made executable. `permitted: dashboardData?.products != null` means a response
    /// that OMITS a total renders that tile as unavailable — indistinguishable, to a merchant,
    /// from one they have no permission for. This records the behaviour so that a fixture missing
    /// a total is never mistaken for a permissions defect.
    final withoutTotals = dashboard();
    final data = withoutTotals['data']! as Map<String, Object?>;
    data.remove('products');

    final api = ApiStub()..on('dashboard', withoutTotals);

    await pumpScreen(tester, const HomeScreen(), api: api, register: () {
      Get.put(ThemeController());
      Get.put(NotificationController());
    });

    await pumpUntil(
      tester,
      () => find.textContaining('سامر الحلبي').evaluate().isNotEmpty,
      reason: 'the dashboard did not load, so nothing about the tiles was measured',
    );
    await drainToasts(tester);

    /// `48` was the products total in the full fixture and is absent from this one. Its presence
    /// here would mean the tile is reading something other than the field that was removed.
    expect(find.textContaining('48'), findsNothing,
        reason: 'the products total rendered although the response omitted it');
    expect(tester.takeException(), isNull);
  });
}
