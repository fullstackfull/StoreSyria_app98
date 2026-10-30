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

            // بدون هذين السطرين يبقى اتجاه الواجهة من اليسار إلى اليمين
            // مهما كانت اللغة، لأن MaterialApp يعود إلى
            // DefaultWidgetsLocalizations واتجاهه LTR دائماً.
            //
            // Without these two the ambient Directionality stays LTR whatever
            // the locale: MaterialApp falls back to
            // DefaultWidgetsLocalizations, whose textDirection is always
            // TextDirection.ltr. Arabic is this app's default AND fallback
            // locale, so every EdgeInsetsDirectional / PositionedDirectional
            // in lib/ was resolving the wrong way round, and Material's own
            // date pickers and selection menus were rendering English labels
            // to an Arabic merchant.
            //
            // Guarded by test/localization/ambient_direction_test.dart
            // (behaviour) and test/localization/app_root_wiring_test.dart
            // (that this file still passes them).
            localizationsDelegates: TranslationService.localizationsDelegates,
            supportedLocales: TranslationService.supportedLocales,

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