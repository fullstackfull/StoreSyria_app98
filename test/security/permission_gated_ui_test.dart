import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/core/permissions/merchant_permissions.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';

/// P2-07-13 / WS K13 — what the merchant, the limited employee and the operator are OFFERED.
///
/// These drive the real widgets rather than asserting on the permission object, because the object
/// being right is not the deliverable: the deliverable is that a figure the server withheld does
/// not render as `0`, and that a limited employee is not offered a screen that will refuse them.
void main() {
  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    storageDir = Directory.systemTemp.createTempSync('store_go_gated_ui_test');

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

  setUp(() {
    MerchantPermissions.forget();
    Get.clearTranslations();
    // 'action_not_permitted'.tr returns the KEY itself without a translation installed, which
    // would make the assertion below pass on the key rather than on the copy.
    Get.addTranslations(<String, Map<String, String>>{'en_US': en});
    Get.locale = const Locale('en', 'US');
  });

  Widget host(Widget child) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => GetMaterialApp(
          translations: _Translations(),
          locale: const Locale('en', 'US'),
          home: Scaffold(body: child),
        ),
      );

  group('a dashboard figure', () {
    testWidgets('renders the number when the server sent one', (tester) async {
      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            total: '17',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('17'), findsOneWidget);
      expect(find.text('—'), findsNothing);
    });

    /// THE DEFECT THIS ROW FIXES. Every caller passed `?? "0"`, so a figure the server WITHHELD
    /// rendered as a confident zero: a store with hidden orders read as a store with none.
    testWidgets('shows a dash, never a zero, when it was withheld', (tester) async {
      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            // What the screen passes: the figure is absent, so `?? "0"` yields "0".
            total: '0',
            permitted: false,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('—'), findsOneWidget,
          reason: 'a withheld figure must not be rendered as a number');
      expect(find.text('0'), findsNothing,
          reason: 'the withheld figure was served as 0 -- wrong information, not withheld '
              'information');
    });

    /// A DASH IS SILENT TO A SCREEN READER. Sighted merchants can infer something from an em dash;
    /// a reader would hear "Total Orders" and a meaningless glyph, so the tile has to SAY why.
    testWidgets('tells a screen reader why the figure is a dash', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            total: '0',
            permitted: false,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp(r'Total Orders.*permission')),
        findsOneWidget,
        reason: 'a screen reader was given a dash and no explanation',
      );

      handle.dispose();
    });

    testWidgets('a permitted figure carries no refusal in its label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            total: '17',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp(r'permission')), findsNothing,
          reason: 'a figure the merchant may see was announced as refused');

      handle.dispose();
    });
  });

  group('the settings navigation grid', () {
    /// FAIL OPEN WHEN UNINFORMED. A client shipped ahead of its backend receives no permission
    /// list; gating strictly would empty the grid and leave the merchant an app with no
    /// navigation. The server enforces independently, so the worst case is a visible entry whose
    /// screen then refuses.
    test('an uninformed client offers every entry', () {
      const nothing = MerchantPermissions.none();

      for (final permission in <String>[
        Permissions.manageStoreAnalytics,
        Permissions.manageShipping,
        Permissions.manageCustomer,
        Permissions.manageDeliveryboy,
        Permissions.manageCoupon,
      ]) {
        expect(nothing.mayOffer(permission), isTrue,
            reason: 'an empty list must not hide $permission and strand the merchant');
      }
    });

    /// INFORMED GATES. Once the server has listed anything, an absent name hides the entry.
    test('an informed client hides what the server did not list', () {
      final ordersOnly = MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>[Permissions.manageOrder],
      });

      expect(ordersOnly.mayOffer(Permissions.manageOrder), isTrue);

      for (final permission in <String>[
        Permissions.manageStoreAnalytics,
        Permissions.manageShipping,
        Permissions.manageCustomer,
        Permissions.manageDeliveryboy,
        Permissions.manageCoupon,
      ]) {
        expect(ordersOnly.mayOffer(permission), isFalse,
            reason: 'an orders-only employee was offered $permission');
      }
    });

    test('the operator is offered everything', () {
      final operator = MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>[MerchantPermissions.wildcard],
        'user_type': 'super admin',
      });

      expect(operator.mayOffer(Permissions.manageShipping), isTrue);
      expect(operator.mayOffer('Manage Something Added Next Year'), isTrue);
    });

    /// `current` is what the screens read, so the memo must follow a persist and a forget or a
    /// store switch would leave the previous store's grid on screen.
    test('current follows persist and forget', () {
      expect(MerchantPermissions.current.isEmpty, isTrue);

      MerchantPermissions.fromJson(<String, dynamic>{
        'permissions': <String>[Permissions.manageCoupon],
      }).persist();

      expect(MerchantPermissions.current.may(Permissions.manageCoupon), isTrue);
      expect(MerchantPermissions.current.mayOffer(Permissions.manageShipping), isFalse);

      MerchantPermissions.forget();

      expect(MerchantPermissions.current.isEmpty, isTrue,
          reason: 'a store switch or logout left the previous permissions in the memo');
    });
  });
}

class _Translations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{'en_US': en};
}
