import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

simpleAppBar({
  bool isBack = false,
  bool isBold = false,
  required String title,
  required String? label,
  required VoidCallback onNewLabelTap,
}) {
  final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

  final borderColor =
  isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

  final textColor =
  isDark ? AppColor.cWhite : AppColor.themeNavyBlueColor;

  final accent = AppColor.themeNavyBlueColor;

  return PreferredSize(
    preferredSize: const Size.fromHeight(70),
    child: Padding(
      padding: EdgeInsets.only(
        top: Get.height * 0.05,
        left: 15.w,
        right: 15.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title section
          Expanded(
            child: Row(
              children: [
                if (isBack)
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 30.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderColor,
                        ),
                        borderRadius:
                        BorderRadius.circular(15.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColor.themeNavyBlueColor,
                      ),
                    ),
                  ),

                if (isBack)
                  horizontalSpace(10),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isBold
                        ? pBold18.copyWith(
                      color: textColor,
                      fontSize: 20.sp,
                    )
                        : pMedium18.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // New label button
          if (label != null) ...[
            SizedBox(width: 8.w),

            GestureDetector(
              onTap: onNewLabelTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(30.r),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}