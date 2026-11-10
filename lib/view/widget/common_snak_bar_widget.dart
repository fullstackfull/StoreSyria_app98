import 'dart:async';
import 'dart:ui'; // تأكد من استيراد هذه المكتبة إذا كنت تريد إضافة الغباشة لاحقاً

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================
// PUBLIC TYPE
// ============================================================

enum AppSnackBarType {
 success,
 error,
 warning,
 info,
}

// ============================================================
// INTERNAL TYPE
// ============================================================

enum _SnackType {
 success,
 error,
 warning,
 info,
}

// ============================================================
// COMMON TOAST
// ============================================================

void commonToast(
    String msg, {
     AppSnackBarType type = AppSnackBarType.success,
    }) {
 switch (type) {
  case AppSnackBarType.success:
   AppSnackBar.success(title: msg);
   break;

  case AppSnackBarType.error:
   AppSnackBar.error(title: msg);
   break;

  case AppSnackBarType.warning:
   AppSnackBar.warning(title: msg);
   break;

  case AppSnackBarType.info:
   AppSnackBar.info(title: msg);
   break;
 }
}

// ============================================================
// STYLE
// ============================================================

/// F277 — THE TYPE COLOUR IS PER THEME, AND IT HAS TO BE.
///
/// ══════════════════════════════════════════════════════════════════════════════════════════════
/// WHY ONE COLOUR PER TYPE COULD NEVER HAVE WORKED
/// ══════════════════════════════════════════════════════════════════════════════════════════════
///
/// The icon is painted in the type colour, on a circle of the SAME colour at 10% alpha, over the
/// toast surface — white in light mode, `#18263F` in dark. So the icon's own backdrop is a tint of
/// itself, and WCAG 2.1 SC 1.4.11 asks 3:1 for an icon that conveys meaning.
///
/// A mid-tone colour is too close to its own 10% tint over WHITE, and too close to its own 10% tint
/// over a DARK surface — in opposite directions. One value cannot satisfy both backdrops, which is
/// why exactly FOUR of the eight type/theme combinations failed and four passed. Measured on the
/// real composited backdrop by `test/a11y/toast_type_contrast_test.dart`:
///
///     success  light  2.9562  FAIL     success  dark  4.0608  ok
///     error    light  4.1329  ok       error    dark  2.9997  FAIL
///     warning  light  2.8561  FAIL     warning  dark  4.2456  ok
///     info     light  5.7945  ok       info     dark  2.1063  FAIL
///
/// `error` dark is the one worth pausing on: rounded to two places it reads 3.00 and looks like a
/// pass. It is 2.9997. The test caught it after I had already written "error passes in both
/// themes", and `error` is the type every refusal is routed to.
///
/// ══════════════════════════════════════════════════════════════════════════════════════════════
/// THE VALUES COME FROM THE STORE SYRIA DESIGN SYSTEM, NOT FROM A NEW PALETTE
/// ══════════════════════════════════════════════════════════════════════════════════════════════
///
/// `public/css/store-syria-ds.css` already defines a per-theme semantic FOREGROUND for each of
/// these four meanings, and its own comment says why: *"--ss-danger inverts between themes: dark
/// mode needs a light red that reads as text on a dark surface"*. The web had solved this; the app
/// had not. So these are that solution, transcribed:
///
///     light  success --ss-green-800 #165e34 · warning --ss-amber-900 #5d3f04
///            danger  --ss-red-800   #8c1d17 · info    --ss-blue-800  #15558f
///     dark   success #7fd6a0 · warning #f0c674 · danger #f3a9a4 · info #9cc6ef
///
/// No competing design system is introduced: the semantics are unchanged (green means success, red
/// means error, amber warns, blue informs) and only the SHADE moves with the theme — which is what
/// the design system already does on the web.
///
/// MEASURED AFTER THE CHANGE, all eight combinations clear 3:1 with room: 6.53 to 8.16. The
/// contrast test asserts every one of them in both directions, so a colour cannot regress silently
/// and a future shade change has to come past it.
class _SnackStyle {
 final IconData icon;

