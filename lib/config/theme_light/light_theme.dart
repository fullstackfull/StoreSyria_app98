import 'dart:ui';

import 'package:store_go_app/utils/colors.dart';

class AppLightTheme {
  AppLightTheme._();

  static void lightThemeColor() {
    // الخلفيات الأساسية
    AppColor.cBackGround = LightThemeColor.cBackGround;

    // النصوص
    AppColor.cText = LightThemeColor.cText;
    AppColor.cLabel = LightThemeColor.cLabel;
    AppColor.cWhiteFont = LightThemeColor.cWhiteFont;
    AppColor.cBlackFont = LightThemeColor.cBlackFont;

    // ألوان إضافية يجب تحديثها لضمان التناسق
    AppColor.cFont = Color(0xff66728c); // اللون الرمادي للنصوص الثانوية في الفاتح
    AppColor.cBorder = Color(0xffCFD9E3); // لون الحدود الفاتح
    AppColor.cShadow = Color.fromRGBO(0, 0, 0, 0.04); // الظل في الفاتح

    // ألوان البراند (يمكن تثبيتها أو تغييرها حسب الرغبة)
    AppColor.cBottomNavyBlueColor = LightThemeColor.cBottomNavyBlueColor;

    // ملاحظة: الألوان الثابتة مثل themeNavyBlueColor لا تحتاج لتغيير هنا
    // إلا إذا كنت تريد تغيير لون البراند نفسه في الوضع الفاتح فقط.
  }
}