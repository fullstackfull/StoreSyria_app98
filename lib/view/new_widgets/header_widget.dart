import 'package:get/get.dart';
import 'package:store_go_app/utils/text_style.dart';
import '../../utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/images.dart';
import '../widget/icon_and_image.dart';

Widget HeaderWidget({
  required BuildContext context,
  required String title,
  required String? label,
  required VoidCallback onNewLabelTap,

  bool showBackButton = false,
  VoidCallback? onBackTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final titleColor =
  isDark ? Colors.white : AppColor.themeNavyBlueColor;

  final accent = AppColor.themeNavyBlueColor;

  return Padding(
    padding: EdgeInsets.only(top: 12.w),
    child: Row(
      children: [
        if (showBackButton)
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: GestureDetector(
              onTap: onBackTap ?? () => Get.back(),
              child: Container(
                height: 30.h,
                width: 40.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? DarkThemeColor.cBorder
                        : AppColor.cBorder,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Align(
                  child: assetSvdImageWidget(
                    image: DefaultImages.backIcn,
                    width: 11.w,
                    height: 10.h,
                    color: isDark
                        ? AppColor.cWhite
                        : AppColor.themeNavyBlueColor,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: Text(
            title,
            style: pBold24.copyWith(
              color: titleColor,
            ),
          ),
        ),

        if (label != null)
          GestureDetector(
            onTap: onNewLabelTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 7.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: accent,
                  width: 1.3,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 18.sp,
                    color: accent,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}