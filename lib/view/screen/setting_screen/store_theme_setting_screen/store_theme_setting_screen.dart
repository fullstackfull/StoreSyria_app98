// ignore_for_file: must_be_immutable

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';

class StoreThemeSettingScreen extends StatelessWidget {
  StoreThemeSettingScreen({super.key});

  ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ThemeController(),
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColor.cBackGround,
          appBar: simpleAppBar(title: ''),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(
                () {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Store Theme Setting",
                        style: pRegular20,
                      ),
                      verticalSpace(20),
                      Row(
                        children: [
                          assetSvdImageWidget(
                            image: DefaultImages.brightnessIcn,
                            width: 24.w,
                            height: 24.h,
                            colorFilter: ColorFilter.mode(
                              AppColor.cLabel,
                              BlendMode.srcIn,
                            ),
                          ),
                          horizontalSpace(10),
                          Text(
                            "Layout Settings",
                            style: pMedium14,
                          ),
                        ],
                      ),
                      verticalSpace(10),
                      horizontalDivider(),
                      verticalSpace(10),
                      Row(
                        children: [
                          CupertinoSwitch(
                            value: themeController.isDark.value,
                            onChanged: (value) {
                              themeController.isDark.value = value;
                            },
                            activeColor: AppColor.themeGreenColor,
                          ),
                          horizontalSpace(10),
                          Text(
                            "Dark Layout",
                            style: pMedium14,
                          ),
                        ],
                      ),
                      verticalSpace(20),
                      CommonButton(
                        title: "Save",
                        onPressed: () {
                          themeController
                              .changeTheme(themeController.isDark.value);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
