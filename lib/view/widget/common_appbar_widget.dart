import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

simpleAppBar({
  bool isBack = false,
  bool isBold = false,
  required String title,
  required String? label,
  required VoidCallback onNewLabelTap,
}) {

  return PreferredSize(
    // Scaffold CAPS this slot rather than taking it as a hint: it wraps the
    // appBar in ConstrainedBox(maxHeight: preferredSize.height + topPadding)
    // (material/scaffold.dart). A declared 70 with `top: Get.height * 0.05`
    // spending 40 of it leaves the back control 30dp and clamps its 48dp
    // minimum DOWN -- silently, with no overflow error. So this is derived from
    // the SAME expression as the padding below: a literal 88 would be correct
    // at exactly one device height.
    preferredSize: Size.fromHeight(Get.height * 0.05 + kMinInteractiveDimension),
    /* P2.5 -- THE THEME IS READ FROM THIS WIDGET'S OWN CONTEXT, NOT FROM `Get.context`.
       =============================================================================================

       It used to open with

           final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

       at the top of the FUNCTION, and both halves of that were wrong.

       `Get.context` is the root navigator's context, not this app bar's. Reading an
       InheritedWidget through a foreign context registers NO DEPENDENCY, so when the theme
       changes nothing marks this subtree dirty -- and when it is rebuilt for some other reason it
       reads a Theme resolved somewhere else in the tree, which during a rebuild pass can still be
       the OLD one. `simpleAppBar` is also a plain function rather than a widget, so its body runs
       while its caller builds and there is no element of its own to depend on anything.

       MEASURED, after driving the real toggle through `ThemeController.changeTheme`: switching
       dark -> light left the title at `AppColor.cWhite` ON A WHITE BAR. The back control beside
       it rendered normally, because its colour is not conditioned on `isDark` at all -- so the
       screen looked fine and the title was simply gone. Found in a capture of the theme-switch
       reveal: 7,770 pixels of pure #FFFFFF where the title should be, in both light-destination
       combinations. 28 screens use this app bar.

       A `Builder` gives the subtree an element of its own, so `Theme.of(context)` here both reads
       the right value and subscribes: a theme change now rebuilds the app bar by itself.

       Guarded by `test/a11y/appbar_title_follows_theme_test.dart`, which drives the real toggle
       in both directions and measures the title's CONTRAST against the bar rather than merely
       asserting the colour changed. */
    child: Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

      final textColor = isDark ? AppColor.cWhite : AppColor.themeNavyBlueColor;

      final accent = AppColor.themeNavyBlueColor;

      return Padding(
      padding: EdgeInsets.only(
        top: Get.height * 0.05,
        left: 15.w,
        right: 15.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title section
          Expanded(
            child: Row(
              children: [
                if (isBack)
                  // The painted box stays 30x40; the HIT AREA grows to 48.
                  // Enlarging what a merchant sees would overturn a visual
                  // decision on 23 screens; enlarging the target fixes the
                  // accessibility defect and changes nothing but the press
                  // ripple. `tooltip:` is the sighted hint and what iOS folds
                  // into accessibilityLabel; `semanticLabel:` on the Icon is
                  // what gives ANDROID a name at all, because the engine's
                  // AccessibilityBridge composes its content description from
                  // value+label+hint and never reads a tooltip. Both, or
                  // TalkBack says "button" and nothing else.
                  IconButton(
                    tooltip: 'back'.tr,
                    onPressed: () {
                      Get.back();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: kMinInteractiveDimension,
                      minHeight: kMinInteractiveDimension,
                    ),
                    icon: Container(
                      height: 30.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderColor,
                        ),
                        borderRadius:
                        BorderRadius.circular(15.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        semanticLabel: 'back'.tr,
                        color: AppColor.themeNavyBlueColor,
                      ),
                    ),
                  ),

                if (isBack)
                  horizontalSpace(10),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isBold
                        ? pBold18.copyWith(
                      color: textColor,
                      fontSize: 20.sp,
                    )
                        : pMedium18.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // New label button
          if (label != null) ...[
            SizedBox(width: 8.w),

            GestureDetector(
              onTap: onNewLabelTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(30.r),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
                    width: 1.3,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18.sp,
                      color: accent,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
    }),
  );
}
