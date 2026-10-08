// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/theme_light/dark_theme.dart'; // تأكد من المسار
import 'package:store_go_app/config/theme_light/light_theme.dart'; // تأكد من المسار
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/theme_switch_overlay.dart';

class ThemeController extends GetxController {
  final scrollbarTheme = ScrollbarThemeData(
    thumbVisibility: MaterialStateProperty.all(true),
  );

  RxBool isDark = false.obs;

  bool get isDarkTheme => isDark.value;

  ThemeData get theme {
    if (isDarkTheme) {
      AppDarkTheme.darkColor();
      return _buildTheme(
        base: ThemeData.dark(),
        brightness: Brightness.dark,
        background: DarkThemeColor.cBackGround,
        card: DarkThemeColor.cCardBackground,
        surface: DarkThemeColor.cSurface,
        border: DarkThemeColor.cBorder,
        text: DarkThemeColor.cText,
        secondaryText: DarkThemeColor.cSecondaryText,
        primary: DarkThemeColor.cPrimary,
        accent: DarkThemeColor.cAccent,
        error: DarkThemeColor.cRedText,
        appBarBg: DarkThemeColor.cBottomNavyBlueColor,
        appBarFg: Colors.white,
      );
    } else {
      AppLightTheme.lightThemeColor();
      return _buildTheme(
        base: ThemeData.light(),
        brightness: Brightness.light,
        background: AppColor.cBackGround,
        card: Colors.white,
        surface: LightThemeColor.cLight,
        border: LightThemeColor.cBorder,
        text: LightThemeColor.cText,
        secondaryText: LightThemeColor.cFont,
        primary: LightThemeColor.cPrimary,
        accent: LightThemeColor.cAccent,
        error: LightThemeColor.cRedText,
        appBarBg: Colors.white,
        appBarFg: LightThemeColor.cPrimary,
      );
    }
  }

  ThemeData _buildTheme({
    required ThemeData base,
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color surface,
    required Color border,
    required Color text,
    required Color secondaryText,
    required Color primary,
    required Color accent,
    required Color error,
    required Color appBarBg,
    required Color appBarFg,
  }) {
    final bool dark = brightness == Brightness.dark;
    final RoundedRectangleBorder sheetShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    );

    return base.copyWith(
      // الدارك كان ياخد نصوص اللايت (أسود عغامق)، هلق كل ثيم بياخد نصوصه
      textTheme: base.textTheme.apply(
        fontFamily: 'Tajawal',
        bodyColor: text,
        displayColor: text,
      ),
      scrollbarTheme: scrollbarTheme,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: card,
      dividerColor: border,
      hintColor: secondaryText,
      iconTheme: IconThemeData(color: text),
      colorScheme: (dark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: card,
        onSurface: text,
        error: error,
        outline: border,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        ),
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        modalBackgroundColor: card,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black.withOpacity(dark ? 0.6 : 0.45),
        shape: sheetShape,
        dragHandleColor: border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: text,
          fontFamily: 'Tajawal',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: secondaryText, fontFamily: 'Tajawal'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? surface : const Color(0xFF1E222B),
        contentTextStyle: TextStyle(
          color: dark ? text : Colors.white,
          fontFamily: 'Tajawal',
        ),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: text, fontFamily: 'Tajawal'),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: surface,
        hintStyle: TextStyle(color: secondaryText),
        labelStyle: TextStyle(color: secondaryText),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withOpacity(0.3),
        selectionHandleColor: accent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
    );
  }

  void changeTheme(bool value) {
    // صورة للشاشة الحالية قبل التبديل، مشان أنيميشن الانتقال
    ThemeSwitchOverlay.capture();
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