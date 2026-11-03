import 'package:flutter/material.dart';
import 'package:store_go_app/utils/store_syria_brand.dart';

class AppColor {
  static Color cBlack = Colors.black;
  static Color cWhite = Color(0xffFFFFFF);
  static Color cBorder = Color(0xffCFD9E3);
  static Color cLight = Color(0xfff2f6fa);
  static Color cBackGround = Color(0xffdce4f1);
  static Color cTransparent = Colors.transparent;
  // These four are the MUTABLE brand globals: AppLightTheme/AppDarkTheme overwrite them on every
  // theme switch, so the literals here are only the pre-switch defaults. Two of the names are
  // wrong and are left alone deliberately -- `themeGreenColor` and `cGreenFont` have held a CYAN
  // since long before Phase 2.5, and renaming them would touch 121 call sites across 32 files for
  // no behaviour change. StoreSyriaBrandTest pins what they actually hold.
  static Color themeNavyBlueColor = StoreSyriaBrand.blue;
  static Color blueColor = Color(0xFF2C57A2);
  static Color cBottomNavyBlueColor = StoreSyriaBrand.navy;
  static Color themeGreenColor = StoreSyriaBrand.cyan;   // CYAN, not green
  static Color cButton = Color(0xffF0F1F5);
  static Color cRed = Color(0xffFF754C);
  static Color cLightGreen = Color.fromRGBO(0, 180, 216, 0.2);
  static Color cLightRed = Color.fromRGBO(252, 39, 90, 0.2);
  static Color cGreyOpacity = Color.fromRGBO(0, 0, 0, 0.52);
  static Color cWhiteFont = Color(0xffFAFBFD);
  static Color cBlackFont = Colors.black;
  static Color cFont = Color(0xff66728c);
  static Color cGreenFont = StoreSyriaBrand.cyan;   // CYAN, not green
  static Color cText = Color(0xff1E222B);
  static Color cDarkGreyFont = Color(0xff717887);
  static Color cLabel = Color(0xff172C4E);
  static Color cRedText = Color(0xffdc0303);
  static Color cHintFont = Color(0xffFFFFFF);
  static Color cShadow = Color.fromRGBO(0, 0, 0, 0.04);
  static Color cDivider = Color(0xffDCE2ED);
  static Color cPDFPage = Color(0xfff5f5f5);
}

class DarkThemeColor {
  // خلفيات كحلية مريحة بدل الأسود الغامق
  static Color cBackGround = Color(0xFF0F1A2E);
  static Color cCardBackground = Color(0xFF18263F);
  static Color cSurface = Color(0xFF213252); // حقول الإدخال والعناصر المرفوعة
  static Color cBorder = Color(0xFF2E4266);
  static Color cDivider = Color(0xFF26385A);
  static Color cWhiteFont = Colors.black;
  static Color cBlackFont = Colors.white;
  static Color cText = Color(0xFFF1F5FB);
  static Color cSecondaryText = Color(0xFFA9B8D0);
  static Color cLabel = Color(0xFFF1F5FB);
  static Color cBottomNavyBlueColor = Color(0xFF14213A);

  // ألوان البراند بنسخة أقوى وأوضح على الخلفية الغامقة
  // P2.5-BR-03 -- cPrimary was Color(0xFF10AFC0), hue 185.8: the ONLY one of the app's six brand
  // colours that sat outside the logo's 189.4-218.9 gradient. The replacement is the same step
  // the web design system uses for its dark brand, so the two platforms now agree in dark mode as
  // well as light: 6.11:1 on cSurface, 7.23:1 on cCardBackground, 8.31:1 on cBackGround.
  static Color cPrimary = StoreSyriaBrand.cyanOnDark;
  static Color cBlue = Color(0xFF6EA2FF);          // hue 218.5, in band
  static Color cAccent = Color(0xFF22C7EA);        // hue 190.5, in band
  static Color cRedText = Color(0xFFFF6B6B);
  static Color cShadow = Color.fromRGBO(0, 0, 0, 0.35);
  static Color cGreyOpacity = Color.fromRGBO(0, 0, 0, 0.65);
}

class LightThemeColor {
  static Color cBackGround = Color(0xffFFFFFF);
  static Color cWhiteFont = Colors.white;
  static Color cBlackFont = Colors.black;
  static Color cText = Color(0xff1E222B);
  static Color cLabel = Color(0xff172C4E);
  static Color cBottomNavyBlueColor = Color(0xff172C4E);

  // P2.5-BR-03 -- the brand reads from StoreSyriaBrand, which is measured from the logo and is
  // the same source the Laravel admin cites. cPrimary was Color(0xFF172C4E), the deep navy: in
  // the gradient, but not the colour the logo sets its own tagline in. The navy is kept below as
  // cLabel and cBottomNavyBlueColor, where a filled bar under white type wants exactly that.
  static Color cPrimary = StoreSyriaBrand.blue;
  static Color cBlue = Color(0xFF2C57A2);          // 0.4 deg from the blue anchor; left as it was
  static Color cAccent = StoreSyriaBrand.cyan;     // was 0xFF00B4D8, 0.8 deg off the cyan anchor
  static Color cFont = Color(0xff66728c);
  static Color cDarkGreyFont = Color(0xff717887);
  static Color cBorder = Color(0xffCFD9E3);
  static Color cLight = Color(0xfff2f6fa);
  static Color cButton = Color(0xffF0F1F5);
  static Color cDivider = Color(0xffDCE2ED);
  static Color cRedText = Color(0xffdc0303);
  static Color cShadow = Color.fromRGBO(0, 0, 0, 0.04);
  static Color cGreyOpacity = Color.fromRGBO(0, 0, 0, 0.52);
}
