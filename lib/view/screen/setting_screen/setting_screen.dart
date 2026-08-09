// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/auth/login_widget.dart';
import 'package:store_go_app/view/screen/setting_screen/payment_setting_screen/payment_setting_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/store_setting_screen.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/services/fcm_token_service.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';

import 'email_setting_screen.dart';
import 'loyality_setting_screen.dart';
import 'store_theme_setting_screen/store_theme_setting_screen.dart';

class SettingScreen extends StatelessWidget {
  final bool isBack;
  const SettingScreen({Key? key, required this.isBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ThemeController(),
        builder: (_) {
        return Scaffold(
          backgroundColor: AppColor.cBackGround,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Store Settings",
                    style: pRegular20,
                  ),
                  verticalSpace(5),
                  Text(
                    "Welcome to the Store Settings!",
                    style: pRegular12.copyWith(color: AppColor.cDarkGreyFont),
                  ),
                  verticalSpace(20),
                  settingWidget(icon: DefaultImages.storeIcn, title: "Store Settings", function: () {Get.to(()=>StoreSettingScreen());},), horizontalDivider(),
                  settingWidget(icon: DefaultImages.themeIcn, title: "Store Theme Settings", function: () {Get.to(() => StoreThemeSettingScreen());},), horizontalDivider(),
                  // settingWidget(icon: DefaultImages.siteIcn, title: "Site Settings", function: () {},), horizontalDivider(),
                  settingWidget(icon: DefaultImages.categoriesIcn, title: "Store Payment", function: () {Get.to(() => PaymentSettingScreen());},), horizontalDivider(),
                  settingWidget(icon: DefaultImages.envelopeIcn, title: "Store Email Setting", function: () {Get.to(() => EmailSettingScreen());},), horizontalDivider(),
                  settingWidget(icon: DefaultImages.loyaltyIcn, title: "Store Loyalty Program", function: () {Get.to(() => LoyaltyProgramScreen());},), horizontalDivider(),
                  // settingWidget(icon: DefaultImages.callIcn, title: "Whatsapp Message Setting", function: () {},), horizontalDivider(),
                  settingWidget(icon: DefaultImages.logoutIcn, title: "LogOut", function: () async {
                    // مسح وتدمير FCM Token عند تسجيل الخروج
                    await FcmTokenService().clearFcmToken();
                    // مسح بيانات الإشعارات
                    if (Get.isRegistered<NotificationController>()) {
                      Get.find<NotificationController>().clearNotificationData();
                    }
                    Prefs.clear();
                    Get.offAll(()=>NormalLoginWidget());
                  },), horizontalDivider(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget settingWidget(
      {required String icon,
      required String title,
      required Function() function}) {
    return GestureDetector(
      onTap: function,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          width: Get.width,
          height: 40,
          decoration: BoxDecoration(
              color: AppColor.cBackGround,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
            BoxShadow(color: AppColor.cShadow, offset: Offset(0, 8),blurRadius: 15,spreadRadius: 0.5)
          ]),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    assetSvdImageWidget(image: icon, width: 12, height: 12,    colorFilter: ColorFilter.mode(
                        AppColor.cLabel, BlendMode.srcIn)),
                    horizontalSpace(15),
                    Text(
                      title,
                      style: pRegular14,
                    )
                  ],
                ),
                Icon(
                  Icons.arrow_right_alt,
                  color: AppColor.cFont,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
