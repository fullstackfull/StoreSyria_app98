import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

/// P2.5-P2 — the loading indicator never appeared, and its sibling popped whatever was on top.
/// =================================================================================================
///
/// WHAT WAS THERE, in full:
///
///     static showLoader() { const LoadingWidget(); }        // constructed, then DISCARDED
///     static hideLoader() { Get.back(closeOverlays: true); }
///
/// `showLoader()` built a widget expression and threw it away. Nothing was inserted into any
/// overlay, route or builder, so NO LOADER WAS EVER SHOWN -- at four live call sites.
///
/// `hideLoader()` was the dangerous half. With no loader to dismiss, `Get.back(closeOverlays:
/// true)` popped whatever happened to be on top of the navigation stack. At
/// `category_controller.dart:280` that runs immediately after the HTTP response and BEFORE the
/// status branches, with the category bottom sheet open -- so the sheet was dismissed on EVERY
/// outcome, including 403 and 429, losing whatever the merchant had typed and leaving them a
/// toast to explain it.
///
/// THE CALL SITES WERE ALREADY WRITTEN FOR A LOADER THAT OPENS A DIALOG. Two of the four follow
/// `showLoader()` with `if (Get.isDialogOpen ?? false) { Get.back(); }`
/// (my_plan_controller.dart:26, category_controller.dart:120) -- a guard that has been correctly
/// doing nothing, because no dialog was ever open. One (category_controller.dart:173, the search)
/// had no close at all, which is why making `showLoader()` real without fixing it would have hung
/// that flow behind a permanent modal barrier.
///
/// WHAT THESE CASES PIN. The owner's requirement is that the repair prove "unrelated routes and
/// dialogs cannot be popped", so that is asserted directly rather than inferred: `hideLoader()`
/// with no loader open must be a no-op, and anything somebody else opened must survive it.
void main() {
  /// BOUNDED PUMPS, NOT a settle.
  ///
  /// `LoadingWidget` is a `CircularProgressIndicator`, which animates for ever, so the tree never
  /// reaches quiescence and a settle times out -- the same trap this repository already records
  /// for the shimmer and for `Lottie.asset`. Every wait here is a fixed number of frames,
  /// comfortably past the 150ms dialog transition.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// A host with a navigator, so Get has somewhere to push.
  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: Center(child: Text('HOST'))),
      ),
    );
    await settle(tester);
  }

  tearDown(Get.reset);

  testWidgets('hideLoader with no loader open pops nothing', (tester) async {
    await pumpHost(tester);

    // Somebody else's dialog -- a delete confirmation, a sheet, anything.
    Get.dialog(const Scaffold(body: Center(child: Text('SOMEONE ELSES DIALOG'))));
    await settle(tester);

    expect(find.text('SOMEONE ELSES DIALOG'), findsOneWidget);

    Loader.hideLoader();
    await settle(tester);

    expect(find.text('SOMEONE ELSES DIALOG'), findsOneWidget,
        reason: 'hideLoader() dismissed a dialog it did not open. That is the defect: with no '
            'loader on screen, Get.back(closeOverlays: true) pops whatever is on top -- which at '
            'category_controller.dart:280 was the merchant\'s half-filled category sheet.');
  });

  testWidgets('hideLoader with nothing at all open does not pop the host route', (tester) async {
    await pumpHost(tester);

    Loader.hideLoader();
    await settle(tester);

    expect(find.text('HOST'), findsOneWidget,
        reason: 'hideLoader() popped the only route on the stack.');
  });

  testWidgets('showLoader then hideLoader shows and removes exactly the loader', (tester) async {
    await pumpHost(tester);

    Loader.showLoader();
    await settle(tester);

    expect(find.byType(LoadingWidget), findsOneWidget,
        reason: 'showLoader() showed nothing. It used to construct `const LoadingWidget()` as an '
            'expression and discard it.');

    Loader.hideLoader();
    await settle(tester);

    expect(find.byType(LoadingWidget), findsNothing, reason: 'the loader was not dismissed');
    expect(find.text('HOST'), findsOneWidget, reason: 'the host route was popped along with it');
  });

  testWidgets('a second showLoader does not stack a second barrier', (tester) async {
    await pumpHost(tester);

    Loader.showLoader();
    Loader.showLoader();
    await settle(tester);

    expect(find.byType(LoadingWidget), findsOneWidget,
        reason: 'two loaders are on screen; one hideLoader() would leave the other behind as a '
            'permanent barrier');

    Loader.hideLoader();
    await settle(tester);

    expect(find.byType(LoadingWidget), findsNothing);
    expect(find.text('HOST'), findsOneWidget);
  });

  testWidgets('a second hideLoader does not pop anything else', (tester) async {
    await pumpHost(tester);

    Loader.showLoader();
    await settle(tester);

    Loader.hideLoader();
    await settle(tester);

    // The over-call. A controller that closes the loader in both a success and a finally block
    // would do exactly this.
    Loader.hideLoader();
    await settle(tester);

    expect(find.text('HOST'), findsOneWidget,
        reason: 'the second hideLoader() popped the host route. hideLoader() must be a no-op '
            'once its own loader is gone.');
  });

  testWidgets('the guard the call sites already use still works', (tester) async {
    await pumpHost(tester);

    Loader.showLoader();
    await settle(tester);

    // my_plan_controller.dart:26 and category_controller.dart:120 both close the loader this way
    // rather than through hideLoader(). That has been a no-op until now; it must work.
    expect(Get.isDialogOpen ?? false, isTrue,
        reason: 'showLoader() does not register as a dialog, so the `if (Get.isDialogOpen) '
            'Get.back()` at my_plan_controller.dart:26 and category_controller.dart:120 would '
            'go on doing nothing and those two loaders would never close.');

    if (Get.isDialogOpen ?? false) Get.back();
    await settle(tester);

    expect(find.byType(LoadingWidget), findsNothing);

    // And hideLoader() afterwards must not then pop the host.
    Loader.hideLoader();
    await settle(tester);

    expect(find.text('HOST'), findsOneWidget,
        reason: 'hideLoader() popped the host after the call site had already closed the loader '
            'itself. It must notice that its loader is gone.');
  });
}
