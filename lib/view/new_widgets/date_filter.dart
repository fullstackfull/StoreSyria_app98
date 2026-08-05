import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

Widget sectionHeaderWithFilterWidget({
  required BuildContext context,
  required String title,
  required String filterLabel,
  VoidCallback? onFilterTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final titleColor = isDark ? Colors.white : Colors.black;
  final accent = AppColor.themeNavyBlueColor;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: titleColor),
        ),
      ),
      SizedBox(width: 8.w),
      GestureDetector(
        onTap: onFilterTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 14.sp, color: accent),
              SizedBox(width: 6.w),
              Text(
                filterLabel,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: accent),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
