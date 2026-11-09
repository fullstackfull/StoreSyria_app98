import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/view/screen/home_screen/shipping_screen.dart';
import 'package:store_go_app/view/screen/home_screen/tax_screen.dart';
import 'package:store_go_app/view/screen/notification_screen/notification_screen.dart';
import 'package:store_go_app/view/screen/wallet/wallet_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-OPS — the operations screens, driven and captured with real rows.
/// =================================================================================================
///
/// The second tranche through the screen harness. `screen_mount_matrix_test.dart` and
/// `populated_screen_capture_test.dart` covered the five catalogue/people screens; these four are
/// the operational ones — tax, shipping, wallet and notifications — and they are a DIFFERENT shape
/// in three ways that each had to be read out of the code rather than guessed:
///
///   1. **Three of the four register their own controller.** `TaxScreen`, `ShippingScreen` and
///      `WalletScreen` all carry `Get.put(SomeController())` in a `State` FIELD INITIALISER, which
///      runs inside `pumpWidget` and therefore inside the harness's client zone. They need no
///      `register` callback at all. `NotificationScreen` is the opposite — `Get.find<...>()` in its
///      field initialiser — so it does need one, and would throw `"NotificationController" not
///      found` without it.
///   2. **The envelopes differ.** Tax and shipping are the paginated `{status, data: {data: []}}`
///      shape the first tranche used. The wallet is NOT: it is
///      `{status, data: {available_balance, transactions: [], pagination: {}}}`. Notifications are
///      different again — `NotificationModel.fromJson` is handed the WHOLE body and reads
///      `json['count']` beside `json['data']`, and its `status` is parsed
///      `json['status'] is bool ? ... : null`, so the integer `1` every other endpoint uses lands
///      as `null` there. The controller does not gate on it, which is why these fixtures still
///      work — but a fixture copied from the first tranche would have been wrong in a way that
///      still rendered.
///   3. **`NotificationController` reads a CACHE on `onInit`** (`_loadCachedNotifications`, from
///      GetStorage under a `cache_*` key). That is exactly the trap `resetScreenHarness` was built
///      to clear; without that clearing, one test here would render the previous test's rows. The
///      harness's own regression test covers the mechanism; this file depends on it.
///
/// EVERY CASE PROVES THE LIST REALLY FILLED before it captures. An empty list renders the screen's
/// `EmptyState`, which looks like a working screen with no data — the error that twice froze a
/// wrong baseline in this repository, and that the delivery-man fixture reproduced last session
/// with a string `'1'` where the controller wanted an int.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// The paginated envelope tax and shipping share. `status` is the INTEGER 1: both controllers
  /// gate on `data['status'] == 1` (`tax_controller.dart:49`, `shipping_controller.dart:60`), and
  /// both `clear()` their list BEFORE that check, so a fixture that failed the gate would leave an
  /// empty list and an `EmptyState` rather than an error.
  Map<String, Object?> paginated(List<Object?> rows) => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'current_page': 1,
          'last_page': 1,
          'per_page': 10,
          'total': rows.length,
          'data': rows,
        },
      };

  Map<String, Object?> taxPage() => paginated(<Object?>[
        <String, Object?>{
          'id': 1,
          'tax_name': 'ضريبة القيمة المضافة',
          'tax_type': 'percentage',
          'tax_amount': 11,
          'status': 1,
          'store_id': 1,
        },
        <String, Object?>{
          'id': 2,
          'tax_name': 'Municipality fee',
          'tax_type': 'fixed',
          'tax_amount': 25,
          'status': 1,
          'store_id': 1,
        },
      ]);

  Map<String, Object?> shippingPage() => paginated(<Object?>[
        <String, Object?>{
          'id': 1,
          'name': 'توصيل داخل دمشق',
          'description': 'خلال ٢٤ ساعة',
          'amount': '5000',
          'charges_type': 'Flat',
          'status': '1',
          'store_id': 1,
          'expeted_delivery': '1',
          'return_order_dutation': 3,
        },
        <String, Object?>{
          'id': 2,
          'name': 'Governorate courier',
          'description': 'Two to four working days',
          'amount': '12000',
          'charges_type': 'Flat',
          'status': '1',
          'store_id': 1,
          'expeted_delivery': '4',
          'return_order_dutation': 7,
        },
      ]);

  /// The wallet's own envelope: a balance and a `transactions` list, NOT the paginated `data.data`
  /// shape. `WalletData.fromJson` is handed `data['data']` (`wallet_controller.dart:89`).
  Map<String, Object?> walletPage() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'store_id': 1,
          'available_balance': '482500',
          'currency_code': 'SYP',
          'currency_symbol': 'ل.س',
          'transactions': <Object?>[
            <String, Object?>{
              'id': 91,
              'type': 'topup',
              'direction': 'credit',
              'amount': '150000',
              'currency_code': 'SYP',
              'balance_before': '332500',
              'balance_after': '482500',
              'description': 'إيداع من الحوالة البنكية',
              'status': 'completed',
              'created_at': '2026-11-02 10:15:00',
            },
            <String, Object?>{
              'id': 90,
              'type': 'withdrawal',
              'direction': 'debit',
              'amount': '60000',
              'currency_code': 'SYP',
              'balance_before': '392500',
              'balance_after': '332500',
              'description': 'Payout to merchant account',
              'status': 'completed',
              'created_at': '2026-10-29 09:40:00',
            },
          ],
          'pagination': <String, Object?>{
            'total': 2,
            'per_page': 10,
            'current_page': 1,
            'last_page': 1,
            'has_more': false,
          },
        },
      };

  /// Notifications: the model is handed the WHOLE body, and `count` sits BESIDE `data`.
  /// `NotificationModel.status` is `json['status'] is bool ? ... : null`, so the `1` here parses to
  /// `null` — deliberately kept, because that is what the server sends and the controller never
  /// reads it.
  Map<String, Object?> notificationPage() => <String, Object?>{
        'status': 1,
        'count': 2,
        'data': <String, Object?>{
          'current_page': 1,
          'last_page': 1,
          'per_page': 15,
          'total': 2,
          'data': <Object?>[
            <String, Object?>{
              'id': 501,
              'store_id': 1,
              'user_id': 7,
              'type': 'order_placed',
              'title': 'طلب جديد #1042',
              'message': 'وصل طلب جديد بقيمة ٨٥٠٠٠ ل.س',
              'reference_type': 'order',
              'reference_id': 1042,
              'is_read': false,
              'push_sent': true,
              'created_at': '2026-11-09 08:05:00',
            },
            <String, Object?>{
              'id': 500,
              'store_id': 1,
              'user_id': 7,
              'type': 'stock_low',
              'title': 'Low stock warning',
              'message': 'Damascene cotton shirt is down to 3 units',
              'reference_type': 'product',
              'reference_id': 12,
              'is_read': true,
              'push_sent': true,
              'created_at': '2026-11-08 17:30:00',
            },
          ],
        },
      };

  final cases = <_OpsCase>[
    _OpsCase(
      surface: 'flutter-tax-list',
      label: 'tax rates',
      endpoint: 'taxlist',
      body: taxPage(),
      build: () => const TaxScreen(),
      // No register: `_TaxScreenState` does `Get.put(TaxController())` itself.
      rowText: 'Municipality fee',
    ),
    _OpsCase(
      surface: 'flutter-shipping-list',
      label: 'shipping methods',
      endpoint: 'shippinglist',
      body: shippingPage(),
      build: () => const ShippingScreen(),
      rowText: 'Governorate courier',
    ),
    _OpsCase(
      surface: 'flutter-wallet',
      label: 'wallet',
      endpoint: 'wallet/transactions',
      body: walletPage(),
      build: () => const WalletScreen(),
      rowText: 'Payout to merchant account',
    ),
    _OpsCase(
      surface: 'flutter-notifications',
      label: 'notifications',
      endpoint: 'notification',
      body: notificationPage(),
      build: () => NotificationScreen(isBack: false),
      register: () {
        Get.put(NotificationController());
      },
      rowText: 'Low stock warning',
    ),
  ];

  for (final opsCase in cases) {
    for (final combination in kFourCombinations) {
      testWidgets('${opsCase.label} renders its rows in ${combination.name}', (tester) async {
        final api = ApiStub()..on(opsCase.endpoint, opsCase.body);

        await pumpScreen(
          tester,
          opsCase.build(),
          api: api,
          combination: combination,
          register: opsCase.register,
        );

        /// THE PREMISE, FIRST. Without it an empty list would be captured as a verified screen:
        /// every one of these four renders an `EmptyState` when its list is empty, and that is
        /// indistinguishable from a merchant who simply has no tax rates.
        await pumpUntil(
          tester,
          () => find.textContaining(opsCase.rowText).evaluate().isNotEmpty,
          reason: '${opsCase.label}: "${opsCase.rowText}" never reached the screen, so either the '
              'fixture did not satisfy the controller\'s status gate or the list never rendered. '
              'The screen would have been captured showing its empty state. Calls: ${api.calls}',
        );

        await drainToasts(tester);

        expect(tester.takeException(), isNull,
            reason: '${opsCase.label} threw while rendering in ${combination.name}');

        expect(api.sawRequestFor(opsCase.endpoint), isTrue,
            reason: '${opsCase.label} never called ${opsCase.endpoint}. Recorded: ${api.calls}');

        final context = tester.element(find.byType(Scaffold).first);
        expect(Directionality.of(context), combination.direction,
            reason: '${opsCase.label} rendered the wrong direction in ${combination.name}');
        expect(
          Theme.of(context).brightness,
          combination.dark ? Brightness.dark : Brightness.light,
          reason: '${opsCase.label} rendered the wrong brightness in ${combination.name}',
        );

        final captured = await captureScreen(tester, captureName(opsCase.surface, combination));
        if (captureDir != null) {
          expect(captured, isNotNull);
          expect(captured!.lengthSync(), greaterThan(1000),
              reason: 'the ${opsCase.label} capture is suspiciously small: a blank render');
        }
      });
    }
  }

  testWidgets('premise: the wallet balance really is on screen, not just in the controller',
      (tester) async {
    /// The wallet is the one screen here whose headline number is not a list row, and
    /// `available_balance` sits at a different depth from everything else in this API. A fixture
    /// that put it in the wrong place would still fill `transactions` and still pass the case
    /// above. This asserts the balance itself rendered.
    final api = ApiStub()..on('wallet/transactions', walletPage());

    await pumpScreen(tester, const WalletScreen(), api: api);

    await pumpUntil(
      tester,
      () => find.textContaining('482500').evaluate().isNotEmpty ||
          find.textContaining('482,500').evaluate().isNotEmpty,
      reason: 'the available balance never rendered; recorded calls were ${api.calls}',
    );

    await drainToasts(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('premise: an empty page really does render the empty state, not a row', (tester) async {
    /// The control for every `rowText` assertion above. If the screens rendered something that
    /// matched `textContaining` regardless of the data, those assertions would be vacuous. Here the
    /// same screen is served an EMPTY page and the row text must be absent.
    final api = ApiStub()..on('taxlist', paginated(<Object?>[]));

    await pumpScreen(tester, const TaxScreen(), api: api);
    await pumpFrames(tester);
    await drainToasts(tester);

    expect(find.textContaining('Municipality fee'), findsNothing,
        reason: 'the row text appears even with no rows, so the populated assertions prove nothing');
    expect(tester.takeException(), isNull);
  });
}

class _OpsCase {
  _OpsCase({
    required this.surface,
    required this.label,
    required this.endpoint,
    required this.body,
    required this.build,
    required this.rowText,
    this.register,
  });

  final String surface;
  final String label;
  final String endpoint;
  final Map<String, Object?> body;
  final Widget Function() build;

  /// Text from the SECOND row of the fixture, in Latin script so the assertion is readable in a
  /// failure message. The second row, not the first, so a screen that renders only one item still
  /// fails.
  final String rowText;

  final void Function()? register;
}
