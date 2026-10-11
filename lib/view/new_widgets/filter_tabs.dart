import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';

Widget orderStatusTabsWidget({
  required BuildContext context,
  required int selectedIndex,
  required ValueChanged<int> onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = AppColor.themeNavyBlueColor;
  final normalTextColor = isDark ? DarkThemeColor.cText : AppColor.cText;

  Widget tab({
    required int index,
    required String label,
  }) {
    final active = selectedIndex == index;

    return GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : normalTextColor,
          ),
        ),
      ),
    );
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        tab(
          index: 0,
          label: "all_orders".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 1,
          label: "pending".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 2,
          label: "delivered".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 3,
          label: "cancelled".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 4,
          label: "return".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 5,
          label: "confirmed".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 6,
          label: "picked_up".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 7,
          label: "shipped".tr,
        ),
      ],
    ),
  );
}