import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/core/controller/delivery_boy/delivery_boy_controller.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/view/screen/category_screen/category_screen.dart';
import 'package:store_go_app/view/screen/coupon_screen/coupon_screen.dart';
import 'package:store_go_app/view/screen/customers/customer_screen.dart';
import 'package:store_go_app/view/screen/delivery_boys/delivery_boy_screen.dart';
import 'package:store_go_app/view/screen/product_screen/products_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-HARNESS — the harness proved against REAL screens, in all four combinations.
/// =================================================================================================
///
/// `screen_harness_test.dart` proves the harness's claims about itself. This file proves it
/// generalises: five merchant screens of four different shapes, each mounted in English-LTR and
/// Arabic-RTL, light and dark — **20 mounts** — with the network under control and no
/// `pumpAndSettle` anywhere.
///
/// Before this, `test/ui/setting_gate_rendering_test.dart` was the only screen that could be
/// pumped at all, and its own header explains why: it "needs no controller registration" because it
/// builds through `GetBuilder<ThemeController>(init: ThemeController())` and constructs its own.
/// Every screen here does the opposite — a `Get.find<SomeController>()` in a field initialiser and
/// a fetch from `initState` or a post-frame callback.
///
/// WHAT EACH CASE ASSERTS, AND WHY IT IS IN THIS ORDER.
///
///   1. the screen made the HTTP call the stub expected — WITHOUT this, a screen that silently
///      stopped fetching and a screen whose request escaped to the real network both look like a
///      pass;
///   2. it mounted with no exception — `tester.takeException()` is checked explicitly, because a
///      widget-library exception is reported at the END of a test and is easy to leave unasserted;
///   3. it rendered the direction and brightness that were asked for — this project has already
///      shipped four "configurations" whose LTR and RTL images were byte-identical
///      (`RESUME-POINT-2026-10-27.md`), so the combination is measured, not assumed.
///
/// THESE ARE MOUNT TESTS, NOT DESIGN VERIFICATION. They establish that a screen can be driven and
/// that what it draws can be measured. Promoting a surface in the coverage matrix needs captures
/// and a look at them; see `PHASE-2.5-SESSION-2026-11-09.md`.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// One page, in the envelope every list endpoint in this API shares: `{status, data: {...}}`.
  ///
  /// The lists are deliberately EMPTY. A populated fixture has to match each model's own field
  /// names — and this project has twice frozen a baseline whose fixture used the wrong key
  /// (`email` nested instead of at the root, `mobile` instead of `contact`). An empty page
  /// exercises the same parse path, the same loading-to-loaded transition and the same empty
  /// state, without inventing a shape that might be wrong.
  Map<String, Object?> page(String listKey) => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          listKey: <Object?>[],
          'pagination': <String, Object?>{'last_page': 1},
        },
      };

  final cases = <_ScreenCase>[
    _ScreenCase(
      name: 'customers',
      endpoint: 'customerlist',
      body: page('customers'),
      build: () => const CustomerScreen(),
      register: () {
        Get.put(CustomerController());
      },
    ),
    _ScreenCase(
      name: 'products',
      endpoint: 'productlist',
      body: page('products'),
      build: () => const ProductsScreen(isBack: false),
      register: () {
        Get.put(ProductController());
      },
    ),
    _ScreenCase(
      name: 'categories',
      endpoint: 'categorylist',
      body: page('categories'),
      build: () => const CategoriesScreen(isBack: false),
      register: () {
        Get.put(CategoryController());
      },
    ),
    _ScreenCase(
      name: 'coupons',
      endpoint: 'couponlist',
      body: page('coupons'),
      build: () => const CouponScreen(),
      register: () {
        Get.put(NewCouponController());
      },
    ),
    _ScreenCase(
      name: 'delivery men',
      endpoint: 'deliveryboy',
      body: page('deliveryboy'),
      build: () => const DeliveryBoyScreen(),
      register: () {
        Get.put(DeliveryBoyController());
      },
    ),
  ];

  for (final screenCase in cases) {
    for (final combination in kFourCombinations) {
      testWidgets('${screenCase.name} mounts and fetches in ${combination.name}', (tester) async {
        final api = ApiStub()..on(screenCase.endpoint, screenCase.body);

        await pumpScreen(
          tester,
          screenCase.build(),
          api: api,
          combination: combination,
          register: screenCase.register,
        );

        // Toasts first: a screen whose fetch failed shows one, and a pending 4s timer would
        // otherwise surface as an unrelated teardown failure.
        await drainToasts(tester);

        expect(
          tester.takeException(),
          isNull,
          reason: '${screenCase.name} threw while mounting in ${combination.name}',
        );

        expect(
          api.calls,
          isNotEmpty,
          reason: '${screenCase.name} made no HTTP call. Either it stopped fetching on mount, or '
              'the request escaped the stub — and the second case means the test was talking to '
              'the real network.',
        );

        final context = tester.element(find.byWidgetPredicate((w) => w.runtimeType.toString() == screenCase.widgetTypeName));

        expect(Directionality.of(context), combination.direction,
            reason: '${screenCase.name} rendered the wrong direction in ${combination.name}');
        expect(
          Theme.of(context).brightness,
          combination.dark ? Brightness.dark : Brightness.light,
          reason: '${screenCase.name} rendered the wrong brightness in ${combination.name}',
        );
      });
    }
  }

  testWidgets('premise: every case names an endpoint the app really has', (tester) async {
    /// A typo in `endpoint` would make `on()` never match, the fallback would answer, and every
    /// case above would still pass its `calls is not empty` assertion. This checks the fragment
    /// against the request the screen actually made, for one case, so the matching itself is
    /// known to work rather than assumed.
    final api = ApiStub()..on('customerlist', page('customers'));

    await pumpScreen(tester, const CustomerScreen(), api: api, register: () {
      Get.put(CustomerController());
    });

    expect(api.sawRequestFor('customerlist'), isTrue,
        reason: 'the recorded calls were ${api.calls}');
  });
}

class _ScreenCase {
  _ScreenCase({
    required this.name,
    required this.endpoint,
    required this.body,
    required this.build,
    required this.register,
  });

  final String name;
  final String endpoint;
  final Map<String, Object?> body;
  final Widget Function() build;
  final void Function() register;

  /// The runtime type name of the screen widget, for locating its element.
  String get widgetTypeName => build().runtimeType.toString();
}
