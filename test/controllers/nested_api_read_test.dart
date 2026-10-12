// Executable coverage for the 24 unguarded NESTED reads of a decoded API body.
//
// WHAT WAS WRONG. Twenty-four call sites across six controllers read a
// response as `data['data']['message']` (and in one case
// `data['data']['user_info']['current_store']`). The `?? 'fallback'` next to
// them makes them LOOK defensive, but `[]` binds tighter than `??`: when the
// server answers `{"status": 0}` with no `data` object -- which is what an
// error payload, a 200-with-an-error-envelope, or a version skew looks like --
// the inner index runs on null and throws NoSuchMethodError before the `??`
// is ever consulted.
//
// WHY IT IS WORSE THAN A VISIBLE CRASH. Every one of these throws INSIDE the
// `onSuccess` closure, so everything after it in that closure is skipped:
//
//   * store_setting_controller.deleteStoreData skipped Prefs.setStoreID,
//     leaving the app pointed at a store the server had just deleted;
//   * loyality_controller.getLoyaltyData left the loyalty screen showing the
//     previous store's reward point.
//
// HOW THESE TESTS WORK. Each controller holds its repository in a NON-final
// field, so a subclass that returns a canned `Success` is enough to drive the
// real production method -- no HTTP, no mocking framework. `commonToast` is a
// no-op here on purpose and not by accident: _AppSnackBarController.show
// returns early when `Get.overlayContext` is null
// (common_snak_bar_widget.dart:169-171), and there is no overlay under
// `flutter test`. So these tests execute the real parse-and-assign path and
// stop exactly where the merchant's device would have thrown.
//
// A NOTE ON THE TYPE ERRORS. Three of these sites also fed a raw JSON value
// into a NON-NULLABLE String position (`TextEditingController.text`, an
// `RxString`, and `commonToast(String msg, ...)`). A Laravel controller
// returning `"reward_point": 150` unquoted therefore crashed the loyalty
// screen on a response with nothing wrong with it. The `.toString()` inside
// apiText covers that, and `reads an unquoted number` below is the proof.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/config/repository/category_repository.dart';
import 'package:store_go_app/config/repository/loyalty_repository.dart';
import 'package:store_go_app/config/repository/setting_repository.dart';
import 'package:store_go_app/config/repository/shipping_repository.dart';
import 'package:store_go_app/config/repository/store_settings_repository.dart';
import 'package:store_go_app/config/repository/tax_repository.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/core/controller/home_controller/shipping_controller.dart';
import 'package:store_go_app/core/controller/home_controller/tax_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/email_setting_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/loyality_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/store_setting_controller.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/utils/prefer.dart';

Success<Map<String, dynamic>> _ok(Map<String, dynamic> body) =>
    Success<Map<String, dynamic>>(body);

// --------------------------------------------------------------------------
// Fakes. Each returns the same canned body for every method, which is all
// these tests need: the body IS the input under test.
// --------------------------------------------------------------------------

class _FakeLoyaltyRepository extends LoyaltyRepository {
  _FakeLoyaltyRepository(this.body);
  final Map<String, dynamic> body;

  @override
  Future<Result<Map<String, dynamic>>> getLoyaltySettingData() async =>
      _ok(body);

  @override
  Future<Result<Map<String, dynamic>>> setLoyaltyData({
    required String status,
    required String point,
  }) async =>
      _ok(body);
}

class _FakeTaxRepository extends TaxRepository {
  _FakeTaxRepository(this.body);
  final Map<String, dynamic> body;

  @override
  Future<Result<Map<String, dynamic>>> addTaxData({
    required bool isUpdate,
    required String taxId,
    required String taxName,
    required String type,
    required String taxAmount,
    required String status,
  }) async =>
      _ok(body);

  @override
  Future<Result<Map<String, dynamic>>> deleteTaxData(String taxId) async =>
      _ok(body);

