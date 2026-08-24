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
import '../../../translations/translation_service.dart';
import '../../new_widgets/lang_widget.dart';
import '../../new_widgets/settings_card.dart';
import '../../widget/app_dialog.dart';
import 'email_setting_screen.dart';
import 'loyality_setting_screen.dart';

class AppSettingsScreen extends StatefulWidget {
  AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final StoreSettingController storeSettingController =
  Get.put(StoreSettingController());
  bool isLanguageExpanded = false;


  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        TranslationService.currentLocale.languageCode == 'ar';

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: AppColor.cBackGround,
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

            ],
                ),
              ),
      ),
    );
  }
}