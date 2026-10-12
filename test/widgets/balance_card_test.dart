// Regression guard for R7-N3 -- the wallet card showed a hard "0" while loading.
//
// `balanceCard` read `controller.availableBalance.value` into a local OUTSIDE
// the `Obx` builder. That breaks twice over:
//
//   * GetX registers an observable as a dependency of an Obx only when it is
//     read INSIDE the builder, so the read outside registered nothing; and
//   * a local captured outside the closure is not re-evaluated when the
//     closure re-runs, so the value was a snapshot frozen at
//     widget-construction time.
//
// The guard it fed was `balance.isEmpty || balance == null`. The `== null`
// half was dead -- the local is a non-nullable String, which the analyzer
// reported as `unnecessary_null_comparison`. The `isEmpty` half could never
// fire either, because availableBalance is seeded with '0'
// (wallet_controller.dart:21) and '0' is not empty.
//
// Net effect: the CircularProgressIndicator was unreachable, and a merchant
// opening the wallet was shown a confident "0" balance that was really just
// "not loaded yet". For a wallet figure that is not a cosmetic bug -- a zero
// balance the merchant does not actually have is worse than a spinner.
//
// These tests pump the real widget with a real WalletController and assert on
// what is on screen. WalletController is constructed directly rather than via
// Get.put, because onInit() fires getWalletData() and would reach the network.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/wallet/wallet_controller.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/new_widgets/balance_card.dart';

void main() {
  setUpAll(() {
    Get.addTranslations({'en': en});
    Get.locale = const Locale('en', 'US');
  });

  Widget host(WalletController controller) {
    // ScreenUtil is required because the card sizes itself with .w/.h/.r/.sp.
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => balanceCard(
              isDark: false,
              controller: controller,
              context: context,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a loading wallet shows a spinner, not a "0" balance',
      (tester) async {
    final controller = WalletController();
    controller.isLoading.value = true;
    controller.availableBalance.value = '0'; // the seeded value

    await tester.pumpWidget(host(controller));
    await tester.pump();

    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
      reason: 'While the wallet is loading the merchant must not be shown a '
          'balance figure at all.',
    );
    expect(
      find.text('0'),
      findsNothing,
      reason: 'A "0" here reads as a real zero balance.',
    );
  });

  testWidgets('a loaded wallet shows the balance and no spinner',
      (tester) async {
    final controller = WalletController();
    controller.isLoading.value = false;
    controller.availableBalance.value = '1234.50';

    await tester.pumpWidget(host(controller));
    await tester.pump();

    expect(find.text('1234.50'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('the balance is reactive: it updates without a parent rebuild',
      (tester) async {
    // This is the property the stale capture destroyed. The Obx must re-read
    // the observable, not replay a value captured when balanceCard() ran.
    final controller = WalletController();
    controller.isLoading.value = true;
    controller.availableBalance.value = '0';

    await tester.pumpWidget(host(controller));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Exactly what getWalletData() does on success -- and nothing rebuilds
    // the parent, so only the Obx subscription can surface this.
    controller.availableBalance.value = '987.65';
    controller.isLoading.value = false;
    await tester.pump();

    expect(find.text('987.65'), findsOneWidget);
    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
      reason: 'The Obx must have re-run and re-read the observable.',
    );
  });

  testWidgets('an empty balance still shows the spinner', (tester) async {
    // The original intent of the `isEmpty` branch, kept: a blank figure is
    // not something to render as a balance either.
    final controller = WalletController();
    controller.isLoading.value = false;
    controller.availableBalance.value = '';

    await tester.pumpWidget(host(controller));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a later balance change is picked up too', (tester) async {
    // Guards against a fix that re-reads once but then re-freezes.
    final controller = WalletController();
    controller.isLoading.value = false;
    controller.availableBalance.value = '10.00';

    await tester.pumpWidget(host(controller));
    await tester.pump();
    expect(find.text('10.00'), findsOneWidget);

    controller.availableBalance.value = '20.00';
    await tester.pump();

    expect(find.text('20.00'), findsOneWidget);
    expect(find.text('10.00'), findsNothing);
  });
}
