import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/config/repository/dashboard_repository.dart';
import 'package:store_go_app/core/controller/home_controller/home_controller.dart';
import 'package:store_go_app/core/permissions/merchant_permissions.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/network/result.dart';

/// P2-07-13 / WS K13 — PERMISSIONS FOLLOW THE STORE.
///
/// This is the case a login-only payload could never express, and the owner's condition for this
/// row: the permissions must belong to the CURRENT store. A merchant with two stores and one
/// employee in each switches between them inside the app, and the set has to change with it.
///
/// It drives the real [HomeController] against a fake repository, because the thing being tested
/// is the controller's sequencing — clear, request, adopt — not the parse, which
/// merchant_permissions_test.dart covers.
void main() {
  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    storageDir = Directory.systemTemp.createTempSync('store_go_switch_test');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();
  });

  tearDownAll(() {
    try {
      storageDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  setUp(MerchantPermissions.forget);

  test('a dashboard response replaces the permission set', () async {
    final controller = HomeController();
    final fake = _FakeDashboardRepository(<String>['Manage Order', 'Show Order']);
    controller.dashboardRepository = fake;

    await controller.getDashboardData();

    expect(controller.permissions.value.may('Manage Order'), isTrue);
    expect(controller.permissions.value.may('Manage Products'), isFalse);
    expect(MerchantPermissions.current.may('Manage Order'), isTrue,
        reason: 'the set must also be persisted, so a screen not wired to this controller sees it');
  });

  test('a store switch replaces the previous store permissions', () async {
    final controller = HomeController();
    final fake = _FakeDashboardRepository(<String>['Manage Order']);
    controller.dashboardRepository = fake;

    await controller.getDashboardData();

    expect(controller.permissions.value.may('Manage Order'), isTrue,
        reason: 'premise: store A granted it');

    // The merchant switches store. The second store grants a different set.
    fake.permissions = <String>['Manage Coupon'];
    controller.resetForStoreChange();
    await Future<void>.delayed(Duration.zero);

    expect(controller.permissions.value.may('Manage Coupon'), isTrue);
    expect(controller.permissions.value.may('Manage Order'), isFalse,
        reason: "store A's permission was still held inside store B");
    expect(MerchantPermissions.current.may('Manage Order'), isFalse,
        reason: "the persisted set still carried store A's permission after the switch");
  });

  /// FAIL CLOSED ACROSS THE SWITCH. The few hundred milliseconds between clearing store A and
  /// store B's response arriving must hold NOTHING, not store A's set — otherwise the app offers
  /// the wrong store's surfaces during the switch. The fake records the state at request time,
  /// which is the only moment that window is observable.
  test('nothing is held while the new store is still loading', () async {
    final controller = HomeController();
    final fake = _FakeDashboardRepository(<String>['Manage Order']);
    controller.dashboardRepository = fake;

    await controller.getDashboardData();
    expect(MerchantPermissions.current.may('Manage Order'), isTrue, reason: 'premise');

    fake.permissions = <String>['Manage Coupon'];
    controller.resetForStoreChange();
    await Future<void>.delayed(Duration.zero);

    expect(fake.heldAtRequestTime, isNotNull, reason: 'premise: the fake was asked');
    expect(fake.heldAtRequestTime, isEmpty,
        reason: "store A's permissions were still live while store B was loading");
  });

  /// A FAILED REFRESH MUST NOT GRANT ANYTHING. If the new store's dashboard never answers, the app
  /// holds nothing rather than falling back to the previous store's set.
  test('a failed refresh after a switch leaves nothing held', () async {
    final controller = HomeController();
    final fake = _FakeDashboardRepository(<String>['Manage Order']);
    controller.dashboardRepository = fake;

    await controller.getDashboardData();
    expect(MerchantPermissions.current.may('Manage Order'), isTrue, reason: 'premise');

    fake.fail = true;
    controller.resetForStoreChange();
    await Future<void>.delayed(Duration.zero);

    expect(controller.permissions.value.isEmpty, isTrue,
        reason: 'a failed refresh fell back to the previous store\'s permissions');
  });

  /// AN OLDER SERVER sends no `permissions` key. The strict set is then empty, which hides data
  /// surfaces; `mayOffer` is what keeps navigation usable. Both halves pinned here together so
  /// the pair cannot drift apart.
  test('a response with no permissions key holds nothing but still offers navigation', () async {
    final controller = HomeController();
    controller.dashboardRepository = _FakeDashboardRepository(null);

    await controller.getDashboardData();

    expect(controller.permissions.value.isEmpty, isTrue);
    expect(controller.permissions.value.may('Manage Order'), isFalse);
    expect(controller.permissions.value.mayOffer('Manage Order'), isTrue,
        reason: 'a client ahead of its backend must not hide its own navigation');
  });
}

class _FakeDashboardRepository extends DashboardRepository {
  _FakeDashboardRepository(this.permissions);

  List<String>? permissions;
  bool fail = false;

  /// What was held at the moment the request went out — the only way to observe the window
  /// between clearing the old store and adopting the new one.
  Set<String>? heldAtRequestTime;

  @override
  Future<Result<Map<String, dynamic>>> getDashBoardData() async {
    heldAtRequestTime = MerchantPermissions.current.names;

    if (fail) {
      return const Failure<Map<String, dynamic>>(FailureReason.network, 'no network');
    }

    return Success<Map<String, dynamic>>(<String, dynamic>{
      'data': <String, dynamic>{
        'user': <String, dynamic>{'name': 'Merchant', 'image': null},
        'store': <dynamic>[],
        'qr-code': <String, dynamic>{'url': null, 'name': null},
        if (permissions != null) 'permissions': permissions,
        if (permissions != null) 'user_type': 'admin',
      },
    });
  }
}
