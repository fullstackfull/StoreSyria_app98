// ignore_for_file: prefer_const_constructors

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

simpleAppBar({
  bool isBack = false,
  bool isBold = false,
  required String title,
  required String? label,
  required VoidCallback onNewLabelTap,
  }) {
  final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
  final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;
  final textColor =  isDark ? AppColor.cWhite : AppColor.themeNavyBlueColor;
  final accent = AppColor.themeNavyBlueColor;

  return PreferredSize(
    preferredSize: Size(Get.width, 70),
    child: Padding(
      padding: EdgeInsets.only(top: Get.height * 0.05, left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              isBack == true
                  ? GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 30.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(Icons.arrow_back,color: AppColor.themeNavyBlueColor),
                      ),
                  )
                  : SizedBox(),
              horizontalSpace(isBack == true ? 15 : 0),
              Text(
                title,
                style: isBold ? pBold18.copyWith(color: textColor,fontSize: 21.sp) : pMedium18.copyWith(color: textColor),
              ),
            ],
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
                    color: accent.withOpacity(0.4),
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
    ),
  );
}