  // Called by the success branches after the toast. Answering with a Failure
  // keeps the follow-up list refresh out of the assertion while still
  // exercising the code that calls it.
  @override
  Future<Result<Map<String, dynamic>>> getTaxData(int page) async =>
      const Failure<Map<String, dynamic>>(
        FailureReason.network,
        'not under test',
      );
}

class _FakeSettingRepository extends SettingRepository {
  _FakeSettingRepository(this.body);
  final Map<String, dynamic> body;

  @override
  Future<Result<Map<String, dynamic>>> saveEmailSettingData({
    required Map<dynamic, dynamic> data,
  }) async =>
      _ok(body);

  @override
  Future<Result<Map<String, dynamic>>> getEmailSettingData() async => _ok(body);

  @override
  Future<Result<Map<String, dynamic>>> setTestMailData({
    required String email,
  }) async =>
      _ok(body);
}

class _FakeShippingRepository extends ShippingRepository {
  _FakeShippingRepository(this.body);
  final Map<String, dynamic> body;

  @override
  Future<Result<Map<String, dynamic>>> addShippingData({
    required bool isUpdate,
    required String shippingId,
    required String name,
    required String description,
  }) async =>
      _ok(body);

  @override
  Future<Result<Map<String, dynamic>>> getShippingData(int page) async =>
      const Failure<Map<String, dynamic>>(
        FailureReason.network,
        'not under test',
      );
}

class _FakeCategoryRepository extends CategoryRepository {
  _FakeCategoryRepository(this.body);
  final Map<String, dynamic> body;

  @override
  Future<Result<Map<String, dynamic>>> getCategoriesData(int page) async =>
      _ok(body);

  @override
  Future<Result<Map<String, dynamic>>> deleteCategoriesData({
    required int categoryId,
  }) async =>
      _ok(body);
}

class _FakeStoreSettingsRepository extends StoreSettingRepository {
  _FakeStoreSettingsRepository(this.body);
  final Map<String, dynamic> body;

  @override
  Future<Result<Map<String, dynamic>>> deleteStoreData() async => _ok(body);
}

