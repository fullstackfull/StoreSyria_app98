import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-COMP — the two shared feedback surfaces, driven rather than described.
/// =================================================================================================
///
/// Five inventory rows name these two widgets, under two sets of names, because two audit passes
/// recorded them separately:
///
///   `Shared toast (live)`                      -> AppSnackBar / commonToast
///   `Shared action feedback (AppSnackBar)`      -> the same class
///   `Shared confirmation dialog`                -> AppDialog.showCustomDialog
///   `Shared confirmation dialog (AppDialog)`    -> the same method, "12 live call sites"
///   `Shared toast (duplicate class)`            -> a DIFFERENT file; see the note at the bottom
///
/// Both are overlays, and that is why neither had ever been photographed.
/// `component_gallery_capture_test.dart:187` says so in as many words — *"`AppDialog` opens an
/// overlay, which a static gallery cannot hold; its BUTTON is the part that ships inside the
/// dialog"* — so the gallery captured `AppButton` and left the dialog itself uncaptured. A toast
/// is the same shape: `_AppSnackBarController.show` inserts an `OverlayEntry` into the root
/// navigator's overlay, which is ABOVE the screen a gallery pumps.
///
/// So this file drives the real public entry points and photographs what the overlay draws.
///
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
/// THE TOAST IS CAPTURED IN THE SHAPE THE APP ACTUALLY SHOWS, AND THAT IS A DELIBERATE NARROWING
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
///
/// `AppSnackBar.success` takes `title` AND `message`, but `commonToast` — the function all ~271
/// call sites use (`common_snak_bar_widget.dart:33`) — passes only `title`. A two-line toast is
/// therefore a state this application never renders, and capturing one would be evidence for a
/// layout no merchant can reach. Each case here goes through `commonToast`, so the captures are
/// the single-line shape, and all four TYPES are driven because `_styles` gives each its own
/// icon, accent and border (`common_snak_bar_widget.dart:104`).
///
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
/// WHY THE TOAST CASES PUMP A BOUNDED NUMBER OF FRAMES AND ONLY THEN DRAIN
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
///
/// `_SimpleSnackBarState` runs a 250 ms slide+fade on mount, and `show()` arms a 3 s
/// `Timer(duration, _remove)`. `drainToasts` advances 10 s of fake clock, so draining BEFORE the
/// capture photographs an empty screen — the toast has already removed itself. Each case pumps
/// 400 ms (animation finished, timer not fired), captures, and drains afterwards so the static
/// `_entry`/`_timer` on `_AppSnackBarController` do not survive into the next test with a
/// reference to a disposed overlay.
///
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
/// WHAT THE RTL CASES PUT ON SCREEN
/// ─────────────────────────────────────────────────────────────────────────────────────────────────
///
/// Arabic text, not English text in a mirrored box. `PositionedDirectional` and `Row` mirror on
/// direction alone, so an English string proves the geometry flipped; it does not show whether an
/// Arabic line fits the one-line layout or whether the icon still sits beside it. The strings are
/// written here rather than read through `.tr` because a capture test that resolves its own
/// fixture through the translation map is also asserting the map, and a missing key would then
/// read as a layout defect.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);

  // The shade `category_widget.dart:33` declares and passes as `confirmColor` on the destructive
  // dialog. It is a file-local const there, so it is repeated rather than imported.
  const Color danger = Color(0xFFEF4444);

  String toastText(GoldenCombination c, AppSnackBarType type) {
    final bool rtl = c.direction == TextDirection.rtl;

    switch (type) {
      case AppSnackBarType.success:
        return rtl ? 'تم حفظ المنتج بنجاح' : 'Product saved successfully';
      case AppSnackBarType.error:
        return rtl ? 'تعذّر حفظ المنتج' : 'Could not save the product';
      case AppSnackBarType.warning:
        return rtl ? 'الكمية في المخزون منخفضة' : 'Stock for this product is low';
      case AppSnackBarType.info:
        return rtl ? 'تمت مزامنة الطلبات' : 'Orders have been synced';
    }
  }

  // ===============================================================================================
  //  SHARED TOAST  /  SHARED ACTION FEEDBACK (AppSnackBar)
  // ===============================================================================================

  for (final combination in kFourCombinations) {
    for (final type in AppSnackBarType.values) {
      final String slug = 'flutter-component-toast-${type.name}';

      testWidgets('the ${type.name} toast renders in ${combination.name}', (tester) async {
        final api = ApiStub();

        await pumpScreen(
          tester,
          // A plain host. The toast does not render INSIDE this screen -- it goes to the root
          // navigator's overlay, above it -- so the host only has to exist and be neutral enough
          // that the capture is of the toast and not of a page behind it.
          const Scaffold(body: SizedBox.expand()),
          api: api,
          combination: combination,
        );

        final String message = toastText(combination, type);

        // THE REAL PUBLIC ENTRY POINT, the one ~271 call sites use.
        commonToast(message, type: type);

        // 400 ms: past the 250 ms entry animation, well short of the 3 s self-removal.
        await pumpFrames(tester, frames: 8, step: const Duration(milliseconds: 50));

        expect(tester.takeException(), isNull,
            reason: 'the ${type.name} toast threw in ${combination.name}');

        // A TOAST THAT RESOLVED NO OVERLAY SHOWS NOTHING AND DOES NOT RAISE.
        //
        // `show()` returns early when `_resolveOverlay()` is null (`common_snak_bar_widget.dart`),
        // which is the right production behaviour -- a throw there would crash a save button --
        // but it means "no exception" is NOT evidence the toast appeared. That is exactly how
        // D-42.6 survived: every call raised silently at ~271 sites and no test noticed. So the
        // message itself has to be on screen.
        final Finder text = find.text(message);

        expect(text, findsOneWidget,
            reason: 'the ${type.name} toast put nothing on screen in ${combination.name}. '
                'Either the overlay could not be resolved (D-42.6) or the entry was removed '
                'before the capture.');

        // The toast's OWN direction, read from its own subtree rather than from the host. The
        // overlay sits above the `Directionality` that `pumpScreen` wraps the screen in, so it
        // inherits direction from the app's locale -- the same chain as production.
        expect(Directionality.of(tester.element(text)), combination.direction,
            reason: 'the ${type.name} toast rendered the wrong direction in ${combination.name}');

        final captured = await captureScreen(tester, captureName(slug, combination));

        if (captureDir != null) {
          expect(captured, isNotNull);
          expect(captured!.lengthSync(), greaterThan(1000),
              reason: 'the ${type.name} toast capture is suspiciously small');
        }

        // Let the 3 s timer fire so `_remove()` detaches the entry through its own code path,
        // rather than leaving a static reference to an overlay this test is about to tear down.
        await drainToasts(tester);
        expect(find.text(message), findsNothing,
            reason: 'the toast never removed itself; its timer is not firing');
      });
    }
  }

  // ===============================================================================================
  //  SHARED CONFIRMATION DIALOG (AppDialog)
  // ===============================================================================================

  for (final combination in kFourCombinations) {
    testWidgets('the confirmation dialog renders in ${combination.name}', (tester) async {
      final api = ApiStub();

      final bool rtl = combination.direction == TextDirection.rtl;

      // The destructive shape all twelve live call sites use: a Lottie glyph, a danger-coloured
      // confirm, and a question that names what is about to be destroyed
      // (`category_widget.dart:329`, `products_screen.dart:766`, `order_screen.dart:623`, ...).
      final String title = rtl ? 'حذف' : 'Delete';
      final String message =
          rtl ? 'هل تريد حذف هذه الفئة؟' : 'Are you sure you want to delete this category?';

      late BuildContext hostContext;

      await pumpScreen(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              hostContext = context;
              return const SizedBox.expand();
            },
          ),
        ),
        api: api,
        combination: combination,
      );

      AppDialog.showCustomDialog(
        context: hostContext,
        title: title,
        message: message,
        lottieAsset: 'assets/lottie/delete_icon.json',
        confirmColor: danger,
        onConfirm: () async {},
      );

      // The dialog's own transition is 200 ms. Lottie is pumped with bounded frames and never
      // settled: a Lottie controller repeats, so `pumpAndSettle` times out on it.
      await pumpFrames(tester, frames: 10, step: const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull,
          reason: 'the confirmation dialog threw in ${combination.name}');

      expect(find.text(message), findsOneWidget,
          reason: 'the confirmation dialog put no message on screen in ${combination.name}');

      expect(Directionality.of(tester.element(find.text(message))), combination.direction,
          reason: 'the confirmation dialog rendered the wrong direction in ${combination.name}');

      final captured =
          await captureScreen(tester, captureName('flutter-component-confirm-dialog', combination));

      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the confirmation dialog capture is suspiciously small');
      }

      // Close it through the Navigator so the route is gone before teardown.
      Navigator.of(hostContext, rootNavigator: true).pop();
      await pumpFrames(tester, frames: 8);
    });
  }
}
