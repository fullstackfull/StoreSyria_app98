import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
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

  // تنظيف البيانات من علامات التنصيص الزائدة إن وجدت
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
    if (cleanType == 'flat') return '$value\$';

    return value;
  }

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(
            color: AppColor.themeNavyBlueColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
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
                                  .withOpacity(.06),
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
                  color: AppColor.themeGreenColor.withOpacity(.06),
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
                    color: subTextColor.withOpacity(.08),
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
              couponStatusBadgeWidget(
                label: isActive ? 'active'.tr : 'inactive'.tr,
                type: isActive
                    ? CouponBadgeType.success
                    : CouponBadgeType.danger,
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
      color: color.withOpacity(.06),
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