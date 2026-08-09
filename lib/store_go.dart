// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, must_be_immutable, sdk_version_since

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/utils/constant.dart';
import 'bindings/app_binding.dart';
import 'config/theme_light/dark_theme.dart';
import 'config/theme_light/light_theme.dart';
import 'view/screen/welcome_screen.dart';
import 'view/screen/auth/login_widget.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:store_go_app/view/screen/dashboard_manager/dashboard_manager.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';

class StoreGoApp extends StatelessWidget {
  StoreGoApp({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _initAppData() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await remoteConfig.fetchAndActivate();
      String baseUrl = remoteConfig.getString('base_url');
      Prefs.setBaseUrl(baseUrl);
      print("Base URL Set: $baseUrl");
    } catch (e) {
      print("Remote Config Error: $e");
    }

    String isDemoMode = dotenv.get(AppConstant.isDemoMode);
    Prefs.setBool(AppConstant.isDemoMode, bool.parse(isDemoMode));

    String? accessToken = await Prefs.getToken();
    
    // ✅ التحقق من حالة OnBoarding
    final onboardingController = OnboardingController();
    final isOnboardingCompleted = onboardingController.isOnboardingCompleted;
    print('🔍 حالة OnBoarding في _initAppData: $isOnboardingCompleted');
    
    return {
      'token': accessToken,
      'onboarding_completed': isOnboardingCompleted,
    };
  }

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

            ),
        );
      },
    );
  }
}

