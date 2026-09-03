import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/images.dart';
import '../../utils/colors.dart';
import 'order_status_badge.dart';

Widget topOrderCardWidget({
  required BuildContext context,
  required String orderId,
  required String date,
  required String maskedName,
  required String price,
  String? primaryBadgeLabel,
  String? secondaryBadgeLabel,
  VoidCallback? onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 260.w,
      padding: EdgeInsets.symmetric(vertical: 22.w,horizontal: 15.w),
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              "$orderId  🔥",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: textColor),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16.sp, color: AppColor.themeGreenColor),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        maskedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: subTextColor),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                price,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: textColor),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (secondaryBadgeLabel != null)
                orderStatusBadgeWidget(
                  label: secondaryBadgeLabel,
                  type: OrderBadgeType.success,
                  icon: Icons.verified_outlined,
                ),
              Text(
                date,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: subTextColor),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
enum OrderBadgeType { primary, success, danger }

Widget orderStatusBadgeWidget({
  required String label,
  OrderBadgeType type = OrderBadgeType.primary,
  IconData? icon,
}) {
  Color color;
  switch (type) {
    case OrderBadgeType.success:
      color = AppColor.themeGreenColor;
      break;
    case OrderBadgeType.danger:
      color = AppColor.cRedText;
      break;
    case OrderBadgeType.primary:
      color = AppColor.themeNavyBlueColor;
      break;
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
        ],
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    ),
  );
}


Widget allOrdersListItemWidget({
  required BuildContext context,
  required String orderId,
  required String date,
  required String maskedName,
  required String price,
  int? primaryBadgeLabel,
  String? secondaryBadgeLabel,
  String? changeText,
  String? changeText2,
  VoidCallback? onTap,
  VoidCallback? viewFun,
  VoidCallback? deleteFun,
  VoidCallback? changeFun,
  VoidCallback? changeFun2,
  bool showChangeAction = false,
  bool showChangeAction2 = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  final bool canView = viewFun != null;
  final bool canChange = showChangeAction && changeFun != null;
  final bool canChange2 = showChangeAction2 && changeFun2 != null;
  final bool canDelete = deleteFun != null;

  PopupMenuEntry<String> divider() => PopupMenuItem<String>(
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.themeNavyBlueColor.withOpacity(0.3)),
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SvgPicture.asset(DefaultImages.ordersIcn,
                        width: 20.h, color: AppColor.cGreenFont),
                    Flexible(
                      child: Text(
                        " $orderId",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                splashRadius: 22.r,
                offset: Offset(0, 35.h),
                tooltip: 'more'.tr,
                icon: Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20.sp,
                    color: subTextColor,
                  ),
                ),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                shadowColor: Colors.black.withOpacity(0.4),
                color: cardColor,
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      viewFun?.call();
                      break;
                    case 'change':
                      changeFun?.call();
                      break;
                    case 'change2':
                      changeFun2?.call();
                      break;
                    case 'delete':
                      deleteFun?.call();
                      break;
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[];

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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (canChange) {
                    if (items.isNotEmpty) items.add(divider());
                    items.add(
                      PopupMenuItem(
                        value: 'change',
                        height: 42.h,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18.sp,
                              color: AppColor.themeGreenColor,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              changeText ?? 'change'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColor.themeGreenColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (canChange2) {
                    if (items.isNotEmpty) items.add(divider());
                    items.add(
                      PopupMenuItem(
                        value: 'change2',
                        height: 42.h,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18.sp,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              changeText2 ??'change2',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (canDelete) {
                    if (items.isNotEmpty) items.add(divider());
                    items.add(
                      PopupMenuItem(
                        value: 'delete',
                        height: 42.h,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 18.sp,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'delete'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
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

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16.sp,
                      color: AppColor.themeGreenColor,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        maskedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (secondaryBadgeLabel != null)
                CommonStatusBadge(
                  isCard: true,
                  type: StatusBadgeType.payment,
                  paymentStatus: secondaryBadgeLabel,
                ),
              if (primaryBadgeLabel != null)
                CommonStatusBadge(
                  isCard: true,
                  type: StatusBadgeType.order,
                  orderStatus: primaryBadgeLabel,
                ),
              Flexible(
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}