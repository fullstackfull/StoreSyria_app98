// ignore_for_file: prefer_const_constructors

import 'package:store_go_app/utils/colors.dart';

class AppDarkTheme {
  AppDarkTheme._();

  static darkColor() {
    // الخلفيات
    AppColor.cBackGround = DarkThemeColor.cBackGround;
    AppColor.cLight = DarkThemeColor.cCardBackground;
    AppColor.cButton = DarkThemeColor.cSurface;
    AppColor.cBorder = DarkThemeColor.cBorder;
    AppColor.cDivider = DarkThemeColor.cDivider;
    AppColor.cShadow = DarkThemeColor.cShadow;
    AppColor.cGreyOpacity = DarkThemeColor.cGreyOpacity;

    // النصوص
    AppColor.cWhiteFont = DarkThemeColor.cWhiteFont;
    AppColor.cBlackFont = DarkThemeColor.cBlackFont;
    AppColor.cText = DarkThemeColor.cText;
    AppColor.cLabel = DarkThemeColor.cLabel;
    AppColor.cFont = DarkThemeColor.cSecondaryText;
    AppColor.cDarkGreyFont = DarkThemeColor.cSecondaryText;
    AppColor.cRedText = DarkThemeColor.cRedText;

    // البراند: الكحلي ما بيبين عالغامق، فمنستعمل أزرق أقوى
    AppColor.themeNavyBlueColor = DarkThemeColor.cPrimary;
    AppColor.blueColor = DarkThemeColor.cBlue;
    AppColor.themeGreenColor = DarkThemeColor.cAccent;
    AppColor.cGreenFont = DarkThemeColor.cAccent;
    AppColor.cBottomNavyBlueColor = DarkThemeColor.cBottomNavyBlueColor;
  }
}