 /// The icon colour on a LIGHT surface — a dark shade, because its own 10% tint over white is
 /// almost white.
 final Color light;

 /// The icon colour on a DARK surface — a light shade, for the mirror-image reason.
 final Color dark;

 const _SnackStyle({
  required this.icon,
  required this.light,
  required this.dark,
 });

 /// The one accessor every consumer uses, so no site can read a theme-inappropriate shade.
 Color on(bool isDark) => isDark ? dark : light;
}

const Map<_SnackType, _SnackStyle> _styles = {
 _SnackType.success: _SnackStyle(
  icon: Icons.check_circle_rounded,
  light: Color(0xFF165E34),   // --ss-green-800
  dark: Color(0xFF7FD6A0),
 ),
 _SnackType.error: _SnackStyle(
  icon: Icons.error_rounded,
  light: Color(0xFF8C1D17),   // --ss-red-800
  dark: Color(0xFFF3A9A4),
 ),
 _SnackType.warning: _SnackStyle(
  icon: Icons.warning_rounded,
  light: Color(0xFF5D3F04),   // --ss-amber-900
  dark: Color(0xFFF0C674),
 ),
 _SnackType.info: _SnackStyle(
  icon: Icons.info_rounded,
  light: Color(0xFF15558F),   // --ss-blue-800
  dark: Color(0xFF9CC6EF),
 ),
};

// ============================================================
// PUBLIC API
// ============================================================

class AppSnackBar {
 AppSnackBar._();

