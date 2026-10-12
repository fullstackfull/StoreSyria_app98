// Cross-repo API contract guard -- the CLIENT half.
//
// WHY THIS EXISTS. Every path below is a constant compiled into APKs and IPAs
// that are already installed on merchants' phones. An installed copy cannot be
// told that the server renamed a route: it will keep requesting the old path
// until the merchant updates, which for a long tail of devices is never. So a
// server-side rename is not a refactor, it is a silent outage scoped to
// whoever has not updated -- and it fails on the device, where nobody watching
// the server will see it.
//
// The server side of this contract lives in repo A at
// tests/Support/ApiContract/, which holds a generated manifest
// (manifests/flutter-endpoints.json) extracted from THIS file. That guards the
// server against dropping a route the app calls. It cannot guard the app
// against changing a path out from under the server, because it is generated
// FROM the app -- regenerate it and the drift is absorbed silently. This test
// is the other jaw of the vice: the expected values are written out by hand
// here, so changing base_api.dart fails until someone edits this file too, and
// editing this file is the moment to check the server agrees.
//
// VERIFIED at the time of writing: all 81 live endpoints and all 16 query
// fragments below are byte-identical to the committed manifest in repo A
// (base_path "/api/admin", 81 uncommented endpoints, 16 fragments). The
// comparison was run field by field; there was no drift in either direction.
//
// These tests read the real compiled `API` fields rather than grepping the
// source, so a field that is RENAMED or DELETED breaks compilation here --
// which is the loudest possible failure and exactly what is wanted. A field
// that is ADDED cannot break compilation, so `the contract covers every
// endpoint the class declares` parses the source to catch that case.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/utils/base_api.dart';

import '../support/source_tree.dart';

