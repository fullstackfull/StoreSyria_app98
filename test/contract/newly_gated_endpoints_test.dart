// The CLIENT half of the authentication half of the API contract.
//
// endpoint_contract_test.dart pins WHAT the paths are. This file pins WHICH OF
// THEM NOW NEED A TOKEN, and that the app supplies one.
//
// WHY A SEPARATE FILE. Repo A's integration branch did not change a single
// endpoint path, but it did change who may call nine of them. Measured against
// repo A main (efe05d9f) rather than quoted -- `git diff efe05d9f..167c73ff --
// routes/api.php` -- these nine moved from "no authentication middleware at
// all" to `['custom.auth', ...]`:
//
//   routes/api.php:181-187  categorylist, productlist, variantlist, orderlist,
//                           couponlist, shippinglist, taxlist
//   routes/api.php:155      adminlogout
//   routes/api.php:221-230  /orders/notes/create, /orders/notes/delete
//
// TWO CORRECTIONS THAT MEASUREMENT FORCED, both of which a reader of the
// change summary would otherwise carry forward:
//
//   1. The summary describes "seven admin-API list endpoints, six of them
//      called from repo B". That undercounts. THREE MORE endpoints were
//      newly gated and ALL THREE are called from this app: adminlogout
//      (auth_controller.dart:89), /orders/notes/create
//      (order_repository.dart:108) and /orders/notes/delete
//      (order_repository.dart:129). /orders/update-status is NOT among them --
//      it already carried custom.auth on main (api.php:155-157 there) -- which
//      is exactly the kind of near-miss that makes a hand-kept list unsafe.
//      So the count is nine, not six, and this file is the list.
//
//   2. The summary also states that "no endpoint was removed or renamed; every
//      routes/api.php change is middleware-only". One endpoint WAS removed:
//      `GET /api/delivery-syria/zid-statuses-test`. It is harmless to this
//      app -- nothing under lib/ or test/ mentions it, which the last test
//      below keeps true -- but "middleware-only" is not an accurate
//      description of that diff and should not be repeated.
//
// WHAT GOES WRONG IF THIS DRIFTS. A gated endpoint called without a token gets
// 401, and network.dart maps ANY 401 to Prefs.clear() plus a bounce to the
// login screen. So a single request that forgets the token does not merely
// fail: it logs the merchant out. Six of these nine are the screens a merchant
// opens first, so the visible symptom would be "the app signs me out when I
// open products", with nothing in the product code to point at.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

import '../support/source_tree.dart';