 static void success({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.success,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void error({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.error,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void warning({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.warning,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void info({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.info,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void _show({
  required _SnackType type,
  required String title,
  required String message,
  required Duration duration,
 }) {
  _AppSnackBarController.show(
   type: type,
   title: title,
   message: message,
   duration: duration,
  );
 }
}

// ============================================================
// CONTROLLER
// ============================================================

class _AppSnackBarController {
 static OverlayEntry? _entry;
 static Timer? _timer;

 /// D-42.6 -- WHERE THE TOAST IS INSERTED, AND WHY IT IS NO LONGER ASKED FOR WITH `Overlay.of`.
 ///
 /// ════════════════════════════════════════════════════════════════════════════════════════════
 /// THE DEFECT THIS REPLACES
 /// ════════════════════════════════════════════════════════════════════════════════════════════
 ///
 /// This method used to do:
 ///
 ///     final context = Get.overlayContext;
 ///     if (context == null) return;
 ///     final overlay = Overlay.of(context, rootOverlay: true);
 ///
 /// which cannot resolve on Flutter 3.47.7, in the shipped app, ever:
 ///
 ///   * `Get.overlayContext` (GetX 4.7.3, `extension_navigation.dart:1150`) is
 ///     `key.currentState?.overlay?.context.visitChildElements(...)` -- the single CHILD element
 ///     of the root navigator's `OverlayState` context. `OverlayState.build` returns a
 ///     `_Theater`, so `Get.overlayContext` IS the `_Theater`, which sits ABOVE every entry.
 ///   * `Overlay.of` -> `Overlay.maybeOf` -> `_RenderTheaterMarker.maybeOf`
 ///     (`widgets/overlay.dart:634`). That marker is provided INSIDE
 ///     `_OverlayEntryWidgetState.build()` (`overlay.dart:422`), so the lookup needs an enclosing
 ///     overlay ENTRY, not an enclosing `Overlay`. From the `_Theater` there is none above, and
 ///     `maybeOf` returns null.
 ///
 /// `Overlay.of` then throws `No Overlay widget found` through its assert in debug
 /// (`overlay.dart:612`) and dereferences `result!` in release (`overlay.dart:615`). Measured in
 /// the real app shape -- `GetMaterialApp` with `builder: ThemeSwitchOverlay`, which is a `Stack`
 /// and not an `Overlay`, so nothing in the shipped tree supplies an entry above the root theater:
 ///
 ///     PROBE overlayContext widget:       _Theater
 ///     PROBE maybeOf(rootOverlay:true):   null
 ///     PROBE Get.key.currentState.overlay:OverlayState#00ea5(entries: [..., ...])
 ///
 /// So on every one of the 271 call sites -- 269 `commonToast` plus
 /// `lib/view/new_widgets/customer_contact.dart:34,40` -- a save confirmation, a refusal, a 403
 /// and a demo-mode block raised instead of appearing.
 ///
 /// ════════════════════════════════════════════════════════════════════════════════════════════
 /// THE REPAIR: ASK THE NAVIGATOR, DO NOT SEARCH UPWARDS FROM ABOVE THE ENTRIES
 /// ════════════════════════════════════════════════════════════════════════════════════════════
 ///
 /// The third probe line is the whole fix. The `OverlayState` wanted here is the one whose
 /// `_Theater` `Get.overlayContext` already returns -- `Get.key.currentState.overlay`. Reaching it
 /// downwards from the navigator instead of upwards from the theater removes the impossible
 /// lookup without changing where the toast lands: it is the SAME overlay the old code was aiming
 /// at, and it is the root navigator's, which is what `rootOverlay: true` asked for.
 ///
 /// THAT PLACEMENT ALSO KEEPS THREE THINGS THE TOAST DEPENDS ON, each pinned by a case in
 /// `test/ui/toast_overlay_test.dart` rather than asserted here:
 ///
 ///   * AMBIENT DIRECTION. `WidgetsApp` builds its `Navigator` inside `Localizations`, which
 ///     wraps its child in `Directionality` (`widgets/localizations.dart:744`). The toast is
 ///     positioned with `PositionedDirectional`, and Arabic is this app's default AND fallback
 ///     locale, so an overlay chosen ABOVE `Localizations` would mirror every Arabic toast the
 ///     wrong way.
 ///   * THE APP THEME. `Theme.of(context).brightness` picks the surface and the per-theme type
 ///     colour (F277). An overlay above the `MaterialApp` would resolve the fallback theme and
 ///     paint a light toast in a dark app.
 ///   * Z-ORDER ABOVE DIALOGS AND SHEETS. Routes are entries in this same overlay and
 ///     `OverlayState.insert` with no `below:`/`above:` appends at the top, so the toast is above
 ///     an open dialog and its modal barrier -- which is where refusals come from.
 ///
 /// NOTHING ELSE ABOUT THE TOAST MOVES: the four variants, the 3-second default, the slide/fade
 /// timing, the styling, the `Semantics(liveRegion: true, container: true)` live region from
 /// commit 83dcf49, and every public signature are untouched.
 ///
 /// ════════════════════════════════════════════════════════════════════════════════════════════
 /// WHY THERE ARE THREE STEPS AND NOT ONE
 /// ════════════════════════════════════════════════════════════════════════════════════════════
 ///
 /// Step 1 is the shipped app's path and the only one it uses. Steps 2 and 3 exist so this helper
 /// never becomes the reason a toast is lost in a tree that is shaped differently -- a nested
 /// navigator, or a harness that pumps the app under its own `Overlay`
 /// (`test/a11y/toast_announcement_test.dart` does exactly that). Step 3 is the ORIGINAL lookup,
 /// kept because it is correct for a context that genuinely is inside an entry, but through
 /// `maybeOf` -- never `of`, which is `maybeOf(...)!` with an assert in front of it and is the
 /// line this whole comment is about.
 ///
 /// `mounted` is checked on each candidate: a `GlobalKey`'s `currentState` can outlive its
 /// element, and `OverlayState.insert` on an unmounted state would assert.
 static OverlayState? _resolveOverlay() {
  // 1. The root navigator GetX itself owns -- the shipped path.
  final navigatorOverlay = Get.key.currentState?.overlay;

  if (navigatorOverlay != null && navigatorOverlay.mounted) {
   return navigatorOverlay;
  }

  final context = Get.overlayContext ?? Get.context;

  if (context == null) return null;

  // 2. The root navigator reachable from that context, for a nested or re-parented tree.
  final rootNavigatorOverlay = Navigator.maybeOf(
   context,
   rootNavigator: true,
  )?.overlay;

  if (rootNavigatorOverlay != null && rootNavigatorOverlay.mounted) {
   return rootNavigatorOverlay;
  }

  // 3. The original lookup, null-safe. Correct when the context really is inside an entry.
  return Overlay.maybeOf(
   context,
   rootOverlay: true,
  );
 }

 static void show({
  required _SnackType type,
  required String title,
  required String message,
  required Duration duration,
 }) {
  final overlay = _resolveOverlay();

  // Unchanged contract: with nowhere to put the toast, show nothing. It must not raise -- this is
  // the only feedback path for 271 call sites and a throw here is a crash on a save button.
  if (overlay == null) return;

  _remove();

  _entry = OverlayEntry(
   builder: (_) {
    return _SimpleSnackBar(
     type: type,
     title: title,
     message: message,
     onClose: _remove,
    );
   },
  );

  overlay.insert(_entry!);

  _timer = Timer(
   duration,
   _remove,
  );
 }

 static void _remove() {
  _timer?.cancel();
  _timer = null;

  final entry = _entry;

  _entry = null;

  entry?.remove();
 }
}

// ============================================================
// SNACKBAR
// ============================================================

class _SimpleSnackBar extends StatefulWidget {
 final _SnackType type;
 final String title;
 final String message;
 final VoidCallback onClose;

 const _SimpleSnackBar({
  required this.type,
  required this.title,
  required this.message,
  required this.onClose,
 });

 @override
 State<_SimpleSnackBar> createState() {
  return _SimpleSnackBarState();
 }
}

// ============================================================
// STATE
// ============================================================

class _SimpleSnackBarState extends State<_SimpleSnackBar>
    with SingleTickerProviderStateMixin {
 late final AnimationController _animationController;

 late final Animation<Offset> _slideAnimation;

 late final Animation<double> _fadeAnimation;

 @override
 void initState() {
  super.initState();

  _animationController = AnimationController(
   vsync: this,
   duration: const Duration(
    milliseconds: 250,
   ),
  );

  _slideAnimation = Tween<Offset>(
   begin: const Offset(0, -0.8),
   end: Offset.zero,
  ).animate(
   CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutCubic,
   ),
  );

  _fadeAnimation = CurvedAnimation(
   parent: _animationController,
   curve: Curves.easeOut,
  );

  _animationController.forward();
 }

 @override
 void dispose() {
  _animationController.dispose();
  super.dispose();
 }

 @override
 Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final style = _styles[widget.type]!;

  final backgroundColor = isDark ? const Color(0xFF18263F) : Colors.white;

  final titleColor = isDark ? Colors.white : const Color(0xFF0F1A2E);

  final messageColor = isDark ? const Color(0xFFA9B8D0) : const Color(0xFF6B7280);

  // Converted for consistency rather than to fix a bug: 16 on both sides is SYMMETRIC, so
  // mirroring it is a measured no-op. It is converted so that no physical `Positioned` is left in
  // lib/ at all, which lets the ratchet assert zero instead of carrying an exception nobody
  // re-reads.
  return PositionedDirectional(
   top: MediaQuery.of(context).padding.top + 12,
   start: 16,
   end: 16,
   /* P2.5 a11y -- ANNOUNCED, because until this node existed the toast was not announced at all.
      This widget is inserted as a raw `OverlayEntry` (`_AppSnackBarController.show`), and a raw
      overlay subtree with no live region is silent to TalkBack and VoiceOver. It is the ONLY
      feedback path for roughly 270 `commonToast` call sites -- every save, every refusal, every
      403, every "action not permitted" and every demo-mode block -- so a merchant using a screen
      reader pressed Save and was told nothing, with success and failure indistinguishable.

      Measured before writing it: a case-insensitive sweep of this file for
      semantic|liveRegion|announce|accessib|a11y|screen.reader|talkback|voiceover matched nothing,
      and `_SimpleSnackBar`'s subtree carried no `Semantics` node at any level.

      SAME SHAPE AS THE REST OF THE APP AND AS THE FRAMEWORK. `EmptyState`, `ErrorState` and
      `StaleDataNotice` (`error_empty_state.dart`) each carry `liveRegion: true, container: true`,
      and so does Flutter's own `SnackBar` (`material/snack_bar.dart:830`). NO `label:` HERE,
      deliberately and for the reason `error_empty_state.dart` records: a label on this node would
      duplicate the sentence the visible `Text` already carries, so a reader would meet it twice.
      `container: true` gives the flag a node of its own and lets the visible text be what is read.

      IT GOES INSIDE `PositionedDirectional`, NOT AROUND IT, and that is a layout requirement
      rather than a preference. `PositionedDirectional` builds a `Positioned`, a `ParentDataWidget`
      that applies `StackParentData` to the render object directly beneath it, and that render
      object has to be a child of the overlay's own Stack-like `_RenderTheatre`. Wrapping the root
      instead puts `RenderSemanticsAnnotations` in between and throws "Incorrect use of
      ParentDataWidget ... incompatible type ParentData" on every toast -- measured, not assumed.
      Placed here it still covers the entire visible toast, which is what a live region needs.

      Guarded by `test/a11y/toast_announcement_test.dart`, which drives `commonToast` for all four
      types and reads the live-region flag off the real semantics tree rather than off this source. */
   child: Semantics(
    liveRegion: true,
    container: true,
    child: SafeArea(
     bottom: false,
     child: SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
       opacity: _fadeAnimation,
       child: Material(
        color: Colors.transparent,
        child: Container(
         padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
         ),
         decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          // ==================================================
          // تعديل الحواف لتكون بلون النوع (Type Color)
          // ==================================================
          border: Border.all(
           color: style.on(isDark).withValues(alpha: isDark ? 0.6 : 0.3),
           width: 1.2,
          ),
          boxShadow: [
           BoxShadow(
            color: style.on(isDark).withValues(alpha: isDark ? 0.18 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
           ),
          ],
         ),
         child: Row(
          children: [
           // ==================================================
           // ICON
           // ==================================================

           Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
             color: style.on(isDark).withValues(alpha: .10),
             shape: BoxShape.circle,
            ),
            child: Icon(
             style.icon,
             color: style.on(isDark),
             size: 20,
            ),
           ),

           const SizedBox(width: 10),

           // ==================================================
           // TEXT
           // ==================================================

           Expanded(
            child: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
              Text(
               widget.title,
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
               style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: titleColor,
                height: 1.2,
               ),
              ),

              if (widget.message.trim().isNotEmpty) ...[
               const SizedBox(height: 2),
               Text(
                widget.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                 fontSize: 11.5,
                 color: messageColor,
                 height: 1.3,
                ),
               ),
              ],
             ],
            ),
           ),

           const SizedBox(width: 6),

           // ==================================================
           // CLOSE
           // ==================================================

           InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
             padding: const EdgeInsets.all(5),
             child: Icon(
              Icons.close_rounded,
              size: 18,
              // P2.5 a11y -- 2.54:1 -> 4.83:1 on the light surface.
              //
              // `#9CA3AF` on white is 2.5388:1, under the 3:1 that SC 1.4.11 asks of a UI
              // component, and this glyph is the ONLY way to dismiss a toast early: no second
              // target, no label, no gesture. It was found by looking at the Phase 2.5 captures --
              // in all four LIGHT frames the control was barely there while the dark frames showed
              // it plainly -- and then measured.
              //
              // `#6B7280` is not a new colour. It is the shade this same widget already uses for
              // its secondary text in light mode (`messageColor` above), which is exactly the
              // relationship dark mode already had: there the close icon and the message text are
              // both `#A9B8D0`. So this makes light match dark rather than inventing a value.
              //
              // Measured by `test/a11y/toast_type_contrast_test.dart`, which parses THIS ternary
              // rather than holding a copy of it -- a copy passed against the broken widget.
              color: isDark
                  ? const Color(0xFFA9B8D0)
                  : const Color(0xFF6B7280),
             ),
            ),
           ),
          ],
         ),
        ),
       ),
      ),
     ),
    ),
   ),
  );
 }
}