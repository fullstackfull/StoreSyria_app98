import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/core/controller/dashboard_manager_controller/dashboard_manager_controller.dart';
import 'package:store_go_app/core/controller/delivery_boy/delivery_boy_controller.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/view/screen/dashboard_manager/dashboard_manager.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-SHELL — the bottom-navigation shell and all five of its destinations.
/// =================================================================================================
///
/// **THIS IS THE FRAME EVERY MERCHANT SEES, AND IT WAS THREE OF THE THIRTEEN `BLOCKED` ROWS.**
/// `Nav destination 1 — Home/dashboard`, `2 — Orders` and `3 — Products` were blocked with "audit
/// could not determine its state; it needs to be rendered and classified" — blocked on RENDERING,
/// which is precisely what the screen harness now does. Nothing about them was undecidable; there
/// was no way to look.
///
/// WHY THESE ARE DISTINCT SURFACES FROM THE TAB SCREENS, which matters because the owner forbids
/// reusing one capture for two surfaces by name. `flutter-home_*` and `flutter-orders-list_*` are
/// the screens ALONE, mounted standalone. These are the screens **inside the shell**, with the
/// navigation bar drawn over them and a destination selected — a different widget tree, a different
/// picture, and the only place the navigation bar itself can be reviewed. Each nav capture also
/// has its own file name, and `check-distinct-surface-captures.py` would catch it if any two were
/// pixel-identical.
///
/// WHAT MOUNTING THE SHELL REALLY COSTS, measured rather than hoped for: the body is an
/// `IndexedStack` (`dashboard_manager.dart:94`), which **builds every child**, and
/// `DashboardManagerController.onInit` constructs all five screens up front. So mounting the shell
/// mounts the dashboard, the orders list, the products list, the categories tab and settings at
/// once, and every controller any of them does `Get.find` for has to be registered. That is also
/// exactly what the running app does, which is the point: this is the first test in the project
/// that exercises the whole merchant surface at once.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// The five destinations, in the order `naviBarItemList` declares them
  /// (`dashboard_manager_controller.dart:37-41`).
  const destinations = <(int, String, String)>[
    (0, 'home', 'Home'),
    (1, 'orders', 'Orders'),
    (2, 'products', 'Products'),
    (3, 'categories', 'Categories'),
    (4, 'more', 'More'),
  ];

  /// Every endpoint the five screens reach on mount. The stub answers each with a small, valid
  /// page so that no screen sits in its loading state while another is being captured — a shell
  /// capture showing four shimmering tabs would be evidence of nothing.
  ApiStub shellStub() => ApiStub()
    ..on('dashboard', <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'user': <String, Object?>{'id': 7, 'name': 'سامر الحلبي'},
        'qr-code': <String, Object?>{'url': 'u', 'name': 'متجر الشام'},
        'products': 48,
        'sales': 37,
        'order': 126,
        'user_type': 'admin',
        'permissions': <Object?>['Manage Dashboard', 'Manage Order', 'Manage Products'],
      },
    })
    ..on('toporder', <String, Object?>{'status': 1, 'data': <Object?>[]})
    ..on('orderlist', <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'current_page': 1,
        'last_page': 1,
        'per_page': 10,
        'total': 1,
        'data': <Object?>[
          <String, Object?>{
            'id': 1042,
            'product_order_id': 'SS-1042',
            'order_id_string': 'SS-1042',
            'user_name': 'Marwan Haddad',
            'order_date': '2026-11-08',
            'final_price': '126500',
            'currency_symbol': 'ل.س',
            'payment_type': 'COD',
            'payment_status': 'pending',
            'delivered_status': 0,
            'delivered_status_string': 'Pending',
            'is_guest': 0,
            'store_id': 1,
          },
        ],
      },
    })
    ..on('productlist', <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'currency_symbol': r'$',
        'current_page': 1,
        'last_page': 1,
        'per_page': 10,
        'total': 1,
        'data': <Object?>[
          <String, Object?>{
            'id': 1,
            'name': 'قميص قطن دمشقي',
            'product_code': 'SS-1001',
            'price': 150,
            'sale_price': 120,
            'product_stock': 12,
            'track_stock': 1,
            'status': 1,
            'is_active': 1,
            'variant_product': 0,
          },
        ],
      },
    })
    ..on('categorylist', <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'current_page': 1,
        'last_page': 1,
        'per_page': 10,
        'total': 1,
        'data': <Object?>[
          <String, Object?>{'id': 1, 'name': 'ملابس', 'status': 1, 'store_id': 1},
        ],
      },
    });

  /// Everything the five screens `Get.find` for. `DashboardManagerController` LAST, because its
  /// `onInit` constructs all five screens and those constructors run the field initialisers that
  /// do the finding.
  void registerShell() {
    Get.put(ThemeController());
    Get.put(NotificationController());
    Get.put(OrderController());
    Get.put(ProductController());
    Get.put(CategoryController());
    Get.put(CustomerController());
    Get.put(DeliveryBoyController());
    Get.put(DashboardManagerController());
  }

  double channel(int v) {
    final c = v / 255.0;
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  double luminance(Color c) => 0.2126 * channel((c.r * 255).round()) +
      0.7152 * channel((c.g * 255).round()) +
      0.0722 * channel((c.b * 255).round());

  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  Color flatten(Color fg, Color bg) {
    final a = fg.a;
    int mix(double f, double b) => ((f * 255) * a + (b * 255) * (1 - a)).round().clamp(0, 255);
    return Color.fromARGB(255, mix(fg.r, bg.r), mix(fg.g, bg.g), mix(fg.b, bg.b));
  }

  for (final combination in kFourCombinations) {
    for (final (index, slug, _) in destinations) {
      testWidgets('the shell shows destination $index ($slug) in ${combination.name}',
          (tester) async {
        final api = shellStub();

        await pumpScreen(
          tester,
          const DashBoardManagerScreen(),
          api: api,
          combination: combination,
          register: registerShell,
        );

        /// Select the destination through the CONTROLLER, the same path the nav bar's `onTap`
        /// uses (`dashboard_manager.dart:150`). Tapping the bar itself would be a better test of
        /// the bar, but `StylishBottomBar` renders its items inside its own layout and a
        /// mis-aimed tap would silently select nothing — so the selection is driven and the bar
        /// is then measured.
        final shell = Get.find<DashboardManagerController>();
        shell.updateIndex(index);

        await pumpUntil(
          tester,
          () => shell.currantIndex.value == index,
          reason: 'the shell did not move to destination $index',
        );
        await pumpFrames(tester, frames: 16);
        await drainToasts(tester);

        expect(tester.takeException(), isNull,
            reason: 'the shell threw on destination $index in ${combination.name}');

        /// The nav bar carries all five destinations at once, whichever is selected. Finding the
        /// LABEL of the selected one is not enough — an `IndexedStack` keeps every child alive,
        /// so a label could be coming from a screen rather than from the bar.
        expect(find.byType(DashBoardManagerScreen), findsOneWidget);

        final context = tester.element(find.byType(DashBoardManagerScreen));
        expect(Directionality.of(context), combination.direction,
            reason: 'the shell rendered the wrong direction in ${combination.name}');
        expect(
          Theme.of(context).brightness,
          combination.dark ? Brightness.dark : Brightness.light,
          reason: 'the shell rendered the wrong brightness in ${combination.name}',
        );

        final captured = await captureScreen(
          tester,
          captureName('flutter-shell-$slug', combination),
        );
        if (captureDir != null) {
          expect(captured, isNotNull);
          expect(captured!.lengthSync(), greaterThan(1000),
              reason: 'the shell capture for $slug is suspiciously small: a blank render');
        }
      });
    }

    /* ---- P2.5-FLUTTER-COMP: THE SHELL ITSELF, AT A SECOND WIDTH --------------------------------

       The five cases above are claimed by the five `Nav destination` inventory rows, and the
       `Bottom-nav shell (DashBoardManagerScreen)` row is a SIXTH surface: the chrome those five
       share. It cannot honestly be claimed on one of their images -- the coverage-matrix
       generator refuses one picture for two surfaces, and it is right to -- so the shell gets a
       render of its own.

       A TABLET IS THE HONEST SECOND RENDER, not a second phone frame, because it answers
       something the 360pt set cannot: `StylishBottomBar` lays five destinations out for a phone,
       and whether that still reads at 768pt is a question about the SHELL rather than about any
       one destination. `golden_harness.dart` keeps `kGoldenTabletSize` for exactly this.

       The surface really is the tablet one, asserted rather than assumed: `pinGoldenSurface` is
       called inside `pumpScreen`, so passing the size and then photographing the wrong viewport
       would be invisible in the image. */
    testWidgets('the shell lays its five destinations out on a tablet in ${combination.name}',
        (tester) async {
      final api = shellStub();

      await pumpScreen(
        tester,
        const DashBoardManagerScreen(),
        api: api,
        combination: combination,
        register: registerShell,
        surface: kGoldenTabletSize,
      );

      await pumpFrames(tester, frames: 16);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'the shell threw on a tablet in ${combination.name}');

      expect(find.byType(DashBoardManagerScreen), findsOneWidget);

      final Size surface = tester.view.physicalSize / tester.view.devicePixelRatio;

      expect(surface, kGoldenTabletSize,
          reason: 'this case is meant to be the tablet render and the viewport is $surface');

      final context = tester.element(find.byType(DashBoardManagerScreen));

      expect(Directionality.of(context), combination.direction,
          reason: 'the tablet shell rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'the tablet shell rendered the wrong brightness in ${combination.name}',
      );

      final captured =
          await captureScreen(tester, captureName('flutter-shell-tablet', combination));

      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the tablet shell capture is suspiciously small: a blank render');
      }
    });
  }

  testWidgets('premise: every destination really is reachable and distinct', (tester) async {
    /// Without this, "the shell rendered" would be compatible with a shell stuck on destination 0
    /// — and all five captures would then be the same picture under five names, which is exactly
    /// what `check-distinct-surface-captures.py` exists to catch after the fact. This catches it
    /// before.
    final api = shellStub();

    await pumpScreen(tester, const DashBoardManagerScreen(), api: api, register: registerShell);

    final shell = Get.find<DashboardManagerController>();
    expect(shell.screens.length, 5,
        reason: 'the shell no longer builds five destinations');
    expect(shell.naviBarItemList.length, 5,
        reason: 'the navigation bar no longer carries five items');

    final seen = <int>{};
    for (final (index, _, _) in destinations) {
      shell.updateIndex(index);
      await pumpFrames(tester, frames: 6);
      seen.add(shell.currantIndex.value);
    }
    await drainToasts(tester);

    expect(seen, <int>{0, 1, 2, 3, 4},
        reason: 'the shell did not reach every destination: it settled on $seen');
  });

  for (final dark in <bool>[false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('$theme: an unselected navigation label is readable', (tester) async {
      /// FOUR OF THE FIVE LABELS ARE UNSELECTED AT ANY MOMENT, on the one surface that is on
      /// screen for the whole session. The bar is dark navy in BOTH themes
      /// (`cBottomNavyBlueColor`), so its inactive colour has to be a light tint in both — and in
      /// light mode it was `AppColor.cDarkGreyFont`, a grey meant for light backgrounds.
      ///
      /// The colours are read off the rendered `StylishBottomBar`, not from the source, so this
      /// measures what is drawn.
      final api = shellStub();

      await pumpScreen(
        tester,
        const DashBoardManagerScreen(),
        api: api,
        combination: kFourCombinations.firstWhere((c) => c.name == (dark ? 'dark-ltr' : 'light-ltr')),
        register: registerShell,
      );
      await pumpFrames(tester, frames: 12);
      await drainToasts(tester);

      final bar = tester.widget<StylishBottomBar>(find.byType(StylishBottomBar));
      final background = bar.backgroundColor!;
      final item = bar.items.first;

      final unselected = flatten(item.unSelectedColor, background);
      final selected = flatten(item.selectedColor, background);

      expect(contrast(selected, background), greaterThanOrEqualTo(4.5),
          reason: '$theme: the SELECTED navigation label is '
              '${contrast(selected, background).toStringAsFixed(2)}:1 on the bar');

      expect(
        contrast(unselected, background),
        greaterThanOrEqualTo(4.5),
        reason: '$theme: an unselected navigation label is only '
            '${contrast(unselected, background).toStringAsFixed(2)}:1 against the bar '
            '($unselected on $background). Four of the five are unselected at any moment, on the '
            'bar that is on screen for the whole session. The bar is dark navy in BOTH themes, so '
            'the inactive colour must be a light tint in both.',
      );
    });
  }
}
