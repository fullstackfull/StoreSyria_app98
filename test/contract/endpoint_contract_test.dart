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
// RE-MEASURED against repo A's committed manifest
// (tests/Support/ApiContract/manifests/flutter-endpoints.json: base_path
// "/api/admin", 89 endpoint entries of which 81 uncommented, 16 fragments).
// All 81 endpoint paths are byte-identical in both directions and all 16
// fragment field names match: zero drift.
//
// TWO GAPS that measurement exposed, which is why this file grew:
//
//   1. THREE endpoints were missing from both sides. order_repository.dart
//      wrote "/orders/update-status", "/orders/notes/create" and
//      "/orders/notes/delete" as literals instead of declaring them here, so
//      they were absent from the manifest and from this contract: three live
//      endpoints that the server side had no record of the app calling. They
//      are now API constants, which brings the client half to 84. Repo A's
//      manifest still lists 81 and must be regenerated -- recorded as a
//      cross-repo dependency, not edited from here.
//   2. The manifest records fragments by field NAME ONLY, with no values, so
//      a fragment VALUE change (`?store_id=` to `?storeId=`) is invisible to
//      the server-side checker. The published declaration this file keeps in
//      sync (client-endpoints.json) carries the values, so the server side
//      can diff them.
//
// These tests read the real compiled `API` fields rather than grepping the
// source, so a field that is RENAMED or DELETED breaks compilation here --
// which is the loudest possible failure and exactly what is wanted. A field
// that is ADDED cannot break compilation, so `the contract covers every
// endpoint the class declares` parses the source to catch that case.

