// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          backgroundColor: AppColor.cBackGround,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // STORE SETTINGS
                  // =====================================================

                  Text(
                    'store_settings'.tr,
                    style: pRegular20.copyWith(
                      color: AppColor.cFont,
                    ),
                  ),

                  verticalSpace(20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    children: [
                      settingCard(
                        icon: DefaultImages.statisticIcn,
                        title: 'analytics'.tr,
                        subtitle: 'view_store_performance'.tr,
                        isDark: isDark,
                        function: () {
                          Get.toNamed(AppRoutes.statistics);
                        },
                      ),

                      settingCard(
                        icon: DefaultImages.shippingIcn,
                        title: 'shipping'.tr,
                        subtitle: 'manage_shipping'.tr,
                        isDark: isDark,
                        function: () {
                          Get.toNamed(AppRoutes.shipping);
                        },
                      ),

                      settingCard(
                        icon: DefaultImages.taxIcn,
                        title: 'tax'.tr,
                        subtitle: 'manage_tax'.tr,
                        isDark: isDark,
                        function: () {
                          Get.toNamed(AppRoutes.tax);
                        },
                      ),

                      settingCard(
                        icon: DefaultImages.couponIcn,
                        title: 'coupon'.tr,
                        subtitle: 'manage_coupons'.tr,
                        isDark: isDark,
                        function: () {
                          Get.toNamed(AppRoutes.coupon);
                        },
                      ),
                    ],
                  ),

                  verticalSpace(28),

                  // =====================================================
                  // GENERAL SETTINGS
                  // =====================================================

                  Text(
                    'general_settings'.tr,
                    style: pRegular16.copyWith(
                      color: AppColor.cFont,
                    ),
                  ),

                  verticalSpace(12),

                  settingWidget(
                    icon: DefaultImages.storeIcn,
                    title: 'store_settings'.tr,
                    isDark: isDark,
                    function: () {
                      Get.to(() => StoreSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.themeIcn,
                    title: 'store_theme_settings'.tr,
                    isDark: isDark,
                    function: () {
                      Get.to(() => StoreThemeSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.categoriesIcn,
                    title: 'store_payment'.tr,
                    isDark: isDark,
                    function: () {
                      Get.to(() => PaymentSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.envelopeIcn,
                    title: 'store_email_setting'.tr,
                    isDark: isDark,
                    function: () {
                      Get.to(() => EmailSettingScreen());
                    },
                  ),

                  settingWidget(
                    icon: DefaultImages.loyaltyIcn,
                    title: 'store_loyalty_program'.tr,
                    isDark: isDark,
                    function: () {
                      Get.to(() => LoyaltyProgramScreen());
                    },
                  ),

                  verticalSpace(8),

                  // =====================================================
                  // LOG OUT
                  // =====================================================

                  settingWidget(
                    icon: DefaultImages.logoutIcn,
                    title: 'log_out'.tr,
                    isDark: isDark,
                    function: () async {
                      await FcmTokenService().clearFcmToken();

                      if (Get.isRegistered<NotificationController>()) {
                        Get.find<NotificationController>()
                            .clearNotificationData();
                      }

                      Prefs.clear();

                      Get.offAll(
                            () => NormalLoginWidget(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SETTING WIDGET
  // ============================================================

  Widget settingWidget({
    required String icon,
    required String title,
    required bool isDark,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: AppColor.cBackGround,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColor.cFont.withOpacity(0.06)
                    : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.cShadow.withOpacity(
                    isDark ? 0.12 : 0.30,
                  ),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // =====================================================
                // ICON
                // =====================================================

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

                // =====================================================
                // TITLE
                // =====================================================

                Expanded(
                  child: Text(
                    title,
                    style: pRegular14.copyWith(
                      color: AppColor.cFont,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // =====================================================
                // ARROW
                // =====================================================

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

// ============================================================
// SETTING CARD
// ============================================================

Widget settingCard({
  required String icon,
  required String title,
  required String subtitle,
  required bool isDark,
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
          border: Border.all(
            color: isDark
                ? AppColor.cFont.withOpacity(0.06)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.cShadow.withOpacity(
                isDark ? 0.12 : 0.35,
              ),
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
            // =========================================================
            // TOP ROW
            // =========================================================

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

            // =========================================================
            // TITLE
            // =========================================================

            Text(
              title,
              style: pRegular14.copyWith(
                color: AppColor.cFont,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // =========================================================
            // SUBTITLE
            // =========================================================

            Text(
              subtitle,
              style: pMedium10.copyWith(
                color: AppColor.cDarkGreyFont,
                fontSize: 9.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}