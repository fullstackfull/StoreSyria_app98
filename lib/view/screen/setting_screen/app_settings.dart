// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/store_setting_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import '../../../core/controller/setting_controller/theme_controller.dart';
import '../../../translations/translation_service.dart';
import '../../new_widgets/lang_widget.dart';

class AppSettingsScreen extends StatefulWidget {
  AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final ThemeController themeController = Get.put(ThemeController());
  final StoreSettingController storeSettingController = Get.put(StoreSettingController());
  bool isLanguageExpanded = false;


  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        TranslationService.currentLocale.languageCode == 'ar';

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: isDark  ? DarkThemeColor.cBackGround : const Color(0xFFF5F6F8),
      appBar: simpleAppBar(
        title: 'settings'.tr,
      ),
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
              mainCard(
                icon: Icons.language_rounded,
                title: 'languages'.tr,
                value: isArabic
                    ? 'arabic'.tr
                    : 'english'.tr,
                isExpanded: isLanguageExpanded,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    isLanguageExpanded =
                    !isLanguageExpanded;
                  });
                },
              ),

              AnimatedSize(
                duration:
                const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isLanguageExpanded
                    ? Padding(
                  padding:
                  const EdgeInsets.only(top: 12),
                  child: languageSelector(
                    isArabic: isArabic,
                    isDark: isDark,
                    onLanguageChanged: () {
                      setState(() {
                        isLanguageExpanded = false;
                      });
                    },
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),

              _themeCard(
                isDark: isDark,
                themeController: themeController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _themeCard({
  required bool isDark,
  required ThemeController themeController,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
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
          color: AppColor.themeGreenColor.withOpacity(
            isDark ? 0.10 : 0.12,
          ),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColor.themeGreenColor.withOpacity(
              isDark ? 0.12 : 0.08,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            isDark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            size: 24,
            color: AppColor.themeGreenColor,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'theme'.tr,
                style: pRegular14.copyWith(
                  color: isDark ? AppColor.cWhite : AppColor.cBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isDark
                    ? 'dark_mode'.tr
                    : 'light_mode'.tr,
                style: pRegular10.copyWith(
                  color: AppColor.cDarkGreyFont,
                ),
              ),
            ],
          ),
        ),

        CupertinoSwitch(
          value: isDark,
          onChanged: (value) {
            themeController.isDark.value = value;

            themeController.changeTheme(value);
          },
          activeColor: AppColor.themeGreenColor,
        ),
      ],
    ),
  );
}