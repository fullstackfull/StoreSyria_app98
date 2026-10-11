import 'package:store_go_app/utils/colors.dart';

class AppLightTheme {
  AppLightTheme._();

  static void lightThemeColor() {
    // الخلفيات
    AppColor.cBackGround = LightThemeColor.cBackGround;
    AppColor.cLight = LightThemeColor.cLight;
    AppColor.cButton = LightThemeColor.cButton;
    AppColor.cBorder = LightThemeColor.cBorder;
    AppColor.cDivider = LightThemeColor.cDivider;
    AppColor.cShadow = LightThemeColor.cShadow;
    AppColor.cGreyOpacity = LightThemeColor.cGreyOpacity;

    // النصوص
    AppColor.cText = LightThemeColor.cText;
    AppColor.cLabel = LightThemeColor.cLabel;
    AppColor.cWhiteFont = LightThemeColor.cWhiteFont;
    AppColor.cBlackFont = LightThemeColor.cBlackFont;
    AppColor.cFont = LightThemeColor.cFont;
    AppColor.cDarkGreyFont = LightThemeColor.cDarkGreyFont;
    AppColor.cRedText = LightThemeColor.cRedText;

    // البراند (لازم يرجع لقيمه الأصلية بعد الدارك)
    AppColor.themeNavyBlueColor = LightThemeColor.cPrimary;
    AppColor.blueColor = LightThemeColor.cBlue;
    AppColor.themeGreenColor = LightThemeColor.cAccent;
    AppColor.cGreenFont = LightThemeColor.cAccent;
    AppColor.cBottomNavyBlueColor = LightThemeColor.cBottomNavyBlueColor;
  }
}