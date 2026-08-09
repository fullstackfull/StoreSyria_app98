import '../../utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget HeaderWidget({
  required BuildContext context,
  required String title,
  required String? label,
  required VoidCallback onNewLabelTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final titleColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;
  final accent = AppColor.themeNavyBlueColor;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 26.sp,
          fontWeight: FontWeight.w800,
          color: titleColor,
        ),
      ),
      // GestureDetector(
      //   onTap: onNewLabelTap,
      //   child: Container(
      //     padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(30.r),
      //       border: Border.all(color: accent, width: 1.3),
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Icon(Icons.add, size: 18.sp, color: accent),
      //         SizedBox(width: 4.w),
      //         Text(
      //           label,
      //           style: TextStyle(
      //             fontSize: 14.sp,
      //             fontWeight: FontWeight.w600,
      //             color: accent,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    ],
  );
}