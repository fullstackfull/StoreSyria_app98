// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/theme_light/dark_theme.dart'; // تأكد من المسار
import 'package:store_go_app/config/theme_light/light_theme.dart'; // تأكد من المسار
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';

class ThemeController extends GetxController {
  final scrollbarTheme = ScrollbarThemeData(
    thumbVisibility: MaterialStateProperty.all(true),
  );

  RxBool isDark = false.obs;

  bool get isDarkTheme => isDark.value;

  ThemeData get theme {
    if (isDarkTheme) {
      AppDarkTheme.darkColor();
      return ThemeData.dark().copyWith(
        scrollbarTheme: scrollbarTheme,
        primaryColor: AppColor.themeNavyBlueColor,
        scaffoldBackgroundColor: DarkThemeColor.cBackGround,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          backgroundColor: DarkThemeColor.cBottomNavyBlueColor,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: AppColor.themeNavyBlueColor,
          secondary: AppColor.themeGreenColor,
        ),
      );
    } else {
      AppLightTheme.lightThemeColor();
      return ThemeData.light().copyWith(
        scrollbarTheme: scrollbarTheme,
        primaryColor: AppColor.themeNavyBlueColor,
        scaffoldBackgroundColor: AppColor.cBackGround,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColor.themeNavyBlueColor,
        ),
        colorScheme: ColorScheme.light(
          primary: AppColor.themeNavyBlueColor,
          secondary: AppColor.themeGreenColor,
        ),
      );
    }
  }

  void changeTheme(bool value) {
    isDark.value = value;
    Prefs.setBool(AppConstant.isDarkUrl, value);

    update();
    print('Theme Changed to: ${value ? "Dark" : "Light"}');
  }

  @override
  void onInit() {
    super.onInit();
    bool savedTheme = Prefs.getBool(AppConstant.isDarkUrl) ?? false;
    isDark.value = savedTheme;
    if (isDark.value) {
      AppDarkTheme.darkColor();
    } else {
      AppLightTheme.lightThemeColor();
    }
  }
}