void main() {
  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    // Three of these controllers read or write Prefs, which reads GetStorage,
    // which asks path_provider for the documents directory. Same throwaway
    // directory trick as token_storage_test.dart.
    storageDir = Directory.systemTemp.createTempSync('store_go_nested_test');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();
  });

  tearDownAll(() {
    if (storageDir.existsSync()) storageDir.deleteSync(recursive: true);
  });

  setUp(() async {
    await Prefs.clear();
  });

  // =========================================================================
  // LoyaltyController -- loyality_controller.dart:45-53, six of the 24 sites.
  // =========================================================================

  group('LoyaltyController.getLoyaltyData', () {
    Future<LoyaltyController> run(Map<String, dynamic> body) async {
      final c = LoyaltyController();
      c.loyaltyRepository = _FakeLoyaltyRepository(body);
      await c.getLoyaltyData();
      return c;
    }

    test('a success envelope with NO data object does not throw', () async {
      // The exact body that crashed: `{"status": 1}`. Pre-fix this threw
      // NoSuchMethodError on `data['data']['reward_point']` and the whole
      // onSuccess closure was abandoned.
      final c = await run({'status': 1});

      expect(c.rewardPointController.text, '');
      expect(c.status.value, 'off');
      expect(c.isStatus.value, isFalse);
      expect(c.isLoading.value, isFalse);
    });

    test('a null data object does not throw', () async {
      final c = await run({'status': 1, 'data': null});

      expect(c.rewardPointController.text, '');
      expect(c.status.value, 'off');
    });

    test('a data field that is a String, not an object, does not throw',
        () async {
      // `data['data']?['x']` would NOT have covered this: String rejects a
      // String subscript just as loudly as null does.
      final c = await run({'status': 1, 'data': 'OK'});

      expect(c.rewardPointController.text, '');
      expect(c.status.value, 'off');
    });

    test('reads an unquoted number into the reward point field', () async {
      // The second defect at this site. `.text = 150` is a TypeError against
      // a non-nullable String setter, on a response with nothing wrong with
      // it. Laravel returns an unquoted integer unless the column is cast.
      final c = await run({
        'status': 1,
        'data': {'reward_point': 150, 'loyality_program_enabled': 'on'},
      });

      expect(c.rewardPointController.text, '150');
      expect(c.isStatus.value, isTrue);
      expect(c.status.value, 'on');
    });

    test('a real string payload still round-trips unchanged', () async {
      // The legitimate merchant workflow: this is what the server actually
      // sends today, and it must behave exactly as it did before the fix.
      final c = await run({
        'status': 1,
        'data': {'reward_point': '25', 'loyality_program_enabled': 'off'},
      });

      expect(c.rewardPointController.text, '25');
      expect(c.isStatus.value, isFalse);
      expect(c.status.value, 'off');
    });

    test('an error envelope with no data object does not throw', () async {
      final c = await run({'status': 0});

      expect(c.isLoading.value, isFalse);
    });
  });

  group('LoyaltyController.setLoyaltyData', () {
    test('both branches survive a body with no data object', () async {
      for (final status in [1, 0]) {
        final c = LoyaltyController();
        c.loyaltyRepository = _FakeLoyaltyRepository({'status': status});

        await c.setLoyaltyData(status: 'on', point: '10');

        expect(c.isLoading.value, isFalse);
      }
    });
  });

  // =========================================================================
  // TaxController -- tax_controller.dart:102-142, four of the 24 sites.
  // =========================================================================

  group('TaxController', () {
    test('addTaxData error branch survives a body with no data object',
        () async {
      final c = TaxController();
      c.taxRepository = _FakeTaxRepository({'status': 0});

      await c.addTaxData(
        isUpdate: false,
        taxId: '',
        taxName: 'VAT',
        type: 'fixed',
        taxAmount: '5',
        status: '1',
      );

      expect(c.isLoading.value, isFalse);
    });

    test('deleteTaxData success branch survives a body with no data object',
        () async {
      final c = TaxController();
      c.taxRepository = _FakeTaxRepository({'status': 1});

      await c.deleteTaxData(taxId: '7');

      expect(c.isDeleteLoading.value, isFalse);
      expect(c.taxList, isEmpty);
    });

    test('deleteTaxData error branch survives a body with no data object',
        () async {
      final c = TaxController();
      c.taxRepository = _FakeTaxRepository({'status': 0});

      await c.deleteTaxData(taxId: '7');

      expect(c.isDeleteLoading.value, isFalse);
    });
  });

  // =========================================================================
  // EmailSettingController -- email_setting_controller.dart:50-93, three
  // sites. saveEmailSettingData had NO status check at all, so the crash was
  // on the ordinary success path.
  // =========================================================================

  group('EmailSettingController', () {
    test('saveEmailSettingData survives a body with no data object', () async {
      final c = EmailSettingController();
      c.settingRepository = _FakeSettingRepository({'status': 1});

      await c.saveEmailSettingData(
        mailDriver: 'smtp',
        mailHost: 'smtp.example.test',
        mailPort: '587',
        mailUserName: 'u',
        mailPassword: 'p',
        mailEncryption: 'tls',
        mailFromAddress: 'a@example.test',
        mailFromName: 'Store',
      );

      expect(c.isLoading.value, isFalse);
    });

    test('sendTextEmailData survives a body with no data object', () async {
      final c = EmailSettingController();
      c.settingRepository = _FakeSettingRepository({'status': 1});

      await c.sendTextEmailData(email: 'a@example.test');

      expect(c.isLoading.value, isFalse);
    });

    test('getEmailSettingData error branch survives it too', () async {
      final c = EmailSettingController();
      c.settingRepository = _FakeSettingRepository({'status': 0});

      await c.getEmailSettingData();

      expect(c.isLoading.value, isFalse);
    });
  });

  // =========================================================================
  // ShippingController -- shipping_controller.dart:81, one site, and the only
  // one that could pass NULL to commonToast's non-nullable String parameter:
  // `data['message'] ?? data['data']['message']` is null when both are
  // present-but-null.
  // =========================================================================

  group('ShippingController.addShippingData', () {
    test('a body with no message anywhere does not throw', () async {
      final c = ShippingController();
      c.shippingRepository = _FakeShippingRepository({'status': 1});

      await c.addShippingData(
        isUpdate: false,
        shippingId: '',
        name: 'DHL',
        description: 'd',
      );
    });

    test('a present-but-null message does not throw', () async {
      // Pre-fix: `null ?? null` is null, and commonToast's first parameter is
      // a non-nullable String -- a TypeError, not a blank toast.
      final c = ShippingController();
      c.shippingRepository = _FakeShippingRepository({
        'status': 1,
        'message': null,
        'data': {'message': null},
      });

      await c.addShippingData(
        isUpdate: false,
        shippingId: '',
        name: 'DHL',
        description: 'd',
      );
    });
  });

  // =========================================================================
  // CategoryController -- category_controller.dart:155, 200, 330, 334.
  // =========================================================================

  group('CategoryController', () {
    test('getCategoryData error branch survives a body with no data object',
        () async {
      final c = CategoryController();
      c.categoryRepository = _FakeCategoryRepository({'status': 0});

      await c.getCategoryData(1);

      expect(c.isLoading.value, isFalse);
    });

    test('deleteCategoriesData survives both branches', () async {
      for (final status in [1, 0]) {
        final c = CategoryController();
        c.categoryRepository = _FakeCategoryRepository({'status': status});

        await c.deleteCategoriesData(categoryId: 3);
      }
    });
  });

  // =========================================================================
  // StoreSettingController.deleteStoreData -- store_setting_controller.dart
  // 638-652. The worst of the 24: THREE levels, two of them unguarded, and a
  // `.toString()` on the leaf.
  // =========================================================================

  group('StoreSettingController.deleteStoreData', () {
    Future<StoreSettingController> run(Map<String, dynamic> body) async {
      final c = StoreSettingController();
      c.settingRepository = _FakeStoreSettingsRepository(body);
      await c.deleteStoreData();
      return c;
    }

    test('the legitimate response still caches the new store id', () async {
      // The workflow that must keep working: the server reports which store
      // the merchant is on after the deletion, and the app caches it.
      Prefs.setStoreID('11');

      await run({
        'status': 1,
        'data': {
          'message': 'Store deleted',
          'user_info': {'current_store': 77},
        },
      });

      // 77 unquoted, because that is what the server sends. Pre-fix this
      // worked only via `.toString()` on a dynamic, which is also why the
      // null case below wrote the string "null".
      expect(Prefs.getStoreID(), '77');
    });

    test('a response with no user_info keeps the cached store id', () async {
      // Pre-fix: NoSuchMethodError on `data['data']['user_info']['...']`,
      // which skipped the setStoreID AND the two log lines after it.
      Prefs.setStoreID('11');

      final c = await run({'status': 1});

      expect(Prefs.getStoreID(), '11');
      expect(c.isLoading.value, isFalse);
    });

    test('a null current_store no longer writes the string "null"', () async {
      // The second defect. `null.toString()` is "null", so the cached store
      // id became the four characters n-u-l-l and went out on every later
      // request as `?store_id=null`.
      Prefs.setStoreID('11');

      await run({
        'status': 1,
        'data': {
          'user_info': {'current_store': null},
        },
      });

      expect(Prefs.getStoreID(), isNot('null'));
      expect(Prefs.getStoreID(), '11');
    });

    test('an error envelope does not throw', () async {
      final c = await run({'status': 0});

      expect(c.isLoading.value, isFalse);
    });
  });
}
