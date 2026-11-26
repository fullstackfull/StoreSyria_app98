// ROUTE 1 · wave 4 — THE FIRST WHOLE SCREENS IN THIS REPOSITORY'S BASELINE SET.
// =================================================================================================
//
// WHAT THIS CLOSES, IN THE GAP'S OWN WORDS. `GAP-062`/`P02-K15` carries the next action
// *"Render a whole screen rather than a component, which needs route 2 (the emulator) or a
// screen-level widget harness."* Every golden before this one is a COMPONENT: wave 1's two list
// cards, wave 2's badge catalogues and transaction card, wave 3's eleven shared states, controls
// and card families. `5b3c6bb` says it plainly in its own message — *"Still component-level only:
// no full SCREEN is rendered as a golden."* No emulator exists in these containers, so this is the
// other branch of that sentence: the screen-level harness, taken all the way to a pixel baseline.
//
// AND IT IS NOT A SECOND HARNESS. `test/support/screen_harness.dart` already pumps a real merchant
// screen with its REAL controller in front of a stubbed network — it is what
// `test/screens/*_capture_test.dart` drives. What it has never done is produce a COMPARABLE
// artefact: `captureScreen()` writes a PNG only when `SS_CAPTURE_DIR` is set, and its own docstring
// explains that those images are evidence rather than assertions. This file joins the two halves
// that already exist — `screen_harness`'s pump and `golden_harness`'s baseline discipline — so a
// screen becomes a surface the ordinary blocking `flutter test` compares pixel for pixel the moment
// a human approves one.
//
// WHY A SCREEN IS WORTH A SEPARATE PICTURE FROM ITS CARDS, measured rather than argued. `3727efc`
// found both list cards stretching to fill any bounded box — a `Column` with no `mainAxisSize`
// inside a `Container` with no height — and recorded that *"the app looked right for a reason that
// is not these widgets' doing: both render inside a scrolling list where the main axis is
// UNBOUNDED"*. That is precisely the class of defect a component baseline cannot hold an opinion
// about: the component was wrong, the screen was right, and only rendering both says which. The
// customers screen below is the SAME card wave 1 photographs, in its real list, with its real app
// bar, its real search row, its real spacing and its real siblings above and below.
//
// THE CAPTURE TARGET IS THE PINNED BOUNDARY, NOT `find.byType(Scaffold)`, and the difference is
// not cosmetic. `kCaptureBoundaryKey` is installed by `pumpScreen` ABOVE the navigator, so what it
// photographs includes any overlay the screen put up — a toast, a dialog, a bottom sheet.
// `screen_harness.dart` records the 20 blank captures that measured the alternative: the first
// `RenderRepaintBoundary` walking down from the root belongs to `_ModalScopeState`, holds the first
// route's page and nothing above it. A `Scaffold` finder has a second problem of its own here: a
// screen is free to nest one, and `expectLater` on a finder matching two widgets fails outright.
//
// `pumpAndSettle` IS NOT USED AND CANNOT BE. The loading state is `ShimmerList`, and
// `lib/view/new_widgets/shimmer.dart:76` is `_controller.repeat(...)` — an animation with no end,
// so a loading screen never reaches quiescence. Every case below waits on the CONTROLLER's own
// state with `pumpUntil`, which turns "the data never arrived" into a named failure instead of a
// hang, and then drains the toast clock.
//
// EVERY CASE ASSERTS ITS PREMISE BEFORE IT ASSERTS A PIXEL. A fixture whose key is wrong parses to
// an empty list and renders a convincing empty state — this repository has frozen that picture
// twice — so each case checks the controller filled AND that a row's text is really on screen
// before the comparison runs. A baseline of an empty list that nobody noticed is worse than no
// baseline, because it is then defended for ever.
//
// NOTHING IS ASSERTED UNTIL A HUMAN HAS LOOKED. Each case skips while its baseline is absent and
// says in its skip reason how to capture it. See `test/support/golden_harness.dart` for why a
// baseline committed by the agent that wrote the test is worth nothing.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/view/screen/coupon_screen/coupon_screen.dart';
import 'package:store_go_app/view/screen/customers/customer_screen.dart';
import 'package:store_go_app/view/screen/order_screen/order_screen.dart';
import 'package:store_go_app/view/screen/product_screen/products_screen.dart';

import '../support/golden_harness.dart';
import '../support/list_page_fixtures.dart';
import '../support/screen_harness.dart';

