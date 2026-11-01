// WS K. A failed refresh left the merchant reading data it had just failed to
// refresh, with nothing on screen saying so.
//
// `customer_controller.getCustomersData()`'s `onFailure` sets `errorMessage`,
// shows a 3-second toast, and steps `currantPage` back. The list is LEFT IN
// PLACE — which is correct, because blanking a list on a transient network
// failure is worse than keeping it. What was missing is the merchant being told.
//
// Three seconds later the toast is gone and the screen is indistinguishable
// from a successful refresh. The merchant acts on rows that may be hours old,
// and the section header's counts are the old counts.
//
// `customer_screen.dart:163` already handles error AND EMPTY — it shows
// `ErrorState` rather than the empty state, deliberately, because "you have no
// customers" is the worse lie (P2-07-14 records that reasoning). The gap is
// error with a NON-EMPTY list, which that branch does not reach.
//
// ------------------------------------------------------------------------
// WHAT THIS FIX DELIBERATELY DOES NOT DO, because an adversarial review showed
// both alternatives were worse:
//
//   * NO `page > 1` GUARD. The proposal wanted `currantPage` left alone on a
//     failed page-1 pull, copying `product_controller.dart:166-168`. That guard
//     is correct there ONLY because the products screen clears its list before
//     refreshing; `customer_screen` does not. With the guard, the next scroll
//     asks for page 2 and `customerList.addAll` — which, unlike
//     `order_controller.dart:471-477, has no de-duplication — appends rows the
//     list already holds. Today's step-back is a self-heal: the merchant loses
//     pages 2..n but the list stays consistent. Trading that for duplicate rows
//     is not a fix.
//
//   * NO "as of <time>" STAMP. It needs a companion cache key that
//     `CacheService.clear` does not remove (it clears only `'$_prefix$key'`),
//     so the stamp would outlive its data; and `GetMaterialApp` installs no
//     `localizationsDelegates`, so an Arabic merchant would be shown a raw
//     `toIso8601String()`.
//
// So: an inline notice driven by the observable that already exists, and
// nothing else touched.
//
// AND `errorMessage` HAD TO START BEING CLEARED. `onSuccess` never reset it, so
// a notice keyed on it would appear after the first failure and never leave —
// which is why the second group here exists.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';

