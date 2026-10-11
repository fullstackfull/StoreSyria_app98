import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget statusPill({
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