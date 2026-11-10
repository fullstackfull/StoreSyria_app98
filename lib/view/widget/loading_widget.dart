import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';

/// The app-wide blocking loader.
///
/// WHAT THIS USED TO BE, in full:
///
///     static showLoader() { const LoadingWidget(); }        // constructed, then DISCARDED
///     static hideLoader() { Get.back(closeOverlays: true); }
///
/// `showLoader()` built a widget expression and threw it away. Nothing was inserted into any
/// overlay, route or builder, so **no loader was ever shown** -- at four live call sites
/// (my_plan_controller.dart:22 and category_controller.dart:116, :173, :225).
///
/// `hideLoader()` was the dangerous half. With no loader to dismiss, `Get.back(closeOverlays:
/// true)` popped whatever happened to be on top of the navigation stack. At
/// `category_controller.dart:280` that runs immediately after the HTTP response and BEFORE the
/// status branches, with the category bottom sheet open -- so the sheet was dismissed on EVERY
/// outcome, 403 and 429 included, losing whatever the merchant had typed and leaving them a toast
/// to explain it.
///
/// TWO RULES NOW, and the second is the one the repair is judged on.
///
/// 1. `showLoader()` opens a real dialog, which is what the call sites were already written for:
///    two of the four follow it with `if (Get.isDialogOpen ?? false) { Get.back(); }`
///    (my_plan_controller.dart:26, category_controller.dart:120), a guard that had been correctly
///    doing nothing because no dialog was ever open.
///
/// 2. **`hideLoader()` closes only what `showLoader()` opened, and nothing else.** If no loader is
///    up -- because none was shown, or because the call site already closed it with its own
///    guard, or because `hideLoader()` was called twice -- it returns without touching the
///    navigation stack. That is asserted directly by
///    test/a11y/loader_does_not_pop_unrelated_routes_test.dart, which opens somebody else's
///    dialog and requires it to survive.
///
/// `_open` is cleared by `whenComplete` as well as by `hideLoader()`, so a call site that
/// dismisses the dialog itself leaves this class in a truthful state rather than a stale one.
///
/// NO `PopScope`. The barrier is not dismissible by tapping, but the system back button still
/// closes it deliberately: a flow that forgets to hide the loader should strand the merchant for
/// one back press, not for ever. `category_controller.searchCategoryData` had no close at all
/// until this change, which is exactly the omission that failure mode is chosen for.
class Loader {
  Loader._();

  static bool _open = false;

  /// Visible for testing: is this class's own loader currently up?
  static bool get isShowing => _open;

  static void showLoader() {
    // Never stack. Two loaders mean one `hideLoader()` leaves a permanent barrier behind.
    if (_open) return;

    // NOTHING TO ATTACH TO IS NOT AN ERROR. `Get.dialog` reads
    // `Get.key.currentState!` (get_navigation/src/extension_navigation.dart:81), so calling this
    // before the navigator exists throws "Null check operator used on a null value" -- which is
    // what happened the moment the loader became real, in every controller test that drives
    // `getCategoryData` without an app mounted.
    //
    // A loader is decoration around work that is happening anyway, so the right behaviour when
    // there is no surface to draw on is to draw nothing and let the work proceed. Crashing the
    // caller because its progress indicator had nowhere to go is the wrong trade in production
    // too, not only in tests.
    if (Get.key.currentState == null) return;

    _open = true;

    Get.dialog<void>(
      const LoadingWidget(),
      barrierDismissible: false,
    ).whenComplete(() {
      // Reached however the dialog went away -- our own hideLoader(), a call site's
      // `if (Get.isDialogOpen) Get.back()`, or the back button. Keeping the flag honest is what
      // stops the NEXT hideLoader() from popping something it has no business popping.
      _open = false;
    });
  }

  static void hideLoader() {
    if (!_open) return;

    _open = false;

    if (Get.isDialogOpen ?? false) {
      Get.back<void>();
    }
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColor.themeNavyBlueColor),
    );
  }
}
