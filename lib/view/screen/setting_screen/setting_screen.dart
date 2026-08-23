// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/routes/routes.dart';
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
  const SettingScreen({super.key, required this.isBack});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ThemeController(),
        builder: (_) {
        return Scaffold(
          backgroundColor: AppColor.cBackGround,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Store Settings",
                    style: pRegular20,
                  ),

                  verticalSpace(20),

                  /// Main Settings
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.35,
                    children: [
                      settingCard(
                        icon: DefaultImages.statisticIcn,
                        title: "Statistics",
                        function: () {
                          Get.toNamed(AppRoutes.statistics);
                        },
                      ),

                      settingCard(
                        icon: DefaultImages.shippingIcn,
                        title: "Shipping",
                        function: () {
                          Get.toNamed(AppRoutes.shipping);
                        },
                      ),

                      settingCard(
                        icon: DefaultImages.taxIcn,
                        title: "Tax",
                        function: () {
                          Get.toNamed(AppRoutes.tax);
                        },
                      ),

                      settingCard(
                        icon: DefaultImages.couponIcn,
                        title: "Coupon",
                        function: () {
                          Get.toNamed(AppRoutes.coupon);
                        },
                      ),
                    ],
                  ),

                  verticalSpace(28),

                  Text(
                    "General Settings",
                    style: pRegular16,
                  ),

                  verticalSpace(12),

                  settingWidget(
                    icon: DefaultImages.storeIcn,
                    title: "Store Settings",
                    function: () {
                      Get.to(() => StoreSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.themeIcn,
                    title: "Store Theme Settings",
                    function: () {
                      Get.to(() => StoreThemeSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.categoriesIcn,
                    title: "Store Payment",
                    function: () {
                      Get.to(() => PaymentSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.envelopeIcn,
                    title: "Store Email Setting",
                    function: () {
                      Get.to(() => EmailSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.loyaltyIcn,
                    title: "Store Loyalty Program",
                    function: () {
                      Get.to(() => LoyaltyProgramScreen());
                    },
                  ),

                  verticalSpace(8),

                  settingWidget(
                    icon: DefaultImages.logoutIcn,
                    title: "Log Out",
                    function: () async {
                      await FcmTokenService().clearFcmToken();

                      if (Get.isRegistered<NotificationController>()) {
                        Get.find<NotificationController>()
                            .clearNotificationData();
                      }

                      Prefs.clear();

                      Get.offAll(() => NormalLoginWidget());
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget settingWidget({
    required String icon,
    required String title,
    required Function() function,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: function,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColor.cBackGround,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColor.cShadow.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColor.cLabel.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: assetSvdImageWidget(
                      image: icon,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        AppColor.cLabel,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                horizontalSpace(14),

                Expanded(
                  child: Text(
                    title,
                    style: pRegular14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColor.cFont.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget settingCard({
  required String icon,
  required String title,
  required Function() function,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: function,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cBackGround,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.cShadow.withOpacity(0.35),
              offset: const Offset(0, 5),
              blurRadius: 14,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.cLabel.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: assetSvdImageWidget(
                      image: icon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        AppColor.cLabel,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColor.cFont.withOpacity(0.5),
                ),
              ],
            ),

            const Spacer(),

            Text(
              title,
              style: pRegular14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
