// ROUTE 1 · wave 3 — the LIST and GRID cards: products, coupons, the settings grid and the home
// stat tiles.
// =================================================================================================
//
// WAVE 1 PHOTOGRAPHED THE CUSTOMER AND DELIVERY-MAN CARDS. These are the other four card families
// a merchant actually spends the day looking at, and each is its own row in the Phase 2.5
// inventory: "Product card / field partials", "Coupons list", "More / Settings grid (tab 4)" and
// "Home widgets (stat tiles, QR, profile row)".
//
// WHY EACH ONE IS CAPTURED IN SEVERAL STATES RATHER THAN ONE.
//
//   product-card-grid   `allProductsListItemWidget` is four different pictures, not one with a
//                       different word in it: the hidden chip (status 0), the out-of-stock
//                       colour, the untracked-stock row and the plain in-stock card are four
//                       branches, and a card captured only in its happy state says nothing about
//                       the other three. `imageUrl: ''` deliberately, so the validity check fails
//                       and the placeholder renders — no golden may depend on a network fetch.
//
//                       `salePrice` IS NOT ONE OF THE FOUR, AND THE FIRST CAPTURE IS WHY. The
//                       specimen originally passed `salePrice: '12.00'` beside `price: '18.00'`,
//                       expecting a struck-through pair — and the card rendered `18.00` alone.
//                       `salePrice` appears exactly ONCE in `product_widget.dart`, on line 25, in
//                       the signature: it is declared and never read. The card's only call site
//                       (`products_screen.dart:689-712`) does not pass it either, and says why —
//                       it reads the server's resolved `final_price` instead, because
//                       `sale_price` defaults to 0 for every undiscounted product. So the
//                       parameter is dead API rather than a rendering defect, and a baseline that
//                       passed it would photograph a question with no answer in the picture.
//                       `component_gallery_capture_test.dart`'s specimen passes it and captions
//                       that card "on sale", so that caption describes something its own capture
//                       does not show.
//   coupon-card-column  `productCouponWidget` switches on `status == 1`, which drives the
//                       `statusPill` inside it, and on `couponType`, which decides whether the
//                       discount reads `15%` or a bare figure. Both states in one image.
//   setting-card-grid   `settingCard` is the tile the More and Store Settings grids are built
//                       from, and its icon tint and chevron alpha were BOTH repaired for contrast
//                       (`settings_card.dart:60-80`) — a repair whose result nobody has seen.
//   home-stat-tiles     `totalProductWidget(permitted: false)` is not a styling variant: it swaps
//                       the figure for an em dash, and the author's own comment says why ("an
//                       empty tile reads as a rendering failure"). A permitted tile and a refused
//                       tile are two pictures and only one of them has ever been reviewed.
//
// THE GRID GEOMETRY IS THE APP'S OWN, COPIED NOT GUESSED. `products_screen.dart:782-786` lays the
// product cards out with `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220.w,
// crossAxisSpacing: 14.w, mainAxisSpacing: 16.h, mainAxisExtent: 290.h)`, and
// `store_setting_screen.dart:52-57` uses a 2-column grid with 14pt gaps and a square aspect. Both
// are reproduced exactly, because sizing a card to anything else photographs a layout no merchant
// ever sees — and because the card's inner `Expanded` throws "RenderFlex children have non-zero
// flex but incoming height constraints are unbounded" the moment it is given a free height, which
// is a harness mismatch rather than a defect in the card.
//
// SERVER-SHAPED DATA, NOT KEYS, for everything the server really supplies: product and coupon
// names, prices, codes and dates. Keys for everything the app translates. The mistake in the other
// direction is recorded twice in `component_gallery_capture_test.dart` — a specimen given invented
// English renders as English inside the Arabic image and reads as a missing translation in the
// component, when the specimen is what was wrong. Every value below is invented: no real merchant
// or customer data goes in a fixture or a screenshot.
//
// NOTHING IS ASSERTED UNTIL A HUMAN HAS LOOKED. Each case skips while its baseline is absent.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/new_widgets/coupon_widget.dart';
import 'package:store_go_app/view/new_widgets/settings_card.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';

import '../support/golden_harness.dart';

// The only scaffolding in these images, and here it is also the real one: every one of these
// grids and lists sits inside a padded body on its own screen.
const double kCardGutter = 12;

