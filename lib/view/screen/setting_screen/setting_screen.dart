// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/screen/setting_screen/store_setting_screen.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../../core/controller/auth/auth_controller.dart';
import '../../new_widgets/settings_card.dart';
import '../../../core/permissions/merchant_permissions.dart';

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
                  // P2-07-13 / WS K13. These five cards were shown to every principal, because
                  // the app had no permission model at all -- `adminlogin` returned nothing about
                  // what the employee may do, so a staff member with orders-only access was
                  // offered Analytics, Shipping, Customers, Delivery Men and Coupons, and learned
                  // they could not use them only by tapping one.
                  //
                  // THE GATE IS COSMETIC AND MEANT TO BE. The permission list lives in
                  // unencrypted local storage, so on a rooted device it is attacker-controlled,
                  // and a route can be reached by other means. The control is server-side. This
                  // is here so a limited employee is not offered screens that will refuse them.
                  //
                  // `mayOffer`, NOT `may`: a server that has not been updated sends no list, and
                  // gating strictly on an empty list would empty this grid for everyone.
                  children: <Widget>[
                    if (MerchantPermissions.current
                        .mayOffer(Permissions.manageStoreAnalytics))
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.statisticIcn,
                        title: 'analytics'.tr,
                        subtitle: 'view_store_performance'.tr,
                        function: () {
                          Get.toNamed(AppRoutes.statistics);
                        },
                      ),

                    if (MerchantPermissions.current
                        .mayOffer(Permissions.manageShipping))
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.shippingIcn,
                        title: 'shipping'.tr,
                        subtitle: 'manage_shipping'.tr,
                        function: () {
                          Get.toNamed(AppRoutes.shipping);
                        },
                      ),

                    if (MerchantPermissions.current
                        .mayOffer(Permissions.manageCustomer))
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.groupImg,
                        title: 'customers'.tr,
                        subtitle: 'manage_customer'.tr,
                        function: () {
                          Get.toNamed(AppRoutes.customers);
                        },
                      ),

                    if (MerchantPermissions.current
                        .mayOffer(Permissions.manageDeliveryboy))
                      settingCard(
                        isDark: isDark,
                        icon: DefaultImages.deliveryManIcn,
                        title: 'delivery_men'.tr,
                        subtitle: 'manage_delivery_men'.tr,
                        function: () {
                          Get.toNamed(AppRoutes.deliveryBoys);
                        },
                      ),

                    if (MerchantPermissions.current
                        .mayOffer(Permissions.manageCoupon))
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
                    color: isDark ? DarkThemeColor.cCardBackground : AppColor.cBackGround,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color : AppColor.cBlack.withValues(alpha: 0.2),
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
                        icon: DefaultImages.myPlanImg,
                        title: 'my_plan'.tr,
                        isDark: isDark,
                        function: () {
                          Get.toNamed(AppRoutes.myPlan);
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