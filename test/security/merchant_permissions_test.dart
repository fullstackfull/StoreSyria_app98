import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/core/permissions/merchant_permissions.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/utils/prefer.dart';

/// P2-07-13 / WS K13 — the client half of the permission contract.
///
/// The server's half is pinned by `tests/Feature/Security/AdminApiPermissionExposureTest.php`,
/// which drives a merchant, a limited employee and the platform operator through `adminlogin` and
/// the dashboard and asserts both that the list is correct AND that Laravel withholds the money.
/// This file pins what the app does with that list.
void main() {
  group('MerchantPermissions', () {
    test('a principal holds exactly what the server listed', () {
      final permissions = MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>['Manage Order', 'Show Order'],
        'user_type': 'staff',
      });

      expect(permissions.may('Manage Order'), isTrue);
      expect(permissions.may('Show Order'), isTrue);
      expect(permissions.may('Manage Products'), isFalse,
          reason: 'an employee was offered a screen the server never granted them');
      expect(permissions.userType, 'staff');
      expect(permissions.isUnrestricted, isFalse);
    });

    /// THE OPERATOR. `isAbleTo()` refuses them server-side, so a role-derived list is EMPTY for
    /// the one principal who may do everything; the server answers `['*']` instead. An app that
    /// did not honour the wildcard would hide every screen from the platform operator.
    test('the wildcard is every permission', () {
      final operator = MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>['*'],
        'user_type': 'super admin',
      });

      expect(operator.isUnrestricted, isTrue);
      expect(operator.may('Manage Order'), isTrue);
      expect(operator.may('Manage Products'), isTrue);
      expect(operator.may('Some Permission Nobody Has Invented Yet'), isTrue);
      expect(operator.mayAny(const <String>['Anything']), isTrue);
    });

    test('mayAny holds when any one of the names is held', () {
      final showOnly = MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>['Show Order'],
      });

      expect(showOnly.mayAny(Permissions.readOrders), isTrue,
          reason: 'the backend gates order figures on Manage Order OR Show Order');
      expect(showOnly.mayAny(const <String>['Manage Products', 'Manage Coupon']), isFalse);
    });

    /// FAIL CLOSED, and this is the case that decides whether the whole thing is safe: a server
    /// that has not been updated sends no `permissions` key at all. The app must then offer
    /// nothing rather than everything.
    test('a response with no permissions key holds nothing', () {
      for (final payload in <dynamic>[
        <String, dynamic>{},
        <String, dynamic>{'permissions': null},
        <String, dynamic>{'permissions': 'Manage Order'},
        <String, dynamic>{'permissions': 42},
        <String, dynamic>{'permissions': <dynamic>[]},
        null,
        'not a map',
        <dynamic>[],
      ]) {
        final permissions = MerchantPermissions.fromJson(payload);

        expect(permissions.may('Manage Order'), isFalse,
            reason: 'payload $payload must not grant anything');
        expect(permissions.isUnrestricted, isFalse);
        expect(permissions.isEmpty, isTrue);
      }
    });

    /// A list that is partly rubbish must still yield the usable entries rather than throwing —
    /// the entire app is behind this parse.
    test('non-string entries are dropped rather than thrown on', () {
      final permissions = MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <dynamic>[
          'Manage Order',
          null,
          42,
          '',
          <String>['nested'],
          <String, String>{'k': 'v'},
          'Manage Coupon',
        ],
        'user_type': 7,
      });

      expect(permissions.names, <String>{'Manage Order', 'Manage Coupon'});
      expect(permissions.userType, '', reason: 'a non-string user_type must not be coerced');
    });

    test('names cannot be mutated through the getter', () {
      final permissions = MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>['Manage Order'],
      });

      expect(() => permissions.names.add('Manage Products'), throwsUnsupportedError);
      expect(permissions.may('Manage Products'), isFalse);
    });

    test('none() holds nothing and is not the operator', () {
      const nothing = MerchantPermissions.none();

      expect(nothing.may('Manage Order'), isFalse);
      expect(nothing.isUnrestricted, isFalse);
      expect(nothing.isEmpty, isTrue);
      expect(nothing.userType, '');
    });
  });

  group('MerchantPermissions persistence', () {
    late Directory storageDir;

    setUpAll(() async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();

      // Prefs reads GetStorage, which asks path_provider for the documents directory. Same
      // throwaway-directory trick the existing suites use (nested_api_read_test.dart:178).
      storageDir = Directory.systemTemp.createTempSync('store_go_permissions_test');

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => storageDir.path,
      );

      await GetStorage.init();
      app.getStorage = GetStorage();
    });

    tearDownAll(() {
      // Cleanup must never fail the suite -- GetStorage flushes in the background.
      try {
        storageDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    setUp(() => MerchantPermissions.forget());

    test('a persisted list comes back', () {
      MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>['Manage Order', 'Manage Coupon'],
        'user_type': 'staff',
      }).persist();

      final restored = MerchantPermissions.restore();

      expect(restored.may('Manage Order'), isTrue);
      expect(restored.may('Manage Coupon'), isTrue);
      expect(restored.may('Manage Products'), isFalse);
      expect(restored.userType, 'staff');
    });

    test('the operator wildcard survives a round trip', () {
      MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>['*'],
      }).persist();

      expect(MerchantPermissions.restore().isUnrestricted, isTrue);
    });

    test('nothing persisted restores to nothing held', () {
      expect(MerchantPermissions.restore().isEmpty, isTrue);
      expect(MerchantPermissions.restore().may('Manage Order'), isFalse);
    });

    /// PERMISSIONS ARE SESSION STATE. `Prefs.clear()` is what a forced logout runs, and its
    /// `preservedOnClear` allowlist must NOT carry them: the next merchant to sign in on this
    /// device would otherwise inherit the last one's permissions.
    test('a logout takes the permissions with it', () async {
      MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>['Manage Order'],
        'user_type': 'staff',
      }).persist();

      expect(MerchantPermissions.restore().may('Manage Order'), isTrue,
          reason: 'premise: they were really stored');

      await Prefs.clear();

      expect(MerchantPermissions.restore().isEmpty, isTrue,
          reason: 'the previous session\'s permissions survived a logout');
      expect(Prefs.preservedOnClear, isNot(contains('merchant_permissions')));
    });
  });
}