void main() {
  // `path_provider` HAS TO BE ANSWERED, and finding that out cost a capture run.
  //
  // `buildProfileTitle` draws the avatar with `CachedNetworkImage`
  // (`home_screen_widget.dart:192`), which reaches `flutter_cache_manager`, which calls
  // `getTemporaryDirectory()` — a plugin method channel with NO implementation in a plain widget
  // test. The case threw `MissingPluginException(No implementation found for method
  // getTemporaryDirectory on channel plugins.flutter.io/path_provider)` before it could capture
  // anything.
  //
  // `test/support/screen_harness.dart:103-108` already answers this channel with a throwaway
  // directory for the screen tests; the golden harness does not, because none of waves 1 and 2
  // touched an image. Answered here rather than in `golden_harness.dart` so the other golden
  // files stay free of a plugin stub they do not need.
  late final Directory cacheDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    cacheDir = Directory.systemTemp.createTempSync('ss_golden_cards');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => cacheDir.path,
    );

    await loadAppFonts();
  });

  tearDownAll(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );

    if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
  });

  // See trap 2 in golden_harness.dart: ThemeController.theme mutates the process-global AppColor.
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  // Runtime skip, not `skip:` — see the note in customer_card_golden_test.dart.
  bool skipUnlessCaptured(String surface, GoldenCombination combination) {
    if (goldenReady(surface, combination)) return false;
    markTestSkipped(goldenSkipReason(surface, combination));
    return true;
  }

  for (final combination in kFourCombinations) {
    testWidgets(
      'the product card renders its four states as their baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('product-card-grid', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(kCardGutter),
              child: SizedBox(
                width: kGoldenDesignSize.width - kCardGutter * 2,
                // Two rows of the real grid: 2 x 290 plus one 16pt gap.
                height: 290.h * 2 + 16.h,
                child: GridView(
                  // The grid itself must not scroll in a baseline: a scrollable that can settle
                  // at a different offset is a baseline that differs for a reason nobody can see.
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220.w,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 16.h,
                    mainAxisExtent: 290.h,
                  ),
                  children: <Widget>[
                    allProductsListItemWidget(
                      context: context,
                      imageUrl: '',
                      categoryName: 'Textiles',
                      productId: '41',
                      productName: 'Damask Cotton Scarf',
                      price: '24.00',
                      status: 1,
                      trackStock: true,
                      stock: '12',
                      rating: 4.0,
                      showChangeAction: true,
                    ),
                    allProductsListItemWidget(
                      context: context,
                      imageUrl: '',
                      categoryName: 'Homeware',
                      productId: '42',
                      productName: 'Brocade Cushion Cover',
                      price: '38.00',
                      status: 0,
                      trackStock: true,
                      stock: '6',
                      showChangeAction: true,
                    ),
                    allProductsListItemWidget(
                      context: context,
                      imageUrl: '',
                      categoryName: 'Soaps',
                      productId: '43',
                      productName: 'Aleppo Laurel Soap',
                      price: '9.00',
                      status: 1,
                      trackStock: true,
                      stock: '0',
                      showChangeAction: true,
                    ),
                    // THE UNTRACKED BRANCH: `trackStock: false` replaces the stock figure with
                    // the "Not Tracked" note, which is a different row from "Stock: 0".
                    allProductsListItemWidget(
                      context: context,
                      imageUrl: '',
                      categoryName: 'Textiles',
                      productId: '44',
                      productName: 'Linen Tea Towel Set',
                      price: '18.00',
                      status: 1,
                      trackStock: false,
                      stock: '30',
                      showChangeAction: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('product-card-grid', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the coupon card renders both states as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('coupon-card-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(kCardGutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  productCouponWidget(
                    context: context,
                    index: 0,
                    status: 1,
                    code: 'SPRING15',
                    name: 'Spring Textiles',
                    discount: '15',
                    couponType: 'percentage',
                    // THROUGH THE SCREEN'S OWN FORMATTER, not a hand-written string. The first
                    // version passed the literal `'31 Dec 2026'`, which froze an English month
                    // name into the Arabic baselines — and the real call site
                    // (`coupon_screen.dart:308-312`) runs the server date through
                    // `dateFormatted(... FormatType.date)`, which resolves `MMM` against the
                    // active locale. A fixture that skips the formatter photographs a date the
                    // app never prints and hides whether the localisation works.
                    date: dateFormatted(
                      date: '2026-12-31 00:00:00',
                      formatType: formatForDateTime(FormatType.date),
                    ),
                    onTap: () {},
                    viewFun: () {},
                    changeFun: () {},
                    deleteFun: () {},
                  ),
                  SizedBox(height: 12.h),
                  // THE OTHER SIDE OF BOTH SWITCHES AT ONCE: an inactive coupon drives the
                  // `statusPill`'s red branch, and a `flat` type drives the discount's bare
                  // figure instead of a percentage.
                  productCouponWidget(
                    context: context,
                    index: 1,
                    status: 0,
                    code: 'WELCOME',
                    name: 'عرض الترحيب',
                    discount: '5000',
                    couponType: 'flat',
                    date: dateFormatted(
                      date: '2026-11-01 00:00:00',
                      formatType: formatForDateTime(FormatType.date),
                    ),
                    onTap: () {},
                    viewFun: () {},
                    changeFun: () {},
                    deleteFun: () {},
                  ),
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('coupon-card-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the settings grid renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('setting-card-grid', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return Padding(
                padding: const EdgeInsets.all(kCardGutter),
                child: SizedBox(
                  width: kGoldenDesignSize.width - kCardGutter * 2,
                  // Square tiles, two per row, 14pt gaps — the real grid's own aspect ratio.
                  height: (kGoldenDesignSize.width - kCardGutter * 2 - 14) + 14,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                    children: <Widget>[
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.language2Icn,
                        title: 'store_language_and_currencies'.tr,
                        subtitle: 'manage_your_store_details'.tr,
                        function: () {},
                      ),
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.storeIcn,
                        title: 'store_information'.tr,
                        subtitle: 'manage_store_information'.tr,
                        function: () {},
                      ),
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.taxIcn,
                        title: 'tax'.tr,
                        subtitle: 'manage_store_tax'.tr,
                        function: () {},
                      ),
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.paymentIcn,
                        title: 'payment_methods'.tr,
                        subtitle: 'available_store_payment_methods'.tr,
                        function: () {},
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('setting-card-grid', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the home stat tiles and profile row render as their baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('home-stat-tiles-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(kCardGutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  totalProductWidget(
                    context,
                    image: DefaultImages.gridIcn,
                    title: 'Total'.tr,
                    subTitle: 'Products'.tr,
                    total: '17',
                    accentColor: AppColor.themeGreenColor,
                    period: 'stat_period_in_this_store'.tr,
                  ),
                  SizedBox(height: 12.h),
                  // REFUSED, so the figure becomes an em dash rather than a zero. The number 42 is
                  // passed on purpose: if the permission branch ever stops being honoured, the
                  // picture shows the figure the merchant was not allowed to see.
                  totalProductWidget(
                    context,
                    image: DefaultImages.gridIcn,
                    title: 'Total'.tr,
                    subTitle: 'Orders'.tr,
                    total: '42',
                    accentColor: AppColor.themeNavyBlueColor,
                    permitted: false,
                    period: 'stat_period_all_time'.tr,
                  ),
                  SizedBox(height: 12.h),
                  // `task:` IS NOT PASSED, and the first capture is why. It is declared on
                  // `buildProfileTitle` (`home_screen_widget.dart:107`) and referenced NOWHERE
                  // else in the file; the only call site (`home_screen.dart:145-153`) does not
                  // pass it either. The row prints the fixed "Welcome Back" line above the name
                  // instead. A specimen that supplied a store name would put a value in the
                  // picture that the widget never draws, which is the second dead parameter this
                  // wave found — `salePrice` on the product card is the other.
                  buildProfileTitle(
                    context,
                    name: 'Amina Haddad',
                  ),
                ],
              ),
            ),
          ),
        ));

        // A FIXED SCHEDULE, NOT `pumpAndSettle`, AND THE REASON IS A MEASURED ONE.
        //
        // `buildProfileTitle` puts the merchant's avatar in a `CachedNetworkImage` whose
        // placeholder is a `CircularProgressIndicator` (`home_screen_widget.dart:192-197`). A
        // widget test has no network, so that request never resolves, the spinner never stops and
        // `pumpAndSettle` TIMED OUT in all four combinations — measured, not predicted.
        //
        // SO READ THE AVATAR IN THIS BASELINE AS THE LOADING STATE, not as the steady state. That
        // is a harness condition rather than a product defect: on a device the request either
        // succeeds or fails, and a failure draws the local `Icons.person` fallback
        // (`:200-206`), which no capture taken here can reach. Everything else in the picture —
        // the two stat tiles, the name and store lines, the card and its chevron — is the real
        // steady state.
        //
        // The schedule is deterministic because a widget test drives a fake clock: the same two
        // pumps always land the spinner on the same frame. Verified by capturing twice and
        // comparing the files byte for byte.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('home-stat-tiles-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );
  }
}
