// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/store_setting_controller.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/setting_screen/payment_setting_screen/payment_setting_screen.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../new_widgets/settings_card.dart';
import '../../widget/app_dialog.dart';
import 'email_setting_screen.dart';
import 'loyality_setting_screen.dart';

class StoreSettingScreen extends StatelessWidget {
  StoreSettingScreen({super.key});

  final StoreSettingController storeSettingController =
  Get.put(StoreSettingController());

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark  ? DarkThemeColor.cBackGround : AppColor.cLight,
      appBar: simpleAppBar(
        title: 'store_settings'.tr,
        label: null,
        isBack: true,
        onNewLabelTap: () {  },
      ),
      body: SingleChildScrollView(
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
              children: [
                settingCard(
                  isDark: isDark,
                  icon: DefaultImages.languageIcn,
                  title: 'language_and_currencies'.tr,
                  subtitle: "manage_your_customers_details".tr,
                  function: () => Get.toNamed(AppRoutes.lang),
                ),

                settingCard(
                  isDark: isDark,
                  icon: DefaultImages.storeIcn,
                  title: 'store_information'.tr,
                  subtitle: 'manage_store_information'.tr,
                  function: () {
                    // Store Information
                  },
                ),

                settingCard(
                  isDark: isDark,
                  icon: DefaultImages.themeIcn,
                  title: 'store_design'.tr,
                  subtitle: 'customize_your_store'.tr,
                  function: () {
                    // Store Design
                  },
                ),

                settingCard(
                  isDark: isDark,
                  icon: DefaultImages.taxIcn,
                  title: 'tax'.tr,
                  subtitle: 'manage_store_tax'.tr,
                  function: () {
                    Get.toNamed(AppRoutes.tax);
                  },
                ),

                settingCard(
                  isDark: isDark,
                  icon: DefaultImages.categoriesIcn,
                  title: 'store_payment'.tr,
                  subtitle: 'manage_payment_settings'.tr,
                  function: () {
                    Get.to(() => PaymentSettingScreen());
                  },
                ),

                settingCard(
                  isDark: isDark,
                  icon: DefaultImages.envelopeIcn,
                  title: 'store_email_setting'.tr,
                  subtitle: 'manage_email_settings'.tr,
                  function: () {
                    Get.to(() => EmailSettingScreen());
                  },
                ),

                settingCard(
                  isDark: isDark,
                  icon: DefaultImages.loyaltyIcn,
                  title: 'store_loyalty_program'.tr,
                  subtitle: 'manage_loyalty_program'.tr,
                  function: () {
                    Get.to(() => LoyaltyProgramScreen());
                  },
                ),
              ],
            ),

            verticalSpace(30),

            Text(
              'danger_zone'.tr,
              style: pRegular16.copyWith(
                color: AppColor.cRedText,
              ),
            ),

            verticalSpace(12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.cBackGround,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColor.cRed.withOpacity(
                    isDark ? 0.40 : 0.25,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.cRedText.withOpacity(
                      isDark ? 0.15 : 0.2,
                    ),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'delete_store'.tr,
                    style: pRegular16.copyWith(
                      color: AppColor.cFont,
                    ),
                  ),

                  verticalSpace(8),

                  Text(
                    'delete_store_description'.tr,
                    style: pRegular10.copyWith(
                      color: AppColor.cDarkGreyFont,
                    ),
                  ),

                  verticalSpace(18),

                  CommonIconButton(
                    iconData: DefaultImages.whiteCloseIcn,
                    title: 'delete_store'.tr,
                    onPressed: () => AppDialog.showCustomDialog(
                      message: "deleteStore",
                      lottieAsset: 'assets/lottie/delete_icon.json',
                      iconColor: AppColor.cRedText,
                      confirmColor: AppColor.cRedText,
                      context: context,
                      onConfirm: () =>
                          storeSettingController.deleteStoreData(),
                    ),
                    btnColor: AppColor.cRedText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}