import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import '../../utils/colors.dart';
import 'order_status_badge.dart';

Widget topOrderCardWidget({
  required BuildContext context,
  required String orderId,
  required String date,
  required String maskedName,
  required String price,
  int? primaryBadgeLabel,
  String? secondaryBadgeLabel,
  VoidCallback? onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final subTextColor =
  isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 260.w,
      padding: EdgeInsets.symmetric(
        vertical: 18.h,
        horizontal: 15.w,
      ),
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: AppColor.themeNavyBlueColor.withOpacity(0.3),
        // ),
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= ORDER ID =================
          Text(
            "🔥 $orderId",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),

          SizedBox(height: 14.h),

          /// ================= CUSTOMER + PRICE =================
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16.sp,
                color: AppColor.themeGreenColor,
              ),

              SizedBox(width: 6.w),

              Expanded(
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

              SizedBox(width: 8.w),

              Text(
                price,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          /// ================= STATUS =================
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
            ],
          ),

          SizedBox(height: 14.h),

          /// ================= DATE =================

         Align(
              alignment: Alignment.centerLeft,
              child: Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
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

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        // border: Border.all(color: AppColor.themeNavyBlueColor.withOpacity(0.3)),
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
                    SvgPicture.asset(
                      DefaultImages.ordersIcn,
                      width: 20.h,
                      color: AppColor.cGreenFont,
                    ),

                    SizedBox(width: 6.w),

                    Flexible(
                      child: Text(
                        orderId,
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

              AppPopupMenu(
                viewFun: viewFun,
                changeFun: changeFun,
                changeFun2: changeFun2,
                deleteFun: deleteFun,
                changeText: changeText,
                changeText2: changeText2,
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