import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';


class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final double? iconSize;
  final Color? iconColor;
  final Widget? actionWidget;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.iconSize,
    this.iconColor,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /* P2-07-8. ANNOUNCED, because replacing a list with this widget is a state change a screen
       reader is otherwise never told about. The merchant hears the list, the list is swapped for
       "no customers found", and nothing is said: as far as the reader is concerned the screen
       simply went quiet. `liveRegion` makes the framework announce the label when this subtree
       appears or its text changes.

       Measured before writing it: `liveRegion`, `Semantics(`, `semanticLabel`, `MergeSemantics`
       and `ExcludeSemantics` each appeared ZERO times across lib/, so nothing in this app
       announced any state change at all.

       It goes on the shared widget rather than on each screen, so every list that adopts
       `EmptyState` or `ErrorState` gets it -- the same leverage the web used by putting the
       announcement in one place instead of at sixty call sites.

       NO `label:` HERE, DELIBERATELY. Setting one duplicated the message: this node carried it
       AND the `Text` below carried it, so a reader met the same sentence twice and
       `find.bySemanticsLabel` matched two elements -- which is how the duplication surfaced.
       `container: true` gives the flag a node of its own and lets the visible text remain the
       thing that is read. */
    return Semantics(
      liveRegion: true,
      container: true,
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /* P2.5-A-04. BOTH OF THESE WERE Colors.grey.shade400 (#BDBDBD) IN LIGHT MODE,
                     which measures 1.88:1 on the light background -- against 4.5:1 for the text
                     and 3:1 for the icon. Not "low contrast": a merchant whose list is empty was
                     shown a sentence they could not read telling them why. The dark side was
                     already fine at 8.94:1 and 3.54:1, which is the usual shape of this defect.

                     They now read the app's OWN secondary-text colours rather than naming a grey
                     -- LightThemeColor.cFont (#66728C, 4.83:1) and DarkThemeColor.cSecondaryText
                     (#A9B8D0, 8.66:1) -- the same correction P2.5-D-02 made to the text fields,
                     so the empty state matches every other muted line instead of being its own
                     grey.

                     THE ICON IS AS DARK AS THE TEXT, deliberately. An empty-state icon is usually
                     lighter than its label, but it carries the meaning of the screen, so 3:1 is a
                     floor and no tint of this colour clears it while still reading as lighter.
                     The hierarchy comes from size -- 72r against 16sp -- which costs no contrast.
                     `iconColor` still overrides, and a test asserts it does. */
                  Icon(
                    icon,
                    size: iconSize ?? 72.r,
                    color: iconColor ??
                        (isDark ? DarkThemeColor.cSecondaryText : LightThemeColor.cFont),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isDark ? DarkThemeColor.cSecondaryText : LightThemeColor.cFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (actionWidget != null) ...[
                    SizedBox(height: 24.h),
                    actionWidget!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // P2-07-8. Announced for the same reason as EmptyState above -- and more urgently, since a
    // failure the merchant is never told about leaves them waiting for data that is not coming.
    return Semantics(
      liveRegion: true,
      container: true,
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .08),
                      shape: BoxShape.circle,
                    ),
                    // P2.5-A-04. Was Colors.grey (#9E9E9E) -- 2.68:1 on the light background,
                    // under the 3:1 WCAG 1.4.11 asks of a graphic that carries meaning. The tinted
                    // circle behind it is only 8% grey, so it does not lift the pairing.
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 46.sp,
                      color: isDark ? DarkThemeColor.cSecondaryText : LightThemeColor.cFont,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    "something_went_wrong".tr,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    message.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark
                          ? Colors.white60
                          : Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  if (onRetry != null)
                    IconButton(
                      // Accessible name: this control has no visible text.
                      tooltip: 'retry'.tr,
                      onPressed: onRetry,
                      icon: Icon(Icons.refresh,size: 30.w,),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.themeNavyBlueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

/// WS K. An INLINE notice that the list below may be out of date.
///
/// `ErrorState` above answers the case where a failure left NOTHING to show.
/// This answers the other one: the refresh failed and the previous rows are
/// still on screen. Keeping them is right -- blanking a list on a transient
/// network failure is worse than holding it -- but until now the only signal
/// was a three-second toast, after which the screen was indistinguishable from
/// a successful refresh. The merchant acted on rows that could be hours old,
/// and the header's counts were the old counts.
///
/// It is a NOTICE, not a blocker: the list stays scrollable and usable beneath
/// it, because stale data a merchant knows is stale is still useful.
///
/// `liveRegion`, for the same reason `ErrorState` carries one -- a merchant
/// using a screen reader is the one most likely to have missed the toast too.
class StaleDataNotice extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const StaleDataNotice({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /* F277's LESSON, APPLIED TO MY OWN WIDGET. The amber below was a single
       `#D97706` for both themes, and measured on this notice's own surfaces it
       read **2.8561 in light mode** -- under WCAG 1.4.11's 3:1 for an icon that
       conveys meaning, which this one does. Exactly the defect F277 records for
       the toast palette, shipped by me a few hours earlier in the same session.

       Fixed the same way and from the same source: the Store Syria design
       system's per-theme semantic foregrounds, `--ss-amber-900` on light and
       its dark-mode counterpart. Measured after: 8.6432 light, 8.3955 dark.

       The BORDER keeps the mid-tone `#D97706` deliberately -- a border is
       decorative here (the icon and the text carry the meaning), so 1.4.11 does
       not apply to it, and keeping it preserves the notice's amber identity. */
    final Color accent = isDark
        ? const Color(0xFFF0C674)
        : const Color(0xFF5D3F04);

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        // Directional, so the inset follows the reading direction in Arabic.
        margin: EdgeInsetsDirectional.only(start: 16.w, end: 16.w, top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B2E39) : const Color(0xFFFBF1E6),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFFD97706).withValues(alpha: isDark ? .45 : .30),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.history_rounded, size: 20.sp, color: accent),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'showing_older_data'.tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DarkThemeColor.cText : const Color(0xFF0F1A2E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 12.sp,
                      /* 12sp body text, so WCAG 1.4.3 asks 4.5:1. The previous
                         `#777777` measured **4.0146** against this notice's
                         amber panel — a second contrast defect of mine in the
                         same widget, found by the test below and not by
                         review. `--ss-grey-700` from the design system gives
                         7.8295. The dark side already measured 6.7332 and is
                         unchanged, so only the light shade moves. */
                      color: isDark
                          ? DarkThemeColor.cSecondaryText
                          : const Color(0xFF434D4C),
                    ),
                  ),
                ],
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(width: 8.w),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'retry'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