void main() {
  /// The nine, as the contracted path plus the one client file that calls it.
  /// Written out by hand: a generated list would absorb drift silently, which
  /// is the whole failure mode this guards.
  const gated = <String, String>{
    '/categorylist': 'lib/config/repository/category_repository.dart',
    '/productlist': 'lib/config/repository/product_repository.dart',
    '/orderlist': 'lib/config/repository/order_repository.dart',
    '/couponlist': 'lib/config/repository/coupon_repository.dart',
    '/shippinglist': 'lib/config/repository/shipping_repository.dart',
    '/taxlist': 'lib/config/repository/tax_repository.dart',
    '/adminlogout': 'lib/core/controller/auth/auth_controller.dart',
    '/orders/notes/create': 'lib/config/repository/order_repository.dart',
    '/orders/notes/delete': 'lib/config/repository/order_repository.dart',
  };

  /// The constants in `API` that hold those paths.
  const gatedConstants = <String, String>{
    'categoryListUrl': '/categorylist',
    'productListUrl': '/productlist',
    'orderListUrl': '/orderlist',
    'couponListUrl': '/couponlist',
    'shippingListUrl': '/shippinglist',
    'taxListUrl': '/taxlist',
    'logoutUrl': '/adminlogout',
    'createOrderNoteUrl': '/orders/notes/create',
    'deleteOrderNoteUrl': '/orders/notes/delete',
  };

  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    storageDir = Directory.systemTemp.createTempSync('store_go_gated_test');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();
  });

  tearDownAll(() {
    // Same errno 39 (ENOTEMPTY) race as nested_api_read_test.dart and
    // forced_logout_test.dart: GetStorage flushes in the background and can
    // recreate a file mid-walk. A cleanup race must not redden a green suite.
    try {
      if (storageDir.existsSync()) storageDir.deleteSync(recursive: true);
    } catch (_) {
      // Intentionally ignored.
    }
  });

  setUp(() async {
    await Prefs.clear();
  });

  // ---------------------------------------------------------------------------
  group('the newly gated set is pinned', () {
    test('every one of the nine paths is still the contracted value', () {
      final actual = <String, String>{
        'categoryListUrl': API.categoryListUrl,
        'productListUrl': API.productListUrl,
        'orderListUrl': API.orderListUrl,
        'couponListUrl': API.couponListUrl,
        'shippingListUrl': API.shippingListUrl,
        'taxListUrl': API.taxListUrl,
        'logoutUrl': API.logoutUrl,
        'createOrderNoteUrl': API.createOrderNoteUrl,
        'deleteOrderNoteUrl': API.deleteOrderNoteUrl,
      };

      expect(
        actual,
        gatedConstants,
        reason: 'A path under custom.auth changed on the client. Confirm the '
            'server agrees before editing this expectation.',
      );
    });

    test('there are nine of them, so a silent addition cannot pass', () {
      expect(gated.length, 9);
      expect(gatedConstants.length, 9);
      expect(gatedConstants.values.toSet(), gated.keys.toSet());
    });

    test('variantlist is gated on the server but absent from the client', () {
      // The seventh list endpoint. It is NOT called here, which is why it is
      // not in the nine -- recorded so that adding it is a deliberate act
      // that has to pass through this file and consider the token.
      // The pattern must match a PATH, not an identifier. A bare
      // case-insensitive `variant-?list` reddened this test on
      // add_product_controller.dart:55-56, where `variantList` is a local
      // RxList of categories and has nothing to do with the route -- the same
      // over-matching mistake that made "contact.us" match
      // contact_us_banner_title elsewhere in this project. So the slash is
      // required, which is what distinguishes a route from a variable.
      final hits = <String>[];

      for (final file in libDartFiles()) {
        final source = commentsStripped(file.readAsStringSync());
        if (RegExp(r'/variant-?list', caseSensitive: false)
            .hasMatch(source)) {
          hits.add(relative(file));
        }
      }

      expect(
        hits,
        isEmpty,
        reason: 'variantlist is now behind custom.auth. If the app starts '
            'calling it, add it to the nine above and route it through a '
            'NetworkHttps verb. Found in:\n${hits.join('\n')}',
      );
    });

    test('the one endpoint repo A actually removed is not called here', () {
      // GET /api/delivery-syria/zid-statuses-test was deleted outright in
      // repo A's integration branch. An installed APK cannot be told a route
      // is gone, so this stays asserted rather than assumed.
      final hits = <String>[];

      for (final file in libDartFiles()) {
        final source = commentsStripped(file.readAsStringSync());
        if (source.contains('zid-statuses-test') ||
            source.contains('zidStatuses')) {
          hits.add(relative(file));
        }
      }

      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  });

  // ---------------------------------------------------------------------------
  group('each gated endpoint is reached only through a token-bearing path', () {
    test('its one caller routes through NetworkHttps', () {
      // Two token-bearing shapes exist and only two: a NetworkHttps verb
      // (which calls authHeaders() internally) and a hand-rolled request that
      // calls NetworkHttps.authHeaders() itself -- the logout POST and the two
      // multipart sites. Anything else is a request with no credential, and a
      // request with no credential against these nine is a forced logout.
      final offenders = <String>[];

      for (final entry in gatedConstants.entries) {
        final constant = entry.key;
        final path = entry.value;

        final callers = <String>[];

        for (final file in libDartFiles()) {
          final rel = relative(file);
          if (rel == 'lib/utils/base_api.dart') continue;

          final source = commentsStripped(file.readAsStringSync());
          if (!source.contains('API.$constant')) continue;

          callers.add(rel);

          final bearing = RegExp(
            r'NetworkHttps\.(get|post|put|delete|multipart)Request|'
            r'NetworkHttps\.authHeaders\(\)',
          ).hasMatch(source);

          if (!bearing) {
            offenders.add(
              '$rel calls API.$constant ($path) but never reaches '
              'NetworkHttps',
            );
          }
        }

        if (callers.isEmpty) {
          offenders.add(
            'API.$constant ($path) has no caller -- either the feature was '
            'removed (drop it from the nine) or this test has gone vacuous',
          );
        }

        // The contract records exactly one calling file per endpoint, which is
        // what makes "check that file" a complete check.
        if (callers.length > 1) {
          offenders.add(
            'API.$constant is called from ${callers.length} files '
            '(${callers.join(', ')}); the contract records one',
          );
        } else if (callers.isNotEmpty && callers.single != gated[path]) {
          offenders.add(
            'API.$constant moved from ${gated[path]} to ${callers.single}',
          );
        }
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('the token really is attached, and only when there is one', () async {
      // Executable, through the real storage: authHeaders() is the single
      // construction site (network.dart:69-74) that every one of the nine
      // goes through, so this is the content of the credential they carry.
      Prefs.setToken('1|abcdefGHIJKL0123456789');

      final withToken = NetworkHttps.authHeaders();

      expect(
        withToken[HttpHeaders.authorizationHeader],
        'Bearer 1|abcdefGHIJKL0123456789',
      );

      await Prefs.clear();

      // Absent, not empty and not 'Bearer '. An `Authorization: Bearer `
      // header with nothing after it is a MALFORMED credential rather than no
      // credential, and repo A's CustomAuth would answer 401 to it just the
      // same -- so the distinction matters only in that the absent form is
      // what a pre-login request is supposed to look like.
      expect(
        NetworkHttps.authHeaders()
            .containsKey(HttpHeaders.authorizationHeader),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('login itself must stay reachable without a token', () {
    test('adminlogin is sent with the unauthenticated headers', () {
      // The mirror-image failure: if the login POST ever started using
      // authHeaders(), a fresh install would still work (no token, so no
      // header) but it would be one refactor away from sending a stale token
      // to the one endpoint that must not require one. api.php:133 leaves
      // adminlogin on ['AdminApiLog', 'throttle:auth'] with no custom.auth,
      // and the client matches that deliberately.
      final source = commentsStripped(
        File('${packageRoot().path}/'
                'lib/core/controller/auth/auth_controller.dart')
            .readAsStringSync(),
      );

      final loginBlock = source.substring(source.indexOf('loginAuth('));

      expect(
        loginBlock,
        contains('NetworkHttps.baseHeaders'),
        reason: 'The login request must use the unauthenticated headers.',
      );

      // And baseHeaders must not have grown an Authorization key.
      expect(
        NetworkHttps.baseHeaders
            .containsKey(HttpHeaders.authorizationHeader),
        isFalse,
      );
      expect(
        NetworkHttps.baseHeaders.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')),
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('nothing gated is requested before login', () {
    test('both boot paths test the token before routing to the dashboard', () {
      // Six of the nine are what the dashboard and its tabs load. Routing to
      // the dashboard without a token would fire them all, collect six 401s,
      // and force a logout straight back to the login screen -- a boot loop
      // whose cause is in neither the login code nor the dashboard code.
      //
      // Structural, because both deciders are inside a widget's
      // `Future.delayed` and drive Get.offAllNamed; the predicate they use is
      // executed in the test below.
      const deciders = <String, String>{
        'lib/view/screen/welcome_screen.dart': '_checkAndNavigate',
        'lib/core/controller/auth/auth_controller.dart': 'checkLogin',
      };

      deciders.forEach((path, method) {
        final source = commentsStripped(
          File('${packageRoot().path}/$path').readAsStringSync(),
        );

        final at = source.indexOf(method);
        expect(at, greaterThanOrEqualTo(0), reason: '$path has no $method');

        final body = source.substring(at, at + 900);

        expect(
          body,
          contains('Prefs.getToken().isNotEmpty'),
          reason: '$path:$method must gate on the token. Without it the app '
              'boots into the dashboard, fires the gated endpoints with no '
              'credential, and the first 401 logs the merchant out.',
        );

        final tokenAt = body.indexOf('Prefs.getToken().isNotEmpty');
        final dashAt = body.indexOf('dashboard');

        expect(dashAt, greaterThanOrEqualTo(0), reason: '$path:$method');
        expect(
          tokenAt,
          lessThan(dashAt),
          reason: '$path:$method decides on the dashboard before it has '
              'looked at the token.',
        );
      });
    });

    test('and that predicate is false on a fresh install', () async {
      // The real expression, against the real storage.
      expect(Prefs.getToken().isNotEmpty, isFalse);

      Prefs.setToken('1|abcdefGHIJKL0123456789');
      expect(Prefs.getToken().isNotEmpty, isTrue);

      await Prefs.clear();
      expect(
        Prefs.getToken().isNotEmpty,
        isFalse,
        reason: 'After a forced logout the boot path must send the merchant '
            'to login, not back into the gated screens.',
      );
    });
  });
}