import 'dart:convert';
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
    'createOrderNoteUrl': '/orders/notes/create',
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
    'deleteOrderNoteUrl': '/orders/notes/delete',
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
    'updateOrderStatusUrl': '/orders/update-status',
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
    'createOrderNoteUrl': API.createOrderNoteUrl,
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
    'deleteOrderNoteUrl': API.deleteOrderNoteUrl,
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
    'updateOrderStatusUrl': API.updateOrderStatusUrl,
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

  // =========================================================================
  // Nothing may bypass the API class.
  //
  // Everything above tests the CONSTANTS. All of it is worth nothing if a
  // repository writes its path inline, because then neither this file nor
  // repo A's generated manifest can see that endpoint at all. That was not
  // hypothetical: order_repository.dart did it three times, and those three
  // endpoints were missing from the manifest the server side checks against.
  //
  // The scan reads raw source with line comments dropped -- deliberately NOT
  // codeOnly(), which blanks string literals and would be blind to exactly
  // what is being looked for here.
  // =========================================================================

  group('nothing bypasses the API class', () {
    List<String> codeLines(File file) => file
        .readAsStringSync()
        .split('\n')
        .map((l) => l.trimLeft().startsWith('//') ? '' : l)
        .toList();

    test('no endPoint is assigned a literal path', () {
      final offenders = <String>[];
      var assignments = 0;

      // Either quote style. The double-quote form is the one that shipped,
      // and a single-quote-only grep is how it stayed hidden.
      final literal = RegExp('endPoint' r'\s*=\s*' '["' "']/");
      final anyAssignment = RegExp('endPoint' r'\s*=');

      for (final file in libDartFiles()) {
        final lines = codeLines(file);

        for (var i = 0; i < lines.length; i++) {
          if (anyAssignment.hasMatch(lines[i])) assignments++;
          if (literal.hasMatch(lines[i])) {
            offenders.add('${relative(file)}:${i + 1}:${lines[i].trim()}');
          }
        }
      }

      expect(
        assignments,
        greaterThanOrEqualTo(25),
        reason: 'Only $assignments endPoint assignments were found, so this '
            'scan has stopped matching the repositories and has gone vacuous.',
      );

      expect(
        offenders,
        isEmpty,
        reason: 'Declare the path in lib/utils/base_api.dart and add it to '
            'this contract, then regenerate repo A\'s manifest. A path only '
            'the repository knows about is a route the server can delete '
            'without anything failing until a merchant\'s phone calls it.\n'
            '${offenders.join('\n')}',
      );
    });

    test('no literal path is handed straight to the network layer', () {
      final offenders = <String>[];

      final inline = RegExp(
        r'(getRequest|postRequest|putRequest|deleteRequest|patchRequest)\s*\(\s*'
        '["' "']/",
      );

      for (final file in libDartFiles()) {
        final lines = codeLines(file);

        for (var i = 0; i < lines.length; i++) {
          if (inline.hasMatch(lines[i])) {
            offenders.add('${relative(file)}:${i + 1}:${lines[i].trim()}');
          }
        }
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('the regexes match the defect they are supposed to catch', () {
      // The three literals that really shipped, so a typo cannot make the two
      // scans above silently green.
      final literal = RegExp('endPoint' r'\s*=\s*' '["' "']/");

      expect(
        literal.hasMatch('    String endPoint = "/orders/update-status";'),
        isTrue,
      );
      expect(
        literal.hasMatch("    String endPoint = '/orders/notes/create';"),
        isTrue,
      );
      expect(
        literal.hasMatch(
          '    String endPoint = "\${API.taxListUrl}\${API.storeIdUrl}";',
        ),
        isFalse,
      );
    });

    test('only base_api.dart knows the /api/ base path', () {
      // A full URL pasted into a controller would survive every test above
      // and would not move when the base path does.
      final offenders = <String>[];

      for (final file in libDartFiles()) {
        final path = relative(file);
        if (path == 'lib/utils/base_api.dart') continue;

        final lines = codeLines(file);

        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('/api/')) {
            offenders.add('$path:${i + 1}:${lines[i].trim()}');
          }
        }
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  });

  // =========================================================================
  // The published declaration.
  //
  // Repo A's manifest is GENERATED FROM this app, so regenerating it absorbs
  // drift silently -- the known weakness of the server-side jaw.
  // test/contract/client-endpoints.json is the opposite: committed HERE and
  // verified against the real constants, so the server side has a file it can
  // diff rather than a generator it has to trust. It also carries the
  // fragment VALUES, which the manifest does not record at all.
  // =========================================================================

  group('the published client declaration stays in sync', () {
    late Map<String, dynamic> published;

    setUpAll(() {
      published = jsonDecode(
        File('${packageRoot().path}/test/contract/client-endpoints.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
    });

    test('its endpoints are exactly the contracted endpoints', () {
      expect(
        Map<String, String>.from(published['endpoints'] as Map),
        expectedEndpoints,
        reason: 'test/contract/client-endpoints.json and this contract '
            'disagree. The JSON is what the server side diffs against, so it '
            'has to move in the same commit as the constant.',
      );
    });

    test('its fragments are exactly the contracted fragments', () {
      expect(
        Map<String, String>.from(published['fragments'] as Map),
        expectedFragments,
      );
    });

    test('it publishes the live base url and base path', () {
      expect(published['base_url'], API.baseUrl);
      expect(API.baseUrl, endsWith(published['base_path'] as String));
    });

    test('the counts are stated, so a silent addition cannot pass', () {
      // Repo A's manifest declares 81 endpoints and 16 fragments. The client
      // is at 84 because three endpoints that were inline literals are now
      // declared; the manifest must be regenerated to match. When an 85th
      // appears this fails, and the regeneration question gets asked again
      // instead of being forgotten.
      expect(expectedEndpoints.length, 84);
      expect(expectedFragments.length, 16);
      expect((published['endpoints'] as Map).length, 84);
      expect((published['fragments'] as Map).length, 16);
    });
  });

  // =========================================================================
  // Composition. The shape tests above check each constant alone; these
  // assemble the real strings the repositories build and parse them, because
  // a '?' and an '&' in the wrong order produce a URL that is perfectly valid
  // and carries the wrong parameters.
  // =========================================================================

  group('composed URLs parse the way the server reads them', () {
    test('a list endpoint carries store_id and page as separate parameters',
        () {
      // Verbatim the composition in tax_repository.dart:8,
      // category_repository.dart:7, shipping_repository.dart:8,
      // coupon_repository.dart:7 and order_repository.dart:30.
      final uri = Uri.parse(
        '${API.baseUrl}${API.taxListUrl}${API.storeIdUrl}7${API.andPageUrl}2',
      );

      expect(uri.scheme, 'https');
      expect(uri.path, '/api/admin/taxlist');
      expect(uri.queryParameters, {'store_id': '7', 'page': '2'});
    });

    test('an id endpoint carries store_id and the record id', () {
      // order_repository.dart:140 and :75.
      final uri = Uri.parse(
        '${API.baseUrl}${API.viewOrderUrl}${API.storeIdUrl}7'
        '${API.orderIdUrl}1234',
      );

      expect(uri.path, '/api/admin/vieworder');
      expect(uri.queryParameters, {'store_id': '7', 'order_id': '1234'});
    });

    test('the delivery-boy fragment is a path segment, not a parameter', () {
      // deliveryBoyIdUrl is '/', so the id lands in the PATH and store_id is
      // still the first query parameter. delivery_boy_repository.dart:33.
      final uri = Uri.parse(
        '${API.baseUrl}${API.updateDeliveryBoyUrl}${API.deliveryBoyIdUrl}9'
        '${API.storeIdUrl}7',
      );

      expect(uri.path, '/api/admin/deliveryboysUpdate/9');
      expect(uri.queryParameters, {'store_id': '7'});
    });

    test('the order-note delete URL is unchanged by being de-inlined', () {
      // order_repository.dart:128 built this as one literal with the path
      // baked in. The constant plus fragments must produce the SAME bytes --
      // a difference here would be a wire change, not a refactor.
      final composed =
          '${API.deleteOrderNoteUrl}${API.storeIdUrl}7&order_id=12&note_id=3';

      expect(
        composed,
        '/orders/notes/delete?store_id=7&order_id=12&note_id=3',
      );

      final uri = Uri.parse('${API.baseUrl}$composed');

      expect(uri.path, '/api/admin/orders/notes/delete');
      expect(uri.queryParameters, {
        'store_id': '7',
        'order_id': '12',
        'note_id': '3',
      });
    });

    test('and the two order-note POST paths are unchanged too', () {
      expect(API.updateOrderStatusUrl, '/orders/update-status');
      expect(API.createOrderNoteUrl, '/orders/notes/create');
    });

    test('a swapped separator really does break, so these have teeth', () {
      // With '?' used twice, Uri still parses -- it just reads the whole tail
      // as ONE parameter value, which is why this class of defect is
      // invisible without parsing. Asserted so the tests above are known to
      // be capable of failing.
      final wrong = Uri.parse(
        '${API.baseUrl}${API.taxListUrl}${API.storeIdUrl}7${API.pageUrl}2',
      );

      expect(wrong.queryParameters, {'store_id': '7?page=2'});
      expect(wrong.queryParameters.containsKey('page'), isFalse);
    });
  });
}
