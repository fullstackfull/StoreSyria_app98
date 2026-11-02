import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The CLIENT half of the PERMISSION half of the API contract.
///
/// `newly_gated_endpoints_test.dart` pins which endpoints need a TOKEN. This pins which of them
/// now also need a PERMISSION, and that a refusal of one is survivable.
///
/// WHAT CHANGED SERVER-SIDE (P2-07-13). Five endpoints this app calls moved from "any
/// authenticated member of the tenant" to "the permission the screen needs", because each serves
/// money or analytics and `routes/api.php` declares no permission middleware anywhere:
///
///   | endpoint      | permission                                | what it serves            |
///   |---------------|-------------------------------------------|---------------------------|
///   | `/orderlist`  | `Manage Order` or `Show Order`            | `final_price` per row     |
///   | `/Top_orders` | `Manage Order` or `Show Order`            | orders ranked BY price    |
///   | `/productlist`| `Manage Products`                         | `cost_price`, the margin  |
///   | `/couponlist` | `Manage Coupon` or `Show Coupon`          | `discount_amount`         |
///   | `/staticsdata`| `Manage Store Analytics`/`Manage Dashboard`| store traffic            |
///
/// WHY THIS FILE EXISTS RATHER THAN TRUST. A refusal arrives as **403**, and the distinction
/// between 403 and 401 is the difference between "you may not open that screen" and "you are
/// signed out of the app": `network.dart` maps any 401 to `Prefs.clear()` and a bounce to the
/// login screen, and maps 403 to `action_not_permitted` with the session INTACT. If anyone
/// "hardens" one of these five into a 401, every merchant whose staff opens that screen gets
/// logged out. The server side asserts the same property from its end
/// (`AdminApiListPermissionTest::test_no_gated_route_answers_401_for_a_permission_refusal`);
/// this is the client's statement of what it depends on.
void main() {
  late String network;
  late String baseApi;

  setUpAll(() {
    network = File('lib/network/network.dart').readAsStringSync();
    baseApi = File('lib/utils/base_api.dart').readAsStringSync();
  });

  /// PREMISE. If a path were renamed the table above would be describing endpoints this app no
  /// longer calls, and every assertion below would be vacuously true.
  test('the app still calls all five permission-gated endpoints', () {
    for (final path in const <String>[
      '/orderlist',
      '/Top_orders',
      '/productlist',
      '/couponlist',
      '/staticsdata',
    ]) {
      expect(baseApi, contains("'$path'"),
          reason: '$path is permission-gated server-side but this app no longer declares it');
    }
  });

  /// THE LOAD-BEARING ASSERTION. 403 must not reach the forced-logout path.
  test('a 403 does not force a logout', () {
    final case403 = network.indexOf('case 403:');
    expect(case403, greaterThan(-1), reason: 'the 403 branch is gone');

    final case404 = network.indexOf('case 404:', case403);
    expect(case404, greaterThan(case403));

    final branch = network.substring(case403, case404);

    expect(branch, isNot(contains('onUnauthorized')),
        reason: 'the 403 branch calls onUnauthorized, which clears the session -- a permission '
            'refusal would log the merchant out of the app');
    expect(branch, contains('action_not_permitted'),
        reason: 'a 403 with no server message must still say the action is not permitted');
  });

  /// THE COUNTERPART, so the test above cannot pass because the whole mechanism vanished: 401
  /// MUST still force a logout. Both facts in one file, because it is their difference that
  /// matters.
  test('a 401 still forces a logout', () {
    final case401 = network.indexOf('case 401:');
    expect(case401, greaterThan(-1));

    final next = network.indexOf('case 4', case401 + 10);
    final branch = network.substring(case401, next > case401 ? next : network.length);

    expect(branch, contains('onUnauthorized'),
        reason: 'a genuinely expired session must still end it');
  });

  /// The 403 branch must not be reachable only for one verb. Every request helper funnels through
  /// the same status handling, so this asserts there is exactly one place where it is decided.
  test('the status handling is in one place', () {
    expect(
      'case 403:'.allMatches(network).length,
      1,
      reason: 'a second 403 branch means one of the verbs can diverge from this contract',
    );
  });
}