void main() {
  // `initScreenHarness` loads the fonts, so `loadAppFonts` is not called separately here: without
  // it every glyph in the baseline would be the test font's filled box.
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);

  // `resetScreenHarness` clears GetX and restores the process-global `AppColor` to its light
  // values — trap 2 in golden_harness.dart. A dark case that did not restore would leave every
  // later light case rendering dark tokens.
  tearDown(resetScreenHarness);

  bool skipUnlessCaptured(String surface, GoldenCombination combination) {
    if (goldenReady(surface, combination)) return false;
    markTestSkipped(goldenSkipReason(surface, combination));
    return true;
  }

  for (final combination in kFourCombinations) {
    testWidgets(
      'the customers screen renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('customers-screen', combination)) return;

        final api = ApiStub()..on('customerlist', customerListPage());
        final controller = CustomerController();

        await pumpScreen(
          tester,
          const CustomerScreen(),
          api: api,
          combination: combination,
          // A BLOCK BODY, NEVER AN ARROW. `register:` is `void Function()`, so
          // `register: () => Get.put(controller)` infers `Get.put<void>` from that context and the
          // screen's own `Get.find<CustomerController>()` throws "not found".
          register: () {
            Get.put(controller);
          },
        );

        await pumpUntil(
          tester,
          () => controller.customerList.isNotEmpty,
          reason: 'the customer list never filled — check the fixture\'s keys against '
              'CustomerModel.fromJson before assuming the screen is at fault',
        );

        await drainToasts(tester);

        expect(tester.takeException(), isNull);
        expect(api.sawRequestFor('customerlist'), isTrue,
            reason: 'premise: the screen really fetched through the stub. A screen that fetched '
                'nothing and a screen whose fetch was never intercepted look identical on screen');
        expect(controller.customerList.length, 3,
            reason: 'the fixture carries three customers; a different count means a parse problem '
                'and the baseline would freeze a short list');
        expect(find.textContaining('أمينة'), findsWidgets,
            reason: 'the first customer\'s name is not rendered, so the baseline would freeze an '
                'empty list with a full controller behind it');

        await expectLater(
          find.byKey(kCaptureBoundaryKey),
          matchesGoldenFile(goldenPath('customers-screen', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the products screen renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('products-screen', combination)) return;

        final api = ApiStub()..on('productlist', productListPage());
        final controller = ProductController();

        await pumpScreen(
          tester,
          const ProductsScreen(isBack: false),
          api: api,
          combination: combination,
          register: () {
            Get.put(controller);
          },
        );

        await pumpUntil(
          tester,
          () => controller.productList.isNotEmpty,
          reason: 'the product list never filled — ProductModelData is the paginator shape, so the '
              'rows live at data.data, and ProductData uses typed casts',
        );

        await drainToasts(tester);

        expect(tester.takeException(), isNull);
        expect(api.sawRequestFor('productlist'), isTrue,
            reason: 'premise: the screen really fetched through the stub');
        expect(controller.productList.length, 2);
        expect(find.textContaining('قميص'), findsWidgets,
            reason: 'the first product\'s name is not rendered, so the baseline would freeze an '
                'empty grid');

        await expectLater(
          find.byKey(kCaptureBoundaryKey),
          matchesGoldenFile(goldenPath('products-screen', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    // ---- WAVE 5 ---------------------------------------------------------------------------
    //
    // THE ORDERS LIST IS THE SCREEN A MERCHANT LIVES ON, and it is the one surface whose status
    // vocabulary this project has already measured twice: `status_badge_golden_test.dart`
    // photographs all ten `delivered_status` chips as a catalogue, and wave 2 found the light
    // set has no boundary contrast. This puts two of those chips back where a merchant meets
    // them -- inside the real row, at the real size, beside a price and a date.
    testWidgets(
      'the orders screen renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('orders-screen', combination)) return;

        // `toporder` answers EMPTY deliberately: the header counts a top-orders slot into
        // itemCount when one exists (`order_screen.dart:364`), and the ordinary list is the
        // surface under test. A populated strip is a different picture with its own card.
        final api = ApiStub()
          ..on('toporder', <String, Object?>{'status': 1, 'data': <Object?>[]})
          ..on('orderlist', orderListPage());
        late final OrderController controller;

        await pumpScreen(
          tester,
          const OrderScreen(),
          api: api,
          combination: combination,
          register: () {
            controller = Get.put(OrderController());
          },
        );

        await pumpUntil(
          tester,
          () => controller.orderList.length >= 2,
          reason: 'the orders never loaded. The controller de-duplicates by id, so a fixture '
              'whose two rows shared an id would stop here too. Calls: ${api.calls}',
        );

        await drainToasts(tester);

        expect(tester.takeException(), isNull);
        expect(api.sawRequestFor('orderlist'), isTrue,
            reason: 'premise: the screen really fetched through the stub');
        expect(find.textContaining('SS-1042'), findsWidgets,
            reason: 'the second order is not rendered, so the baseline would freeze a short list');

        await expectLater(
          find.byKey(kCaptureBoundaryKey),
          matchesGoldenFile(goldenPath('orders-screen', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    // THE COUPONS LIST, because the card it is made of was repaired one commit ago and nobody
    // has seen the result in situ. `coupon-card-column` photographs the card on a bare Scaffold;
    // this is the same card in the list it really ships in, which is the distinction
    // `3727efc` showed matters -- a component can be wrong in a box and right on its screen.
    testWidgets(
      'the coupons screen renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('coupons-screen', combination)) return;

        final api = ApiStub()..on('couponlist', couponListPage());
        final controller = NewCouponController();

        await pumpScreen(
          tester,
          const CouponScreen(),
          api: api,
          combination: combination,
          register: () {
            Get.put(controller);
          },
        );

        await pumpUntil(
          tester,
          () => controller.couponsList.isNotEmpty,
          reason: 'the coupon list never filled — CouponData reads coupon_name/coupon_code, not '
              'name/code, and a near-miss renders a convincing empty state',
        );

        await drainToasts(tester);

        expect(tester.takeException(), isNull);
        expect(api.sawRequestFor('couponlist'), isTrue,
            reason: 'premise: the screen really fetched through the stub');
        expect(controller.couponsList.length, 2);
        expect(find.textContaining('EID25'), findsWidgets,
            reason: 'the first coupon code is not rendered');

        await expectLater(
          find.byKey(kCaptureBoundaryKey),
          matchesGoldenFile(goldenPath('coupons-screen', combination)),
        );
      },
      tags: const <String>['golden'],
    );
  }
}
