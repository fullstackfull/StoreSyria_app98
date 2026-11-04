// P2.5 D-42.6 — the shared toast never reached an overlay in the shipped app.
// =================================================================================================
//
// THE DEFECT, MEASURED RATHER THAN REASONED ABOUT.
//
// `_AppSnackBarController.show()` resolved its overlay like this:
//
//     final context = Get.overlayContext;        // GetX 4.7.3
//     if (context == null) return;
//     final overlay = Overlay.of(context, rootOverlay: true);
//
// Both halves are individually reasonable and together they cannot work on Flutter 3.47.7:
//
//   * `Get.overlayContext` (`extension_navigation.dart:1150`) is
//     `key.currentState?.overlay?.context.visitChildElements(...)` — the single child element of the
//     root navigator's `OverlayState` context. `OverlayState.build` returns a `_Theater`, so
//     `Get.overlayContext` is the `_Theater` element, which sits ABOVE every overlay entry.
//   * `Overlay.of` → `Overlay.maybeOf` → `_RenderTheaterMarker.maybeOf` (`overlay.dart:634`,
//     `:2320`). That marker is provided INSIDE `_OverlayEntryWidgetState.build()`
//     (`overlay.dart:422`), so the lookup answers only for a context that is inside an overlay
//     ENTRY. From the `_Theater` there is no marker above, so it returns null.
//
// `Overlay.of` then throws `No Overlay widget found` through its assert in debug, and dereferences
// `result!` in release. Either way `commonToast` raised instead of showing anything — on the ONLY
// feedback path for 271 call sites (269 `commonToast` + 2 `AppSnackBar.info`, counted below in the
// public-surface case). Every save confirmation, every refusal, every 403 and every demo-mode
// block was silently lost.
//
// MEASURED IN THE REAL APP SHAPE, which is the part that makes this a production defect and not a
// harness artefact. `GetMaterialApp`'s `builder:` installs `ThemeSwitchOverlay`
// (`lib/view/widget/theme_switch_overlay.dart`), which is a `Stack` — not an `Overlay`. So nothing
// in the shipped tree puts an overlay entry above the root `_Theater`:
//
//     PROBE overlayContext widget:       _Theater
//     PROBE maybeOf(rootOverlay:true):   null
//     PROBE Get.key.currentState.overlay:OverlayState#00ea5(entries: [..., ...])
//
// The third line is the repair: the `OverlayState` the toast wants is the one GetX already holds a
// navigator for. It is reached by ASKING the navigator, not by searching upwards from a context
// that is above every entry.
//
// ─────────────────────────────────────────────────────────────────────────────────────────────────
// WHY THERE IS NO OUTER `Overlay` IN THIS HARNESS
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//
// `test/a11y/toast_announcement_test.dart` wraps the app in an outer `Overlay` and says in its own
// header that the wrapper is a harness crutch hiding a larger defect. It is the larger defect that
// is repaired here, so this file must not use that crutch: with an outer `Overlay` present the OLD
// code resolves and every case below would pass against the bug. Instead each case asserts, as a
// PREMISE, that the defect's precondition is still in place — `Get.overlayContext` is a `_Theater`
// and `Overlay.maybeOf(..., rootOverlay: true)` on it is null — and only then asks whether the
// toast rendered. A vacuous pass is therefore impossible: if a future Flutter or GetX made the old
// lookup work, the premise fails loudly rather than the suite going quietly green for free.
//
// ─────────────────────────────────────────────────────────────────────────────────────────────────
// WHAT CANNOT BE VERIFIED HERE, STATED PLAINLY
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//
//   * NO DEVICE AND NO EMULATOR. `flutter test` runs on the Dart VM with a headless harness. Nothing
//     here proves a handset shows the toast, that TalkBack or VoiceOver speaks it, or how it looks.
//   * NO RELEASE RUN. A widget test always runs with asserts enabled, so the release failure mode —
//     `Overlay.of`'s `result!` on a null, rather than its assert — cannot be executed. The release
//     claim here is an INFERENCE, not a measurement: the premise assertion measures that
//     `Overlay.maybeOf(...)` is null in the real app shape, `Overlay.of` is `maybeOf(...)!`, so the
//     old line could only throw in release too; and the repaired resolution contains no `!` and no
//     `Overlay.of`, which the last case drives against a tree with no navigator at all.
//   * NO GOLDEN IMAGES. Colours and geometry below are read off the resolved widgets, not compared
//     against a rendered baseline.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/theme_switch_overlay.dart';

