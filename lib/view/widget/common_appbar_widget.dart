// ignore_for_file: prefer_const_constructors

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

import '../../utils/helper.dart';

simpleAppBar({bool isBack = true, required String title, String? date}) {
  final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
  final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;
  final textColor =  isDark ? AppColor.cWhite : AppColor.themeNavyBlueColor;

  return PreferredSize(
    preferredSize: Size(Get.width, 70),
    child: Padding(
      padding: EdgeInsets.only(top: Get.height * 0.07, left: 15, right: 15),
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
                        child: Align(
                          child: assetSvdImageWidget(
                              image: DefaultImages.backIcn,
                              width: 11,
                              height: 10,
                              color : isDark ? AppColor.cWhite : AppColor.themeNavyBlueColor
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              horizontalSpace(isBack == true ? 15 : 0),
              Text(
                title,
                style: pMedium18.copyWith(color: textColor),
              ),
            ],
          ),
          // Text(
          //   // date,
          //   dateFormatted(date: DateTime.now().toString(), formatType: mmmDdYyyy),
          //   style: pRegular14,
          // )
        ],
      ),
    ),
  );
  // return AppBar(
  //   elevation: 0,
  //   leading: isBack == true
  //       ? GestureDetector(
  //           onTap: () {
  //             Get.back();
  //           },
  //           child: Container(
  //               height: 35,
  //               width: 35,
  //               decoration: BoxDecoration(border: Border.all(color: AppColor.cBorder),borderRadius: BorderRadius.circular(15)),
  //               child: Align(child: assetSvdImageWidget(image: DefaultImages.backIcn, width: 11, height: 10))))
  //       : SizedBox(),
  //   backgroundColor: AppColor.cBackGround,
  //   title: Text(
  //     title,
  //     style: pRegular14,
  //   ),
  //   actions: [
  //     Padding(
  //       padding: const EdgeInsets.all(15),
  //       child: Text(
  //         date,
  //         style: pRegular14,
  //       ),
  //     )
  //   ],
  // );
}
