// ignore_for_file: prefer_const_constructors

import 'package:store_go_app/utils/colors.dart';

class AppDarkTheme {
  AppDarkTheme._();

  static darkColor() {
    AppColor.cBackGround = DarkThemeColor.cBackGround;
    AppColor.cWhiteFont = DarkThemeColor.cWhiteFont;
    AppColor.cBlackFont = DarkThemeColor.cBlackFont;
    AppColor.cText = DarkThemeColor.cText;
    AppColor.cLabel = DarkThemeColor.cLabel;
    AppColor.cBottomNavyBlueColor = DarkThemeColor.cBottomNavyBlueColor;
  }
}