/// The shipped app root, reproduced: `ScreenUtilInit` → `GetMaterialApp` → `builder:
/// ThemeSwitchOverlay`, exactly as `lib/store_go.dart:33-76` wires it. NO outer `Overlay`.
///
/// The one departure is the theme: `lib/store_go.dart` passes `themeController.theme`, and
/// `ThemeController` reads `GetStorage`, which a widget test cannot initialise (test/README.md
/// records `pumpWidget` throwing on a null `getStorage`). The toast reads nothing from the theme
/// but `Theme.of(context).brightness`, so a plain light/dark `ThemeData` exercises the same code
/// path — and the light/dark cases below assert the brightness the toast actually resolves, as a
/// premise, rather than assuming it.
Future<void> _pumpRealApp(
  WidgetTester tester, {
  Locale locale = const Locale('en', 'US'),
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        fallbackLocale: TranslationService.fallbackLocale,
        translations: TranslationService(),
        localizationsDelegates: TranslationService.localizationsDelegates,
        supportedLocales: TranslationService.supportedLocales,
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: const Scaffold(body: Center(child: Text('ORIGIN'))),
        builder: (context, child) =>
            ThemeSwitchOverlay(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The premise every case shares: the app is up AND the defect's precondition is still real.
///
/// Without the second half a case could pass because some future Flutter made
/// `Overlay.of(Get.overlayContext)` work again, and the repair would be untested while the suite
/// stayed green. This repository has published a measurement taken from a tree that was not the one
/// under test before, so the precondition is asserted rather than assumed.
///
/// `visible` is the marker that proves the app is on screen. It is a PARAMETER because the default
/// 'ORIGIN' is wrong after a push: `Get.to` installs an OPAQUE route, so the `home:` text is no
/// longer in the tree and asserting it would fail for a reason that has nothing to do with the
/// toast. Measured -- the pushed-route case below failed on exactly that before this was threaded
/// through.
void _assertDefectPreconditionStillHolds({String visible = 'ORIGIN'}) {
  expect(find.text(visible), findsOneWidget,
      reason: 'premise: the app did not pump, so nothing below is about the toast');

  final BuildContext? overlayContext = Get.overlayContext;
  expect(overlayContext, isNotNull,
      reason: 'premise: GetX resolved no overlay context at all, so this case is not exercising '
          'the shape the defect lives in');
  expect(overlayContext!.widget.runtimeType.toString(), '_Theater',
      reason: 'premise: Get.overlayContext is no longer the _Theater element. GetX 4.7.3 defines '
          'it as the single child of the root OverlayState context; if that changed, this file is '
          'measuring a different mechanism than the one it was written for');
  expect(Overlay.maybeOf(overlayContext, rootOverlay: true), isNull,
      reason: 'premise: Overlay.maybeOf now resolves from the _Theater, so the ORIGINAL code would '
          'work and every assertion below would pass against the bug. The repair must be '
          're-proved, or this premise removed deliberately — not quietly.');
}

/// True when `node` or any of its ancestors is a live region.
///
/// Ancestors, because the widget deliberately sets `container: true` with no `label:`, which puts
/// the flag on a node ABOVE the message's own node.
bool _isInsideLiveRegion(SemanticsNode node) {
  SemanticsNode? current = node;
  while (current != null) {
    if (current.flagsCollection.isLiveRegion) return true;
    current = current.parent;
  }
  return false;
}

/// The toast's surface `Container` — the one carrying the 14px radius, not the icon's circle.
Container _toastSurface(WidgetTester tester, String message) {
  final List<Container> matches = tester
      .widgetList<Container>(
        find.ancestor(of: find.text(message), matching: find.byType(Container)),
      )
      .where((Container c) {
        final Decoration? d = c.decoration;
        return d is BoxDecoration && d.borderRadius == BorderRadius.circular(14);
      })
      .toList();

  expect(matches, hasLength(1),
      reason: 'premise: expected exactly one 14px-radius surface above the toast message, found '
          '${matches.length}; the finder below would read the wrong widget');
  return matches.single;
}

/// Lets the controller's own `Timer` fire so the entry is removed the way production removes it.
/// Without this the test ends with a pending timer and fails for an unrelated reason.
Future<void> _letTheToastExpire(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  // ===============================================================================================
  // 1. THE FOUR VARIANTS STILL REACH THE MERCHANT — one case each, per test/README.md
  // ===============================================================================================

  const Map<AppSnackBarType, (String, IconData)> variants =
      <AppSnackBarType, (String, IconData)>{
    AppSnackBarType.success: ('Product saved', Icons.check_circle_rounded),
    AppSnackBarType.error: ('Action not permitted', Icons.error_rounded),
    AppSnackBarType.warning: ('Stock is running low', Icons.warning_rounded),
    AppSnackBarType.info: ('Sync finished', Icons.info_rounded),
  };

  for (final MapEntry<AppSnackBarType, (String, IconData)> entry in variants.entries) {
    final String type = entry.key.name;
    final (String message, IconData icon) = entry.value;

    testWidgets('a $type toast reaches the merchant in the real app shape', (tester) async {
      await _pumpRealApp(tester);
      _assertDefectPreconditionStillHolds();

      commonToast(message, type: entry.key);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'commonToast raised instead of showing a $type toast. This is the defect: '
              'Overlay.of(Get.overlayContext, rootOverlay: true) cannot resolve, so it throws '
              'through its assert in debug and dereferences null in release.');
      expect(find.text(message), findsOneWidget,
          reason: 'the $type toast did not render, so this feedback never reached the merchant');
      expect(find.byIcon(icon), findsOneWidget,
          reason: 'the $type variant lost its icon, so the four variants are no longer distinct');

      await _letTheToastExpire(tester);
    });
  }

  // ===============================================================================================
  // 2. NAVIGATION CONTEXT — a toast raised from a PUSHED route, which is where most of the 271
  //    call sites live (a form screen, a bottom sheet, a detail page), not from `home:`.
  // ===============================================================================================

  testWidgets('a toast raised from a pushed route reaches the merchant', (tester) async {
    await _pumpRealApp(tester);

    Get.to(() => const Scaffold(body: Center(child: Text('EDIT PRODUCT'))));
    await tester.pumpAndSettle();

    _assertDefectPreconditionStillHolds(visible: 'EDIT PRODUCT');

    commonToast('Product saved');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'commonToast raised from a pushed route');
    expect(find.text('Product saved'), findsOneWidget,
        reason: 'a save confirmation raised from a pushed route never reached the merchant');
    // The pushed route is still under it: a toast must not replace the screen.
    expect(find.text('EDIT PRODUCT'), findsOneWidget);

    await _letTheToastExpire(tester);
  });

  // ===============================================================================================
  // 3. DIALOG CONTEXT — and the z-order, proved by HIT TEST rather than by eye.
  // ===============================================================================================

  testWidgets('a toast raised while a dialog is open paints above its barrier', (tester) async {
    await _pumpRealApp(tester);

    Get.dialog<void>(
      const AlertDialog(content: Text('DELETE THIS PRODUCT?')),
    );
    await tester.pumpAndSettle();

    expect(find.text('DELETE THIS PRODUCT?'), findsOneWidget,
        reason: 'premise: no dialog is open, so this case is not about a dialog context');
    expect(find.byType(ModalBarrier), findsWidgets,
        reason: 'premise: the dialog has no modal barrier, so the z-order question below is moot');
    _assertDefectPreconditionStillHolds();

    commonToast('Action not permitted', type: AppSnackBarType.error);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'commonToast raised over an open dialog');
    expect(find.text('Action not permitted'), findsOneWidget,
        reason: 'a refusal raised while a dialog was open never reached the merchant — and a '
            'refusal is exactly what a confirm dialog produces');

    // THE Z-ORDER PROOF. A dialog's `ModalBarrier` covers the whole screen and pops the route when
    // tapped. If the toast were BELOW the barrier, this tap would land on the barrier: the dialog
    // would close and the toast would stay. Asserting the opposite pair proves the toast is on top
    // and hit-testable, without reading a private entry list.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Action not permitted'), findsNothing,
        reason: 'the toast close button did not dismiss the toast, so the tap did not reach it — '
            'the toast is under the dialog barrier');
    expect(find.text('DELETE THIS PRODUCT?'), findsOneWidget,
        reason: 'the tap went through to the dialog barrier and closed the dialog, so the toast is '
            'painted below it');
  });

  // ===============================================================================================
  // 4. ARABIC (RTL) AND ENGLISH (LTR)
  // ===============================================================================================

  testWidgets('the toast inherits LTR from an English app', (tester) async {
    await _pumpRealApp(tester, locale: const Locale('en', 'US'));
    _assertDefectPreconditionStillHolds();

    commonToast('Product saved');
    await tester.pumpAndSettle();

    expect(find.text('Product saved'), findsOneWidget,
        reason: 'premise: no toast, so there is no direction to read');
    expect(Directionality.of(tester.element(find.text('Product saved'))), TextDirection.ltr,
        reason: 'the toast subtree does not see the app ambient direction');

    await _letTheToastExpire(tester);
  });

  testWidgets('the toast inherits RTL from an Arabic app, and keeps its 16/16 insets',
      (tester) async {
    // THE REAL RISK THIS PINS. The toast is positioned with `PositionedDirectional`, which resolves
    // start/end against the AMBIENT `Directionality`. That direction comes from `Localizations`
    // (`localizations.dart:744`), which in `WidgetsApp` encloses the Navigator — and therefore the
    // Navigator's own overlay. Inserting into an overlay ABOVE `Localizations` (the shape the
    // a11y harness fakes with its outer `Overlay`) would hand an Arabic merchant an LTR toast.
    // Arabic is this app's default AND fallback locale, so that is the common case, not the edge.
    await _pumpRealApp(tester, locale: const Locale('ar', 'AE'));
    _assertDefectPreconditionStillHolds();

    commonToast('تم الحفظ');
    await tester.pumpAndSettle();

    expect(find.text('تم الحفظ'), findsOneWidget,
        reason: 'premise: no toast in an Arabic app, so there is no direction to read');
    expect(Directionality.of(tester.element(find.text('تم الحفظ'))), TextDirection.rtl,
        reason: 'the toast resolved LTR inside an Arabic app, so every *Directional offset in it '
            'mirrors the wrong way — the toast is being inserted outside Localizations');

    final Finder safeArea =
        find.ancestor(of: find.text('تم الحفظ'), matching: find.byType(SafeArea));
    expect(safeArea, findsOneWidget,
        reason: 'premise: the toast no longer has exactly one SafeArea above its message, so the '
            'geometry read below is from the wrong widget');

    final Rect rect = tester.getRect(safeArea);
    expect(rect.left, 16.0, reason: 'the start inset changed');
    expect(rect.right, 360.0 - 16.0, reason: 'the end inset changed');
    expect(rect.top, 12.0,
        reason: 'the top offset changed; it is MediaQuery padding (0 here) + 12');

    await _letTheToastExpire(tester);
  });

  // ===============================================================================================
  // 5. LIGHT AND DARK
  // ===============================================================================================

  testWidgets('the toast paints the light surface in a light app', (tester) async {
    await _pumpRealApp(tester, dark: false);
    _assertDefectPreconditionStillHolds();

    commonToast('Product saved');
    await tester.pumpAndSettle();

    expect(find.text('Product saved'), findsOneWidget, reason: 'premise: no toast to inspect');
    expect(Theme.of(tester.element(find.text('Product saved'))).brightness, Brightness.light,
        reason: 'premise: the toast subtree does not resolve the app theme, so the colour below '
            'says nothing about light mode');

    final BoxDecoration d = _toastSurface(tester, 'Product saved').decoration! as BoxDecoration;
    expect(d.color, Colors.white, reason: 'the light-mode toast surface changed');

    await _letTheToastExpire(tester);
  });

  testWidgets('the toast paints the dark surface in a dark app', (tester) async {
    await _pumpRealApp(tester, dark: true);
    _assertDefectPreconditionStillHolds();

    commonToast('Product saved');
    await tester.pumpAndSettle();

    expect(find.text('Product saved'), findsOneWidget, reason: 'premise: no toast to inspect');
    expect(Theme.of(tester.element(find.text('Product saved'))).brightness, Brightness.dark,
        reason: 'premise: the toast subtree does not resolve the app theme, so a dark surface here '
            'would be an accident. This is the assertion that would catch an overlay chosen ABOVE '
            'the MaterialApp Theme.');

    final BoxDecoration d = _toastSurface(tester, 'Product saved').decoration! as BoxDecoration;
    expect(d.color, const Color(0xFF18263F), reason: 'the dark-mode toast surface changed');

    await _letTheToastExpire(tester);
  });

  // ===============================================================================================
  // 6. ACCESSIBILITY — the commit-83dcf49 live region, re-proved WITHOUT the outer-Overlay crutch
  // ===============================================================================================

  testWidgets('the toast is announced to a screen reader in the real app shape', (tester) async {
    // Disposed at the END OF THE BODY, not via addTearDown: flutter_test runs
    // `_verifySemanticsHandlesWereDisposed` before tearDown callbacks.
    final SemanticsHandle handle = tester.ensureSemantics();

    await _pumpRealApp(tester);
    _assertDefectPreconditionStillHolds();

    commonToast('Product saved');
    await tester.pumpAndSettle();

    expect(find.text('Product saved'), findsOneWidget,
        reason: 'premise: the toast did not render, so this case cannot say whether it is '
            'announced');

    final SemanticsNode node = tester.getSemantics(find.text('Product saved'));
    expect(_isInsideLiveRegion(node), isTrue,
        reason: 'the toast is not inside a live region. commit 83dcf49 added it and '
            'test/a11y/toast_announcement_test.dart proves it under an outer Overlay; this case '
            'proves it in the shape the app actually ships.');

    await _letTheToastExpire(tester);
    handle.dispose();
  });

  // ===============================================================================================
  // 7. TIMING AND REPLACEMENT — the behaviours the owner required be preserved
  // ===============================================================================================

  testWidgets('the toast dismisses itself after the 3-second default, not before', (tester) async {
    await _pumpRealApp(tester);
    _assertDefectPreconditionStillHolds();

    commonToast('Product saved');
    await tester.pumpAndSettle();
    expect(find.text('Product saved'), findsOneWidget, reason: 'premise: no toast to time');

    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.text('Product saved'), findsOneWidget,
        reason: 'the toast vanished before 3 seconds; the default duration changed');

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    expect(find.text('Product saved'), findsNothing,
        reason: 'the toast outlived its 3-second timer, so it now has to be dismissed by hand');
  });

  testWidgets('a second toast replaces the first rather than stacking on it', (tester) async {
    await _pumpRealApp(tester);
    _assertDefectPreconditionStillHolds();

    commonToast('Product saved');
    await tester.pumpAndSettle();
    expect(find.text('Product saved'), findsOneWidget, reason: 'premise: the first toast is up');

    commonToast('Action not permitted', type: AppSnackBarType.error);
    await tester.pumpAndSettle();

    expect(find.text('Product saved'), findsNothing,
        reason: 'the first toast is still on screen, so toasts now stack — two overlay entries '
            'overlapping at the same offset');
    expect(find.text('Action not permitted'), findsOneWidget);

    await _letTheToastExpire(tester);
  });

  // ===============================================================================================
  // 8. THE PUBLIC SURFACE 271 CALL SITES DEPEND ON — compiled, not grepped
  // ===============================================================================================

  testWidgets('every public entry point still compiles and shows a toast', (tester) async {
    // THIS CASE IS A COMPILE-TIME PIN AS MUCH AS A RUNTIME ONE. If any signature below changed,
    // this file would not analyse — which is the point: 269 `commonToast(` call sites and 2
    // `AppSnackBar.info(` sites (`lib/view/new_widgets/customer_contact.dart:34,40`) depend on
    // them. Counted with grep over lib/ on 2026-11-04; the brief this work came from said
    // "275 = 269 + 6", and the 6 is the number of `AppSnackBar.` mentions INSIDE
    // common_snak_bar_widget.dart (4 in commonToast's switch + the private constructor), not call
    // sites elsewhere.
    await _pumpRealApp(tester);
    _assertDefectPreconditionStillHolds();

    commonToast('positional only');
    await tester.pumpAndSettle();
    expect(find.text('positional only'), findsOneWidget);
    await _letTheToastExpire(tester);

    commonToast('with a named type', type: AppSnackBarType.warning);
    await tester.pumpAndSettle();
    expect(find.text('with a named type'), findsOneWidget);
    await _letTheToastExpire(tester);

    AppSnackBar.success(title: 'success title');
    await tester.pumpAndSettle();
    expect(find.text('success title'), findsOneWidget);
    await _letTheToastExpire(tester);

    AppSnackBar.error(title: 'error title', message: 'and a body');
    await tester.pumpAndSettle();
    expect(find.text('error title'), findsOneWidget);
    expect(find.text('and a body'), findsOneWidget,
        reason: 'the optional second line stopped rendering');
    await _letTheToastExpire(tester);

    AppSnackBar.warning(title: 'warning title');
    await tester.pumpAndSettle();
    expect(find.text('warning title'), findsOneWidget);
    await _letTheToastExpire(tester);

    AppSnackBar.info(title: 'info title', duration: const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('info title'), findsOneWidget,
        reason: 'the custom-duration overload stopped showing anything');
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.text('info title'), findsNothing,
        reason: 'an explicit duration: is no longer honoured');
  });

  // ===============================================================================================
  // 9. RELEASE-COMPATIBLE BEHAVIOUR — no `!` on a resolution that can legitimately be null
  // ===============================================================================================

  testWidgets('with no navigator at all the toast returns silently instead of raising',
      (tester) async {
    // THE RELEASE-SHAPE GUARD, and it is honest about what it is: this case passed against the
    // ORIGINAL code too, because the original returned early on a null `Get.overlayContext`. It is
    // here so the REPAIR cannot regress into the failure mode it removes. The repaired resolution
    // must degrade to "show nothing" when there is genuinely no overlay, not throw — in debug by
    // assert or in release by `result!`, which is precisely how the old line failed.
    Get.reset();

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(),
          child: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.key.currentState, isNull,
        reason: 'premise: a navigator resolved, so this is not the no-overlay case');
    expect(Get.overlayContext, isNull,
        reason: 'premise: an overlay context resolved, so this is not the no-overlay case');

    commonToast('nowhere to put this');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'the toast raised when there was no overlay to insert into. In release that is a '
            'null dereference and a crash on a path 271 call sites reach.');
    expect(find.text('nowhere to put this'), findsNothing);
  });
}
