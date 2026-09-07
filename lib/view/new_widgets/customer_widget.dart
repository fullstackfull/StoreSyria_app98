// ignore_for_file: prefer_const_constructors

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

  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  final name = customer?.customerInfo?.name?.replaceAll('"', '').trim() ?? '';
  final mobile =
      customer?.customerInfo?.mobile?.replaceAll('"', '').trim() ?? '';
  final email = customer?.email?.replaceAll('"', '').trim() ?? '';
  final lastActive = customer?.lastActive?.replaceAll('"', '').trim() ?? '';
  final totalSpend =
      customer?.totalSpend?.replaceAll('"', '').trim() ?? '0.00';
  final aov = customer?.aov?.replaceAll('"', '').trim() ?? '0.00';
  final orders = customer?.orders ?? 0;

  final bool isActive = customer?.status == 1;

  final statusLabel = customer?.statusText?.isNotEmpty == true
      ? customer!.statusText!
      : isActive
      ? 'active'.tr
      : 'inactive'.tr;

  final displayName = name.isNotEmpty ? name : 'no_customer_name'.tr;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(.25)
                : Colors.black.withOpacity(.06),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _avatar(displayName),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    if (mobile.isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.call_rounded,
                              size: 13.sp, color: subTextColor),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              mobile,
                              overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // ==================================================
              // STATUS PILL
              // ==================================================
              _statusPill(label: statusLabel, isActive: isActive),

              SizedBox(width: 8.w),

              // ==================================================
              // MENU (Using AppPopupMenu)
              // ==================================================
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

          SizedBox(height: 16.h),

          // ==================================================
          // EMAIL
          // ==================================================

          if (email.isNotEmpty) ...[
            _iconTextRow(
              icon: Icons.mail_outline_rounded,
              text: email,
              textColor: subTextColor,
              iconColor: AppColor.themeNavyBlueColor,
            ),
            SizedBox(height: 12.h),
          ],

          // ==================================================
          // STATS BLOCK: ORDERS / SPEND / AOV
          // ==================================================

          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(.04)
                  : const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _statItem(
                    icon: Icons.shopping_bag_rounded,
                    label: 'orders'.tr,
                    value: orders.toString(),
                    color: AppColor.themeGreenColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ),
                _verticalDivider(isDark),
                Expanded(
                  child: _statItem(
                    icon: Icons.payments_rounded,
                    label: 'total_spend'.tr,
                    value: '\$$totalSpend',
                    color: const Color(0xFF00B894),
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ),
                _verticalDivider(isDark),
                Expanded(
                  child: _statItem(
                    icon: Icons.trending_up_rounded,
                    label: 'aov'.tr,
                    value: '\$$aov',
                    color: const Color(0xFFFF9F43),
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // LAST ACTIVE
          // ==================================================

          if (lastActive.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _iconTextRow(
              icon: Icons.schedule_rounded,
              text: '${'last_active'.tr}: $lastActive',
              textColor: subTextColor,
              iconColor: subTextColor,
              small: true,
            ),
          ],
        ],
      ),
    ),
  );
}

// ==================================================
// AVATAR (INITIALS + GRADIENT)
// ==================================================

Widget _avatar(String name) {
  return Container(
    width: 54.w,
    height: 54.w,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: _avatarGradient(name),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18.r),
    ),
    alignment: Alignment.center,
    child: Text(
      _getInitials(name),
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
  );
}

String _getInitials(String name) {
  final parts =
  name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts[0].substring(0, 1).toUpperCase();
  }
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

List<Color> _avatarGradient(String seed) {
  const gradients = <List<Color>>[
    [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    [Color(0xFF00B894), Color(0xFF55EFC4)],
    [Color(0xFFFF9F43), Color(0xFFFFC069)],
    [Color(0xFF0984E3), Color(0xFF74B9FF)],
    [Color(0xFFE17055), Color(0xFFFAB1A0)],
  ];
  final index = seed.isEmpty ? 0 : seed.codeUnitAt(0) % gradients.length;
  return gradients[index];
}

// ==================================================
// STAT ITEM
// ==================================================

Widget _statItem({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
  required Color textColor,
  required Color subTextColor,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, size: 16.sp, color: color),
      SizedBox(height: 6.h),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
      SizedBox(height: 2.h),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w600,
          color: subTextColor,
        ),
      ),
    ],
  );
}

Widget _verticalDivider(bool isDark) => Container(
  width: 1,
  height: 34.h,
  color: isDark
      ? Colors.white.withOpacity(.08)
      : Colors.black.withOpacity(.06),
);

// ==================================================
// ICON + TEXT ROW (email / last active)
// ==================================================

Widget _iconTextRow({
  required IconData icon,
  required String text,
  required Color textColor,
  required Color iconColor,
  bool small = false,
}) {
  return Row(
    children: [
      Icon(icon, size: small ? 13.sp : 15.sp, color: iconColor),
      SizedBox(width: 6.w),
      Expanded(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: small ? 11.sp : 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    ],
  );
}

// ==================================================
// STATUS PILL
// ==================================================

Widget _statusPill({required String label, required bool isActive}) {
  final Color color =
  isActive ? const Color(0xFF00B894) : const Color(0xFFFF5C5C);

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: color.withOpacity(.1),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}