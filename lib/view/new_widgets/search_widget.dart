import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/widget/common_text_field.dart';
import '../../utils/colors.dart';

Widget SearchRowWidget({
  required BuildContext context,
  TextEditingController? controller,
  String? hint,
  Function(String)? onChanged,
  VoidCallback? onSortTap,
  VoidCallback? onFilterTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final hintColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;
  final accent = AppColor.themeNavyBlueColor;

  return Row(
    children: [
      Expanded(
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: CommonTextField(
            prefix: DefaultImages.searchIcn,
            hintText: hint,
            color: isDark ? Colors.grey : Colors.white,
            controller: controller,
            onChanged: onChanged,

          ),
        ),
      ),
      SizedBox(width: 10.w),
      GestureDetector(
        onTap: onSortTap,
        child: Container(
          width: 45.w,
          height: 45.h,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 22.sp),
        ),
      ),
      SizedBox(width: 10.w),
      GestureDetector(
        onTap: onFilterTap,
        child: Container(
          width: 52.w,
          height: 52.h,
          decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
          child: Icon(Icons.tune_rounded, color: textColor, size: 20.sp),
        ),
      ),
    ],
  );
}