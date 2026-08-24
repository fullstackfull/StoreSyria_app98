import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
  final isDark =
      Theme.of(context).brightness == Brightness.dark;

  final cardColor =
  isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;

  final textColor =
  isDark ? DarkThemeColor.cText : AppColor.cText;

  final subTextColor =
  isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  final bool canView = viewFun != null;
  final bool canChange =
      showChangeAction && changeFun != null;
  final bool canDelete = deleteFun != null;

  final bool isActive = status == 1;

  final String cleanType =
      couponType?.replaceAll('"', '').trim().toLowerCase() ?? '';

  final String cleanName =
      name?.replaceAll('"', '').trim() ?? '';

  final String cleanCode =
      code?.replaceAll('"', '').trim() ?? '';

  final String cleanDate =
      date?.replaceAll('"', '').trim() ?? '';

  String discountText() {
    final value = discount?.replaceAll('"', '').trim() ?? '';

    if (value.isEmpty) {
      return '-';
    }

    if (cleanType == 'percentage') {
      return '$value%';
    }

    if (cleanType == 'flat') {
      return '$value\$';
    }

    return value;
  }

  PopupMenuEntry<String> divider() =>
      PopupMenuItem<String>(
        enabled: false,
        height: 1.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Divider(
          height: 1.h,
          thickness: 1,
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.08),
        ),
      );

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: AppColor.themeNavyBlueColor.withOpacity(0.3)),
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      cleanName.isNotEmpty
                          ? cleanName
                          : 'no_coupon_name'.tr,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
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
                              borderRadius:
                              BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.tag_outlined,
                              size: 13.sp,
                              color:
                              AppColor.themeGreenColor,
                            ),
                          ),

                          SizedBox(width: 4.w),

                          Expanded(
                            child: Text(
                              cleanCode,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight:
                                FontWeight.w600,
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
              // MENU
              // ==================================================

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                splashRadius: 22.r,
                offset: Offset(0, 35.h),
                tooltip: 'more'.tr,

                icon: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(.08)
                        : Colors.black.withOpacity(.04),
                    borderRadius:
                    BorderRadius.circular(11.r),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20.sp,
                    color: subTextColor,
                  ),
                ),

                elevation: 8,

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(.12)
                        : Colors.black.withOpacity(.08),
                  ),
                ),

                color: cardColor,

                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      viewFun?.call();
                      break;

                    case 'change':
                      changeFun?.call();
                      break;

                    case 'delete':
                      deleteFun?.call();
                      break;
                  }
                },

                itemBuilder: (context) {
                  final items =
                  <PopupMenuEntry<String>>[];

                  // VIEW
                  if (canView) {
                    items.add(
                      PopupMenuItem(
                        value: 'view',
                        height: 42.h,
                        child: Row(
                          children: [

                            Icon(
                              Icons.visibility_outlined,
                              size: 18.sp,
                              color: subTextColor,
                            ),

                            SizedBox(width: 10.w),

                            Text(
                              'view'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: textColor,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // CHANGE
                  if (canChange) {
                    if (items.isNotEmpty) {
                      items.add(divider());
                    }

                    items.add(
                      PopupMenuItem(
                        value: 'change',
                        height: 42.h,
                        child: Row(
                          children: [

                            Icon(
                              Icons.edit_outlined,
                              size: 18.sp,
                              color:
                              AppColor.themeGreenColor,
                            ),

                            SizedBox(width: 10.w),

                            Text(
                              'change'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color:
                                AppColor.themeGreenColor,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // DELETE
                  if (canDelete) {
                    if (items.isNotEmpty) {
                      items.add(divider());
                    }

                    items.add(
                      PopupMenuItem(
                        value: 'delete',
                        height: 42.h,
                        child: Row(
                          children: [

                            Icon(
                              Icons
                                  .delete_outline_rounded,
                              size: 18.sp,
                              color: Colors.redAccent,
                            ),

                            SizedBox(width: 10.w),

                            Text(
                              'delete'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.redAccent,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return items;
                },
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
                      color: AppColor.themeGreenColor
                          .withOpacity(.06),
                      borderRadius:
                      BorderRadius.circular(12.r),
                    ),                child: Icon(
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
                    borderRadius:
                    BorderRadius.circular(5.r),
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
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [

              // STATUS
              couponStatusBadgeWidget(
                label: isActive
                    ? 'active'.tr
                    : 'inactive'.tr,
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
                      overflow:
                      TextOverflow.ellipsis,
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
 // primary,
  success,
 // warning,
  danger,
}

Widget couponStatusBadgeWidget({
  required String label,
  required CouponBadgeType type,
}) {
  final Color color;

  switch (type) {
    // case CouponBadgeType.primary:
    //   color = AppColor.themeNavyBlueColor;
    //   break;

    case CouponBadgeType.success:
      color = Colors.green;
      break;

    // case CouponBadgeType.warning:
    //   color = Colors.orange;
    //   break;

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