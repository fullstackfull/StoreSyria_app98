// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class AppColor {
  static Color cBlack = Colors.black;
  static Color cWhite = Color(0xffFFFFFF);
  static Color cBorder = Color(0xffCFD9E3);
  static Color cLight = Color(0xfff2f6fa);

  // خلفية فاتحة مريحة
  static Color cBackGround = Color(0xffdce4f1);

  static Color cTransparent = Colors.transparent;

  // اللون الأزرق الداكن (Navy Blue) - الأساسي
  //static Color themeNavyBlueColor = Color(0xFF1E293B);
  static Color themeNavyBlueColor = Color(0xFF172C4E);
  static Color blueColor = Color(0xFF2C57A2);
  static Color cBottomNavyBlueColor = Color(0xFF172C4E);

  // لون التمييز (الأخضر/السماوي)
  static Color themeGreenColor = Color(0xFF00B4D8);

  static Color cButton = Color(0xffF0F1F5);
  static Color cRed = Color(0xffFF754C);

  static Color cLightGreen = Color.fromRGBO(0, 180, 216, 0.2);
  static Color cLightRed = Color.fromRGBO(252, 39, 90, 0.2);
  static Color cGreyOpacity = Color.fromRGBO(0, 0, 0, 0.52);

  /// Text Colors
  static Color cWhiteFont = Color(0xffFAFBFD);
  static Color cBlackFont = Colors.black;
  static Color cFont = Color(0xff66728c); // نص ثانوي فاتح
  static Color cGreenFont = Color(0xFF00B4D8);

  static Color cText = Color(0xff1E222B); // نص أساسي داكن
  static Color cDarkGreyFont = Color(0xff717887);
  static Color cLabel = Color(0xff172C4E);
  static Color cRedText = Color(0xffdc0303);
  static Color cHintFont = Color(0xffFFFFFF);

  static Color cShadow = Color.fromRGBO(0, 0, 0, 0.04);
  static Color cDivider = Color(0xffDCE2ED);
  static Color cPDFPage = Color(0xfff5f5f5);
}

class DarkThemeColor {
  // خلفية داكنة جداً
  static Color cBackGround = Color(0xFF0A0A13);

  // خلفية البطاقات والعناصر العائمة (أفتح قليلاً من الخلفية)
  static Color cCardBackground = Color(0xFF1E222B);

  // حدود العناصر في الدارك مود
  static Color cBorder = Color(0xFF2D3342);

  static Color cWhiteFont = Colors.black;
  static Color cBlackFont = Colors.white;

  // النص الأساسي في الدارك مود (أبيض)
  static Color cText = Colors.white;

  // النص الثانوي في الدارك مود (رمادي فاتح للقراءة المريحة)
  static Color cSecondaryText = Color(0xFFA0A0A0);

  static Color cLabel = Colors.white;
  static Color cBottomNavyBlueColor = Color(0xff222637);
}

class LightThemeColor {
  static Color cBackGround = Color(0xffFFFFFF);
  static Color cWhiteFont = Colors.white;
  static Color cBlackFont = Colors.black;
  static Color cText = Color(0xff1E222B);
  static Color cLabel = Color(0xff172C4E);
  static Color cBottomNavyBlueColor = Color(0xff172C4E);
}