import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';
import '../../utils/colors.dart';

Widget productCouponWidget({
  required BuildContext context,
  int? index,
  int status = 0,
  VoidCallback? onTap,
  VoidCallback? deleteFun,
  VoidCallback? viewFun,
  VoidCallback? changeFun,
  String? code,
  String? name,
  String? discount,
  String? date,
  String? couponType,
  bool showChangeAction = true,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final cardColor =
  isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;

  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;

  final subTextColor =
  isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  final bool isActive = status == 1;

  final String cleanType =
      couponType?.replaceAll('"', '').trim().toLowerCase() ?? '';
  final String cleanName = name?.replaceAll('"', '').trim() ?? '';
  final String cleanCode = code?.replaceAll('"', '').trim() ?? '';
  final String cleanDate = date?.replaceAll('"', '').trim() ?? '';

  // دالة مساعدة لتنسيق نص الخصم
  String discountText() {
    final value = discount?.replaceAll('"', '').trim() ?? '';
    if (value.isEmpty) return '-';

    if (cleanType == 'percentage') return '$value%';
    if (cleanType == 'flat') return '$value';

    return value;
  }

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
        // P06-WS8. THE LIGHT CARD HAD NO BOUNDARY OF ANY KIND, and the two lines that would have
        // given it one were commented out. `LightThemeColor.cBackGround` is 0xffFFFFFF
        // (colors.dart:72) and `cardColor` is `AppColor.cWhite` -- the SAME white -- and this
        // decoration declares no shadow either. Measured off `coupon-card-column.light-ltr.png`:
        // 96.52% of the image is #FFFFFF and a row scan across the card's left edge finds no edge
        // pixel at all. **1.00:1.** The card was invisible as an object; only its contents showed.
        //
        // CORRECTION TO THE COMMIT THAT ADDED THIS COMMENT (01a9a09). The 1.00:1 above is the
        // figure on a WHITE host, which is what `coupon-card-column.light-ltr.png` photographs
        // because the golden harness paints `LightThemeColor.cBackGround` (0xffFFFFFF). THE
        // COUPON *SCREEN* DOES NOT: `coupon_screen.dart:189` hard-codes `Color(0xFFF5F6F8)`, so
        // in the shipped list the white card sat at **1.08:1**, not 1.00:1 -- very faint, and not
        // literally invisible. Both figures are real and they belong to different surfaces; the
        // earlier wording implied the screen had the worse one. Measured off
        // `coupons-screen.light-ltr.png`, whose page reads #F5F6F8 across 66% of the image.
        //
        // The repair holds either way and the white host is NOT hypothetical: two other Scaffolds
        // in that same file (`coupon_screen.dart:80`, `:104`) use `AppColor.cBackGround`, which
        // light mode sets to pure white.
        //
        //     host       card fill   before    with the edge
        //     #FFFFFF    #FFFFFF     1.00:1    1.43:1
        //     #F5F6F8    #FFFFFF     1.08:1    1.32:1
        //
        // This is the repair 3727efc already chose for the customer and delivery-man cards, and
        // the transaction card carries the same hairline: one card family, one edge. It is NOT
        // the commented-out line, which was `themeNavyBlueColor.withValues(alpha: 0.3)` -- a
        // value nobody measured. `LightThemeColor.cBorder` is the app's own token.
        //
        // DARK GETS NO OUTLINE, deliberately: there `cCardBackground` #18263F already differs
        // from `cBackGround` #0F1A2E (1.15:1), and an outline would fight a surface that is
        // already reading. Both halves are pinned by test/ui/card_intrinsic_height_test.dart.
        border: isDark ? null : Border.all(color: LightThemeColor.cBorder),
        borderRadius: BorderRadius.circular(18.r),
      ),
        // P2.5-FLUTTER-FRAMING. `MainAxisSize.min`: a `Column` defaults to `MainAxisSize.max`,
        // so this card filled any BOUNDED height it was given. MEASURED 800.0px in an 800px box
        // against 140.0px in a scrolling list, which is the context the app really renders it in.
        // The card was content-height only by accident of its surroundings.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cleanName.isNotEmpty
                          ? cleanName
                          : 'no_coupon_name'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.1,
                      ),
                    ),
                    if (cleanCode.isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Container(
                            width: 18.w,
                            height: 18.w,
                            decoration: BoxDecoration(
                              color: AppColor.themeGreenColor
                                  .withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.tag_outlined,
                              size: 13.sp,
                              color: AppColor.themeGreenColor,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              cleanCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: subTextColor,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // ==================================================
              // MENU (Using AppPopupMenu)
              // ==================================================
              AppPopupMenu(
                viewFun: viewFun,
                changeFun: showChangeAction ? changeFun : null,
                deleteFun: deleteFun,
                viewText: 'view'.tr,
                changeText: 'change'.tr,
                deleteText: 'delete'.tr,
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ==================================================
          // DISCOUNT
          // ==================================================
          Row(
            children: [
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: AppColor.themeGreenColor.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.confirmation_num_outlined,
                  size: 17.sp,
                  color: AppColor.themeGreenColor,
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                discountText(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1,
                ),
              ),
              if (cleanType.isNotEmpty) ...[
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: subTextColor.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    cleanType == 'percentage'
                        ? 'percentage'.tr
                        : 'flat'.tr,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 13.h),

          // ==================================================
          // STATUS + EXPIRY
          // ==================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // STATUS
              statusPill(
                  label: isActive ? "active".tr : "inactive".tr,
                  isActive: isActive
              ),
              const Spacer(),
              // EXPIRY DATE
              if (cleanDate.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13.sp,
                      color: subTextColor,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      cleanDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ==================================================
// BADGE
// ==================================================

enum CouponBadgeType {
  success,
  danger,
}

Widget couponStatusBadgeWidget({
  required String label,
  required CouponBadgeType type,
}) {
  final Color color;

  switch (type) {
    case CouponBadgeType.success:
      color = Colors.green;
      break;
    case CouponBadgeType.danger:
      color = Colors.redAccent;
      break;
  }

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: 9.w,
      vertical: 5.h,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(7.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}