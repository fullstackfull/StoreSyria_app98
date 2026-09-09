// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/setting_screen/store_setting_screen.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../../core/controller/auth/auth_controller.dart';
import '../../new_widgets/settings_card.dart';

class SettingScreen extends StatelessWidget {
  final bool isBack;

  const SettingScreen({
    super.key,
    required this.isBack,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (_) {
        final bool isDark =
            Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: simpleAppBar(
              title: "more".tr,
              isBold: true,
              label: null,
              onNewLabelTap: () {}
          ),
          backgroundColor: isDark  ? DarkThemeColor.cBackGround : AppColor.cLight,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              24,
              14,
              24,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.2,
                  children: [
                    settingCard(
                      isDark: isDark,
                      icon: DefaultImages.statisticIcn,
                      title: 'analytics'.tr,
                      subtitle: 'view_store_performance'.tr,
                      function: () {
                        Get.toNamed(AppRoutes.statistics);
                      },
                    ),

                    settingCard(
                      isDark: isDark,
                      icon: DefaultImages.shippingIcn,
                      title: 'shipping'.tr,
                      subtitle: 'manage_shipping'.tr,
                      function: () {
                        Get.toNamed(AppRoutes.shipping);
                      },
                    ),

                    settingCard(
                      isDark: isDark,
                      icon: DefaultImages.groupImg,
                      title: 'customers'.tr,
                      subtitle: 'manage_customer'.tr,
                      function: () {
                        Get.toNamed(AppRoutes.customers);
                      },
                    ),

                    settingCard(
                      isDark: isDark,
                      icon: DefaultImages.couponIcn,
                      title: 'coupon'.tr,
                      subtitle: 'manage_coupons'.tr,
                      function: () {
                        Get.toNamed(AppRoutes.coupon);
                      },
                    ),
                  ],
                ),

                verticalSpace(28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.cBackGround,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.themeGreenColor.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      settingWidget(
                        icon: DefaultImages.storeIcn,
                        title: 'store_settings'.tr,
                        isDark: isDark,
                        function: () {
                          Get.to(() => StoreSettingScreen());
                        },
                      ),

                      settingWidget(
                        icon: DefaultImages.walletImg,
                        title: 'wallet'.tr,
                        isDark: isDark,
                        function: () {
                          Get.toNamed(AppRoutes.wallet);
                        }
                         ),


                      settingWidget(
                        icon: DefaultImages.settingIcn,
                        title: 'settings'.tr,
                        isDark: isDark,
                        function: () {
                          Get.toNamed(AppRoutes.appSettings);
                        },
                      ),
                      settingWidget(
                        icon: DefaultImages.logoutIcn,
                        title: 'log_out'.tr,
                        isDark: isDark,
                        function: () {
                          AppDialog.showCustomDialog(
                              context: context,
                              message: "logoutConfirm".tr,
                              title: "logout".tr,
                              lottieAsset: "assets/lottie/logout.json",
                              confirmText: "yes".tr,
                              popOnConfirm: false,
                              onConfirm: () async {
                                Get.find<AuthController>().logout();
                            }
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}