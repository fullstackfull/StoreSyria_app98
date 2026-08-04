// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/store_setting_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

class StoreSettingScreen extends StatelessWidget {
  StoreSettingScreen({super.key});

  StoreSettingController storeSettingController = Get.put(StoreSettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cBackGround,
      appBar: simpleAppBar(title: 'Store Setting'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delete Store",
                style: pRegular20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: horizontalDivider(),
              ),
              Text(
                "Deleting your store means permanently removing all data and content associated with your online business. ",
                style: pRegular10.copyWith(color: AppColor.cDarkGreyFont),
              ),
              verticalSpace(26),
              CommonIconButton(
                iconData: DefaultImages.whiteCloseIcn,
                title: 'Delete Store',
                onPressed: () {
                  if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                    commonToast(AppConstant.demoString);
                  } else {
                    storeSettingController.deleteStoreData();
                  }
                },
                btnColor: AppColor.cRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