void main() {
  // Keyed by field name so a failure names the constant, not just a path.
  // Values are referenced through `API.<field>` below, so this map and the
  // class cannot drift apart without a compile error or a test failure.
  const expectedEndpoints = <String, String>{
    'addBalanceUrl': '/wallet/add-balance',
    'addCategoryUrl': '/addcategory',
    'addCouponUrl': '/addcoupon',
    'addCustomerUrl': '/AddCustomer',
    'addDeliveryBoyUrl': '/deliveryboyStore',
    'addProductUrl': '/addproduct',
    'addReviewUrl': '/addreview',
    'addShippingUrl': '/addshipping',
    'addTaxUrl': '/addtax',
    'assignOrderUrl': '/assignOrders',
    'categoryListUrl': '/categorylist',
    'changeCurrencyUrl': '/updateCurrencyApi',
    'changeLanguageUrl': '/updateStoreLanguage',
    'changeStoreUrl': '/changestore',
    'couponListUrl': '/couponlist',
    'createOrderUrl': '/createOrderViaApi',
    'createProductUrl': '/createproduct',
    'currenciesUrl': '/getCurrenciesApi',
    'customerOrdersUrl': '/customer/orders',
    'customersUrl': '/customerlist',
    'dashboardUrl': '/dashboard',
    'deductBalanceUrl': '/wallet/deduct-balance',
    'deleteCategoryUrl': '/deletecategory',
    'deleteCouponUrl': '/deletecoupon',
    'deleteCustomerUrl': '/destroyCustomer',
    'deleteDeliveryBoyUrl': '/deliveryboysDestroy',
    'deleteOrderUrl': '/deleteorder',
    'deleteProductListUrl': '/deleteproduct',
    'deleteProductUrl': '/deleteproduct',
    'deleteReviewUrl': '/deletereview/',
    'deleteShippingUrl': '/deleteshipping',
    'deleteStoreUrl': '/deletestore',
    'deleteTaxUrl': '/deletetax',
    'deliveryBoysUrl': '/deliveryboysIndex',
    'editProfileUrl': '/editprofile',
    'emailSettingUrl': '/emailsetting',
    'fcmTokenUrl': '/store/fcm-token',
    'generateCodeUrl': '/generatecode',
    'getCurrencyRatesUrl': '/get-currency-rates',
    'getEmailSettingUrl': '/getemailsetting',
    'getLoyaltySettingUrl': '/getloyalitysetting',
    'getStatesUrl': '/getStatesByCountry',
    'getStoreCurrencyLangUrl': '/getCurrentLanguageAndCurrency',
    'getStoreInfoUrl': '/getStoreInfo',
    'imageBaseUrl': '/base_url',
    'languagesUrl': '/getAvailableLanguages',
    'loginUrl': '/adminlogin',
    'logoutUrl': '/adminlogout',
    'loyaltySettingUrl': '/loyalitysetting',
    'myPlanUrl': '/indexAllPlan',
    'notificationUrl': '/notification',
    'orderListUrl': '/orderlist',
    'paymentTypesUrl': '/getActivePaymentMethods',
    'productListUrl': '/productlist',
    'reviewListUrl': '/reviewlist',
    'searchCustomerUrl': '/searchCustomerByName',
    'searchDataUrl': '/searchdata',
    'searchProductListUrl': '/searchproduct',
    'searchProductUrl': '/searchProductsByName',
    'shippingListUrl': '/shippinglist',
    'staticsDataUrl': '/staticsdata',
    'taxListUrl': '/taxlist',
    'testMailUrl': '/testmail',
    'toggleCurrencyStatusUrl': '/toggle-currency-status',
    'topOrdersUrl': '/Top_orders',
    'updateCategoryUrl': '/updatecategory',
    'updateCouponUrl': '/updatecoupon',
    'updateCurrencyRateUrl': '/update-currency-rate',
    'updateCustomerUrl': '/update-customer',
    'updateDeliveryBoyUrl': '/deliveryboysUpdate',
    'updatePassDeliveryBoyUrl': '/deliveryboysReset-password',
    'updatePasswordUrl': '/updatepassword',
    'updateProductUrl': '/updateproduct',
    'updateReviewUrl': '/updatereview',
    'updateShippingUrl': '/updateshipping',
    'updateStoreInfoUrl': '/updateStoreOwnerInfo',
    'updateTaxUrl': '/updatetax',
    'viewOrderUrl': '/vieworder',
    'viewProductUrl': '/viewproduct',
    'viewUsedCouponUrl': '/view-used-coupon',
    'walletUrl': '/wallet/transactions',
  };

  const expectedFragments = <String, String>{
    'andFromDateUrl': '&from_date=',
    'andPageUrl': '&page=',
    'andStatusUrl': '&delivered_status=',
    'andStoreIdUrl': '&store_id=',
    'andToDateUrl': '&to_date=',
    'categoryIdUrl': '&category_id=',
    'couponIdUrl': '&coupon_id=',
    'customerIdUrl': '?customer_id=',
    'deliveryBoyIdUrl': '/',
    'mainCategoryUrl': '&maincategory_id=',
    'orderIdUrl': '&order_id=',
    'pageUrl': '?page=',
    'productIdUrl': '&product_id=',
    'shippingIdUrl': '&shipping_id=',
    'storeIdUrl': '?store_id=',
    'taxIdUrl': '&tax_id=',
  };

  // Mirrors the map above onto the real fields. Written out rather than
  // generated because reflection does not exist in Dart AOT, and because a
  // generated version would re-derive the values from the same source it is
  // supposed to be checking.
  final actualEndpoints = <String, String>{
    'addBalanceUrl': API.addBalanceUrl,
    'addCategoryUrl': API.addCategoryUrl,
    'addCouponUrl': API.addCouponUrl,
    'addCustomerUrl': API.addCustomerUrl,
    'addDeliveryBoyUrl': API.addDeliveryBoyUrl,
    'addProductUrl': API.addProductUrl,
    'addReviewUrl': API.addReviewUrl,
    'addShippingUrl': API.addShippingUrl,
    'addTaxUrl': API.addTaxUrl,
    'assignOrderUrl': API.assignOrderUrl,
    'categoryListUrl': API.categoryListUrl,
    'changeCurrencyUrl': API.changeCurrencyUrl,
    'changeLanguageUrl': API.changeLanguageUrl,
    'changeStoreUrl': API.changeStoreUrl,
    'couponListUrl': API.couponListUrl,
    'createOrderUrl': API.createOrderUrl,
    'createProductUrl': API.createProductUrl,
    'currenciesUrl': API.currenciesUrl,
    'customerOrdersUrl': API.customerOrdersUrl,
    'customersUrl': API.customersUrl,
    'dashboardUrl': API.dashboardUrl,
    'deductBalanceUrl': API.deductBalanceUrl,
    'deleteCategoryUrl': API.deleteCategoryUrl,
    'deleteCouponUrl': API.deleteCouponUrl,
    'deleteCustomerUrl': API.deleteCustomerUrl,
    'deleteDeliveryBoyUrl': API.deleteDeliveryBoyUrl,
    'deleteOrderUrl': API.deleteOrderUrl,
    'deleteProductListUrl': API.deleteProductListUrl,
    'deleteProductUrl': API.deleteProductUrl,
    'deleteReviewUrl': API.deleteReviewUrl,
    'deleteShippingUrl': API.deleteShippingUrl,
    'deleteStoreUrl': API.deleteStoreUrl,
    'deleteTaxUrl': API.deleteTaxUrl,
    'deliveryBoysUrl': API.deliveryBoysUrl,
    'editProfileUrl': API.editProfileUrl,
    'emailSettingUrl': API.emailSettingUrl,
    'fcmTokenUrl': API.fcmTokenUrl,
    'generateCodeUrl': API.generateCodeUrl,
    'getCurrencyRatesUrl': API.getCurrencyRatesUrl,
    'getEmailSettingUrl': API.getEmailSettingUrl,
    'getLoyaltySettingUrl': API.getLoyaltySettingUrl,
    'getStatesUrl': API.getStatesUrl,
    'getStoreCurrencyLangUrl': API.getStoreCurrencyLangUrl,
    'getStoreInfoUrl': API.getStoreInfoUrl,
    'imageBaseUrl': API.imageBaseUrl,
    'languagesUrl': API.languagesUrl,
    'loginUrl': API.loginUrl,
    'logoutUrl': API.logoutUrl,
    'loyaltySettingUrl': API.loyaltySettingUrl,
    'myPlanUrl': API.myPlanUrl,
    'notificationUrl': API.notificationUrl,
    'orderListUrl': API.orderListUrl,
    'paymentTypesUrl': API.paymentTypesUrl,
    'productListUrl': API.productListUrl,
    'reviewListUrl': API.reviewListUrl,
    'searchCustomerUrl': API.searchCustomerUrl,
    'searchDataUrl': API.searchDataUrl,
    'searchProductListUrl': API.searchProductListUrl,
    'searchProductUrl': API.searchProductUrl,
    'shippingListUrl': API.shippingListUrl,
    'staticsDataUrl': API.staticsDataUrl,
    'taxListUrl': API.taxListUrl,
    'testMailUrl': API.testMailUrl,
    'toggleCurrencyStatusUrl': API.toggleCurrencyStatusUrl,
    'topOrdersUrl': API.topOrdersUrl,
    'updateCategoryUrl': API.updateCategoryUrl,
    'updateCouponUrl': API.updateCouponUrl,
    'updateCurrencyRateUrl': API.updateCurrencyRateUrl,
    'updateCustomerUrl': API.updateCustomerUrl,
    'updateDeliveryBoyUrl': API.updateDeliveryBoyUrl,
    'updatePassDeliveryBoyUrl': API.updatePassDeliveryBoyUrl,
    'updatePasswordUrl': API.updatePasswordUrl,
    'updateProductUrl': API.updateProductUrl,
    'updateReviewUrl': API.updateReviewUrl,
    'updateShippingUrl': API.updateShippingUrl,
    'updateStoreInfoUrl': API.updateStoreInfoUrl,
    'updateTaxUrl': API.updateTaxUrl,
    'viewOrderUrl': API.viewOrderUrl,
    'viewProductUrl': API.viewProductUrl,
    'viewUsedCouponUrl': API.viewUsedCouponUrl,
    'walletUrl': API.walletUrl,
  };

  final actualFragments = <String, String>{
    'andFromDateUrl': API.andFromDateUrl,
    'andPageUrl': API.andPageUrl,
    'andStatusUrl': API.andStatusUrl,
    'andStoreIdUrl': API.andStoreIdUrl,
    'andToDateUrl': API.andToDateUrl,
    'categoryIdUrl': API.categoryIdUrl,
    'couponIdUrl': API.couponIdUrl,
    'customerIdUrl': API.customerIdUrl,
    'deliveryBoyIdUrl': API.deliveryBoyIdUrl,
    'mainCategoryUrl': API.mainCategoryUrl,
    'orderIdUrl': API.orderIdUrl,
    'pageUrl': API.pageUrl,
    'productIdUrl': API.productIdUrl,
    'shippingIdUrl': API.shippingIdUrl,
    'storeIdUrl': API.storeIdUrl,
    'taxIdUrl': API.taxIdUrl,
  };

  group('endpoint paths are pinned', () {
    test('every endpoint constant still has its contracted value', () {
      // One expect per field so the failure message names the offender
      // instead of dumping an 81-entry map diff.
      for (final entry in expectedEndpoints.entries) {
        expect(
          actualEndpoints[entry.key],
          entry.value,
          reason:
              'API.${entry.key} changed from "${entry.value}" to '
              '"${actualEndpoints[entry.key]}". Installed app builds still '
              'request the old path, so the server must keep answering it '
              '(or this is a breaking release). Update repo A\'s route and '
              'its manifest together with this line.',
        );
      }
    });

    test('the mirror covers every pinned endpoint', () {
      // Guards the test itself: a field added to expectedEndpoints but not to
      // actualEndpoints would otherwise compare null against null-safe absence.
      expect(actualEndpoints.keys.toSet(), expectedEndpoints.keys.toSet());
    });

    test('every query fragment still has its contracted value', () {
      for (final entry in expectedFragments.entries) {
        expect(
          actualFragments[entry.key],
          entry.value,
          reason: 'API.${entry.key} changed; query strings will not parse '
              'server-side the way the controllers expect.',
        );
      }
    });

    test('the mirror covers every pinned fragment', () {
      expect(actualFragments.keys.toSet(), expectedFragments.keys.toSet());
    });
  });

  group('the contract is complete', () {
    test('every endpoint the class declares is covered by the contract', () {
      // A RENAMED or DELETED field is a compile error above. An ADDED one is
      // not, so parse the declarations and insist the contract knows them all.
      // Without this, a new endpoint could ship with no server-side route and
      // nothing here would notice.
      final source = File(
        '${packageRoot().path}/lib/utils/base_api.dart',
      ).readAsStringSync();

      // Comments are blanked first so the commented-out legacy constants
      // (createReviewUrl, the six payment ones, reviewStatusUrl) stay out --
      // they are deliberately dead, and repo A's manifest marks them
      // commented too. Only the NAMES are needed here; codeOnly() blanks
      // string literals, so the values are not recoverable from it and the
      // value checks are done against the real fields further up.
      final declaredNames = <String>{};
      for (final m in RegExp(
        r'static\s+(?:const\s+)?String\s+(\w+)\s*=',
      ).allMatches(codeOnly(source))) {
        declaredNames.add(m.group(1)!);
      }

      final covered = {
        ...expectedEndpoints.keys,
        ...expectedFragments.keys,
        'baseUrl', // the host, asserted separately below
      };

      final uncovered = declaredNames.difference(covered);

      expect(
        uncovered,
        isEmpty,
        reason:
            'These API constants are declared but not in the contract: '
            '$uncovered. Add each one here AND confirm repo A actually serves '
            'it, then regenerate '
            'tests/Support/ApiContract/manifests/flutter-endpoints.json.',
      );

      // Sanity: the parse found roughly what it should, so a regex that
      // silently matched nothing cannot make this test vacuous.
      expect(
        declaredNames.length,
        greaterThanOrEqualTo(97),
        reason: 'The declaration regex matched only ${declaredNames.length} '
            'constants, which means it has stopped matching base_api.dart and '
            'this test has gone vacuous.',
      );
    });
  });

  group('the base URL', () {
    test('is https, not cleartext', () {
      // An http:// base would send the bearer token in the clear on every
      // request. There is a separate guard for this in
      // test/security/no_certificate_validation_override_test.dart; this one
      // states it as part of the contract.
      expect(API.baseUrl, startsWith('https://'));
    });

    test('carries the /api/admin base path the server contract declares', () {
      // The manifest's "base_path" is exactly this. Every path above is
      // relative to it, so a change here moves all 81 endpoints at once --
      // the single most destructive edit possible in this file.
      expect(API.baseUrl, endsWith('/api/admin'));
    });

    test('has no trailing slash, so joins do not produce a double slash', () {
      // Paths all begin with '/', so a trailing slash here yields
      // "https://host/api/admin//dashboard". Laravel's router does not match
      // that, and it would fail on every endpoint simultaneously.
      expect(API.baseUrl, isNot(endsWith('/')));
    });
  });

  group('path and fragment shapes', () {
    test('every endpoint begins with a single slash', () {
      for (final entry in actualEndpoints.entries) {
        expect(entry.value, startsWith('/'), reason: 'API.${entry.key}');
        expect(
          entry.value,
          isNot(startsWith('//')),
          reason: 'API.${entry.key} would produce a protocol-relative join',
        );
      }
    });

    test('no endpoint contains whitespace or a query string', () {
      // A literal '?' baked into a path constant breaks the moment a caller
      // appends a fragment, because the result has two '?' separators.
      for (final entry in actualEndpoints.entries) {
        expect(
          entry.value,
          isNot(contains(RegExp(r'\s'))),
          reason: 'API.${entry.key} contains whitespace',
        );
        expect(
          entry.value,
          isNot(contains('?')),
          reason: 'API.${entry.key} must not embed a query separator; that is '
              'what the fragment constants are for',
        );
      }
    });

    test('a fragment is either a first-param or a subsequent-param glue', () {
      // These are concatenated onto a URL, so the separator decides whether
      // the result parses at all: '?' must be the first parameter and '&' a
      // later one. Mixing them up yields "...?store_id=1?page=2", where
      // Laravel reads the whole tail as one parameter value.
      for (final entry in actualFragments.entries) {
        if (entry.key == 'deliveryBoyIdUrl') continue; // a path separator
        expect(
          entry.value,
          anyOf(startsWith('?'), startsWith('&')),
          reason: 'API.${entry.key} is neither a "?" nor an "&" fragment',
        );
        expect(
          entry.value,
          endsWith('='),
          reason: 'API.${entry.key} must end with "=" so a value appends '
              'directly',
        );
      }
    });

    test('the "and"-prefixed fragments really are the "&" variants', () {
      // andStoreIdUrl vs storeIdUrl is the whole convention: callers pick by
      // prefix, so a flipped separator is invisible at the call site.
      for (final entry in actualFragments.entries) {
        if (entry.key.startsWith('and')) {
          expect(
            entry.value,
            startsWith('&'),
            reason: 'API.${entry.key} is named "and..." but is not an "&" '
                'fragment',
          );
        }
      }
    });

    test('storeIdUrl and andStoreIdUrl name the same parameter', () {
      // Tenancy rides on store_id. If the two spellings diverged, roughly half
      // the calls would silently drop the tenant discriminator.
      expect(API.storeIdUrl, '?store_id=');
      expect(API.andStoreIdUrl, '&store_id=');
    });
  });
}
