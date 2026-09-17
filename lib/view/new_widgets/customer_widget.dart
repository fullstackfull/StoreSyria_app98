import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';

Widget customerWidget({
  required BuildContext context,
  CustomerData? customer,
  VoidCallback? onTap,
  VoidCallback? viewFun,
  VoidCallback? changeFun,
  VoidCallback? deleteFun,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final cardColor =
  isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final subTextColor =
  isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  final name =
      customer?.customerInfo?.name?.replaceAll('"', '').trim() ?? '';
  final mobile =
      customer?.customerInfo?.mobile?.replaceAll('"', '').trim() ?? '';

  final orders = customer?.orders ?? 0;

  final lastActive =
      customer?.lastActive?.replaceAll('"', '').trim() ?? '';

  final bool isActive = customer?.status == 1;

  final statusLabel = customer?.statusText?.isNotEmpty == true
      ? customer!.statusText!
      : isActive
      ? 'active'.tr
      : 'inactive'.tr;

  final displayName =
  name.isNotEmpty ? name : 'no_customer_name'.tr;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 13.h,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.06)
              : Colors.grey.withOpacity(.10),
        ),
      ),
      child: Column(
        children: [
// Header
          Row(
            children: [
              _avatar(displayName),

              SizedBox(width: 11.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    if (mobile.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 12.sp,
                            color: subTextColor,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              mobile,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: subTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              _statusPill(
                label: statusLabel,
                isActive: isActive,
              ),

              SizedBox(width: 2.w),

              AppPopupMenu(
                viewFun: viewFun,
                changeFun: changeFun,
                deleteFun: deleteFun,
                viewText: 'view'.tr,
                changeText: 'change'.tr,
                deleteText: 'delete'.tr,
              ),
            ],
          ),

          SizedBox(height: 12.h),

// Bottom information
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(.035)
                  : Colors.grey.withOpacity(.045),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _smallInfo(
                    icon: Icons.shopping_bag_outlined,
                    label: 'orders'.tr,
                    value: orders.toString(),
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ),

                Container(
                  width: 1,
                  height: 28.h,
                  color: isDark
                      ? Colors.white.withOpacity(.08)
                      : Colors.grey.withOpacity(.15),
                ),

                if (lastActive.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: _smallInfo(
                        icon: Icons.schedule_outlined,
                        label: 'last_active'.tr,
                        value: lastActive,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _avatar(String name) {
  return Container(
    width: 44.w,
    height: 44.w,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: _avatarGradient(name),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(13.r),
    ),
    alignment: Alignment.center,
    child: Text(
      _getInitials(name),
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
  );
}

String _getInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  if (parts.isEmpty) return '?';

  if (parts.length == 1) {
    return parts[0].substring(0, 1).toUpperCase();
  }

  return (
      parts[0].substring(0, 1) +
          parts[1].substring(0, 1)
  ).toUpperCase();
}

List<Color> _avatarGradient(String seed) {
  const gradients = <List<Color>>[
    [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    [Color(0xFF00B894), Color(0xFF55EFC4)],
    [Color(0xFFFF9F43), Color(0xFFFFC069)],
    [Color(0xFF0984E3), Color(0xFF74B9FF)],
    [Color(0xFFE17055), Color(0xFFFAB1A0)],
  ];

  final index =
  seed.isEmpty ? 0 : seed.codeUnitAt(0) % gradients.length;

  return gradients[index];
}

Widget _smallInfo({
  required IconData icon,
  required String label,
  required String value,
  required Color textColor,
  required Color subTextColor,
}) {
  return Row(
    children: [
      Icon(
        icon,
        size: 14.sp,
        color: AppColor.themeNavyBlueColor,
      ),

      SizedBox(width: 6.w),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                color: subTextColor,
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _statusPill({
  required String label,
  required bool isActive,
}) {
  final color = isActive
      ? const Color(0xFF00B894)
      : const Color(0xFFFF5C5C);

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: 8.w,
      vertical: 5.h,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(.09),
      borderRadius: BorderRadius.circular(20.r),
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

        SizedBox(width: 4.w),

        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}
