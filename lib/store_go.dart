// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, must_be_immutable, sdk_version_since

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'bindings/app_binding.dart';
import 'config/theme_light/dark_theme.dart';
import 'config/theme_light/light_theme.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/view/widget/theme_switch_overlay.dart';

class StoreGoApp extends StatelessWidget {
  StoreGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeController) {
        if (themeController.isDarkTheme) {
          AppDarkTheme.darkColor();
        } else {
          AppLightTheme.lightThemeColor();
        }

        return ScreenUtilInit(
          designSize: const Size(360, 800),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Store Syria',

            // Routes
            initialRoute: AppRoutes.splash,
            initialBinding: AppBinding(),
            getPages: AppRoutes.pages,

            // 1. الثيم الفاتح
            theme: themeController.theme,

            translations: TranslationService(),
            locale: TranslationService.currentLocale, // تحديد اللغة الافتراضية
            fallbackLocale: TranslationService.fallbackLocale,

            // 2. الثيم الداكن (تم إصلاح الخطأ هنا)
            darkTheme: themeController.theme,

            // 3. تحديد الوضع النشط (فاتح أم داكن)
            themeMode: themeController.isDarkTheme ? ThemeMode.dark : ThemeMode.light,

            // أنيميشن تبديل الثيم (دائرة كشف للثيم الجديد)
            builder: (context, child) =>
                ThemeSwitchOverlay(child: child ?? const SizedBox.shrink()),

          ),
        );
      },
    );
  }
}