void main() {
  setUpAll(() => Get.addTranslations({'en': en, 'ar': ar}));
  setUp(() => Get.locale = const Locale('en', 'US'));

  Widget host(Widget Function() build) => ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(home: Scaffold(body: build())),
  );

  group('the notice tells a merchant their list may be out of date', () {
    testWidgets('it renders the reason the server gave', (tester) async {
      await tester.pumpWidget(
        host(() => const StaleDataNotice(message: 'No internet connection')),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No internet connection'),
        findsOneWidget,
        reason:
            'the notice drops the reason, so the merchant is told '
            'something is wrong but not what',
      );
      expect(find.text('showing_older_data'.tr), findsOneWidget);
    });

    testWidgets('it offers a retry when one is given', (tester) async {
      var retried = 0;

      await tester.pumpWidget(
        host(
          () => StaleDataNotice(
            message: 'No internet connection',
            onRetry: () => retried++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('retry'.tr));
      await tester.pumpAndSettle();

      expect(
        retried,
        1,
        reason:
            'the retry control does not reach the callback, so the '
            'merchant can see the problem and not act on it',
      );
    });

    testWidgets('and announces itself, because a merchant using a screen '
        'reader is the one most likely to miss a toast', (tester) async {
      await tester.pumpWidget(
        host(() => const StaleDataNotice(message: 'No internet connection')),
      );
      await tester.pumpAndSettle();

      final semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.text('showing_older_data'.tr),
              matching: find.byType(Semantics),
            )
            .first,
      );

      expect(
        semantics.properties.liveRegion,
        isTrue,
        reason:
            'the notice is not a live region, so it appears silently for '
            'exactly the merchant who cannot see the toast either',
      );
    });

    testWidgets('in Arabic it is Arabic', (tester) async {
      Get.locale = const Locale('ar', 'SA');

      await tester.pumpWidget(
        host(() => const StaleDataNotice(message: 'لا يوجد اتصال')),
      );
      await tester.pumpAndSettle();

      expect(find.text('showing_older_data'.tr), findsOneWidget);
      expect(
        find.text('showing_older_data'),
        findsNothing,
        reason:
            'the raw key is rendering, so the string is missing from '
            'ar.dart and GetX fell back to the key itself',
      );
    });
  });

  group('and the screen actually shows it', () {
    // THE WIDGET IS USELESS IF NOTHING RENDERS IT, and a mutation is what keeps
    // this honest: reverting the wiring left every widget case above green.
    // Source-level because the screen needs a registered controller, a
    // repository and a socket to pump; the widget's own behaviour is driven
    // above.
    test('customer_screen renders StaleDataNotice on a failed refresh', () {
      final source = File(
        'lib/view/screen/customers/customer_screen.dart',
      ).readAsStringSync();

      expect(
        source.contains('StaleDataNotice('),
        isTrue,
        reason:
            'the customer list no longer shows the stale-data notice, so '
            'a failed refresh is back to a three-second toast and a screen '
            'that looks freshly loaded',
      );

      expect(
        source.contains('customerController.errorMessage.value.isNotEmpty'),
        isTrue,
        reason:
            'the notice is not keyed on the failure flag, so it either '
            'never shows or never leaves',
      );
    });
  });

  // THE FINDING NAMED THREE SURFACES, not one: customers, delivery men and the
  // product catalogue. All three share the shape — `onFailure` sets
  // `errorMessage` and leaves the rows in place — so all three get the notice.
  group('the other two lists named in the finding show it too', () {
    test('products_screen renders StaleDataNotice on a failed refresh', () {
      final source = File(
        'lib/view/screen/product_screen/products_screen.dart',
      ).readAsStringSync();

      expect(
        source.contains('StaleDataNotice('),
        isTrue,
        reason:
            'the catalogue no longer shows the stale-data notice. '
            'getProductData clears productList only inside onSuccess, so a '
            'failed page-1 refresh leaves the previous rows on screen with '
            'nothing saying so',
      );

      // NORMAL MODE ONLY. Search clears `searchResults` in its failure limb and
      // the category path clears `categoryResults` before the request, so
      // error-with-rows cannot arise in either -- the notice there could only
      // be wrong.
      expect(
        source.contains('ProductListMode.normal &&'),
        isTrue,
        reason:
            'the notice is not gated to the normal catalogue mode, so it can '
            'render over search or category results where it cannot be true',
      );
    });

    test('delivery_boy_screen renders StaleDataNotice on a failed refresh', () {
      final source = File(
        'lib/view/screen/delivery_boys/delivery_boy_screen.dart',
      ).readAsStringSync();

      expect(
        source.contains('StaleDataNotice('),
        isTrue,
        reason:
            'the delivery men list no longer shows the stale-data notice. A '
            'merchant assigning an order to a driver who has since been '
            'removed is the concrete cost',
      );
    });
  });

  group('the controller stops holding a stale failure', () {
    test('a successful page clears errorMessage', () {
      // Without this the notice, once shown, never leaves: `onSuccess` set the
      // list and left `errorMessage` at its last failure. Source-level because
      // driving the controller needs a repository and a socket; the behaviour
      // it guards is asserted by the widget cases above.
      final source = File(
        'lib/core/controller/customers/customer_controller.dart',
      ).readAsStringSync();

      // BOUNDED ON BOTH SIDES, and that is not a detail. The first draft sliced
      // from `onSuccess:` to END OF FILE, and `errorMessage.value = ''` occurs
      // THREE times in this file -- the two others are in addCustomerData and
      // updateCustomerData. So the unbounded slice stayed green with this very
      // fix reverted. A mutation is what surfaced it.
      final start = source.indexOf(
        'onSuccess:',
        source.indexOf('Future<void> getCustomersData('),
      );
      final end = source.indexOf('onFailure:', start);

      expect(
        start,
        greaterThan(0),
        reason: "premise: getCustomersData's onSuccess was found",
      );
      expect(
        end,
        greaterThan(start),
        reason: 'premise: the onSuccess block was bounded',
      );

      final onSuccess = source.substring(start, end);

      expect(
        onSuccess.contains("errorMessage.value = ''"),
        isTrue,
        reason:
            'a successful refresh does not clear errorMessage, so the '
            'stale-data notice would appear after the first failure and stay '
            'for the rest of the session',
      );
    });

    test('a successful delivery-men load clears errorMessage', () {
      final source = File(
        'lib/core/controller/delivery_boy/delivery_boy_controller.dart',
      ).readAsStringSync();

      final start = source.indexOf(
        'onSuccess:',
        source.indexOf('Future<void> getDeliveryBoysData('),
      );
      final end = source.indexOf('onFailure:', start);

      expect(
        start,
        greaterThan(0),
        reason: 'premise: the onSuccess limb was found',
      );
      expect(
        end,
        greaterThan(start),
        reason: 'premise: the onSuccess limb was bounded',
      );

      expect(
        source.substring(start, end).contains("errorMessage.value = ''"),
        isTrue,
        reason:
            'a successful load does not clear errorMessage, so the delivery '
            "men notice would never leave. The other limbs in this file clear "
            'it; the list getter was the one that did not',
      );
    });

    test('the catalogue clears errorMessage at request start', () {
      // Products differ DELIBERATELY: `getProductData` clears at request start
      // rather than in `onSuccess`, which already retires the notice. Asserted
      // where it actually is, so the test does not demand a redundant second
      // clear.
      final source = File(
        'lib/core/controller/product_controller/product_controller.dart',
      ).readAsStringSync();

      final start = source.indexOf('Future<void> getProductData(');
      final end = source.indexOf('response.fold', start);

      expect(
        start,
        greaterThan(0),
        reason: 'premise: getProductData was found',
      );
      expect(
        end,
        greaterThan(start),
        reason: 'premise: the preamble was bounded',
      );

      expect(
        source.substring(start, end).contains("errorMessage.value = ''"),
        isTrue,
        reason:
            'the catalogue no longer clears errorMessage before requesting, so '
            'the stale-data notice would survive a successful refresh',
      );
    });
  });
}
