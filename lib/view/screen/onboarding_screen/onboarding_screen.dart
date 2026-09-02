// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';
import 'package:store_go_app/core/model/onboarding_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';

/// ============================================================
/// OnboardingScreen
/// - يدعم Lottie animations بدل الصور الثابتة
/// - يدعم Dark / Light mode
/// - يدعم الترجمة (GetX .tr) و RTL/LTR تلقائياً
/// ============================================================
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<OnboardingController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? AppColor.themeNavyBlueColor : AppColor.cLight,
        // ============================================================
        // FIX: استبدلنا GetBuilder بـ Obx هون تحديداً، لأن currentPage
        // هو RxInt (.obs) وGetBuilder ما بيسمعله إلا لو نادينا
        // controller.update() يدوياً. Obx بيتفاعل معه تلقائياً،
        // فهيك الخلفية بتتغير فوراً كل ما تتغير الصفحة.
        // ============================================================
        body: Obx(() {
          final pageColor = _hexToColor(
            controller.onboardingPages[controller.currentPage.value]
                .backgroundColor,
          );
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            // Light mode: خلفية بيضاء ثابتة بدون تدرّج ألوان.
            // Dark mode: يضل نفس تدرّج ألوان الصفحة (أغمق) زي ما كان.
            color: isDark ? null : AppColor.cWhite,
            decoration: isDark
                ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _adjustForTheme(pageColor, isDark, darken: 0),
                  _adjustForTheme(pageColor, isDark, darken: 0.30),
                ],
              ),
            )
                : null,
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(controller, isDark),
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.updatePage,
                      itemCount: controller.onboardingPages.length,
                      itemBuilder: (context, index) {
                        return _buildOnboardingPage(
                          controller.onboardingPages[index],
                          isDark,
                        );
                      },
                    ),
                  ),
                  _buildBottomSection(controller, isDark),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Skip button
  // ---------------------------------------------------------------
  Widget _buildTopBar(OnboardingController controller, bool isDark) {
    // بالـ Light mode الخلفية بيضا، فبدنا لون نص/خلفية غامق يبين فوقها.
    // بالـ Dark mode ضلينا عالأبيض الشفاف زي ما كان.
    final chipBg = isDark ? Colors.white.withOpacity(0.15) : AppColor.cButton;
    final textColor =
    isDark ? Colors.white.withOpacity(0.9) : AppColor.cText;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Align(
        alignment: Alignment.topRight,
        child: Obx(
              () => AnimatedOpacity(
            duration: Duration(milliseconds: 250),
            opacity: controller.currentPage.value <
                controller.onboardingPages.length - 1
                ? 1
                : 0,
            child: IgnorePointer(
              ignoring: controller.currentPage.value >=
                  controller.onboardingPages.length - 1,
              child: TextButton(
                onPressed: controller.skipOnboarding,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  backgroundColor: chipBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  'skip'.tr,
                  style: pMedium16.copyWith(color: textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // صفحة واحدة من الأونبوردينغ (Lottie + عنوان + وصف)
  // ---------------------------------------------------------------
  Widget _buildOnboardingPage(OnboardingModel page, bool isDark) {
    final titleColor = isDark ? Colors.white : AppColor.cText;
    final descColor =
    isDark ? Colors.white.withOpacity(0.85) : AppColor.cFont;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: _buildAnimatedIllustration(page.lottiePath, isDark),
          ),
          SizedBox(height: 40.h),
          Text(
            page.title.tr,
            style: pSemiBold27.copyWith(
              color: titleColor,
              fontSize: 26.sp,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              page.description.tr,
              style: pRegular16.copyWith(
                color: descColor,
                fontSize: 15.sp,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Lottie illustration مع دائرة خلفية شفافة وتأثير دخول ناعم
  // ---------------------------------------------------------------
  Widget _buildAnimatedIllustration(String lottiePath, bool isDark) {
    // بالـ Dark mode: دائرة بيضا شفافة خفيفة فوق الـ gradient الغامق.
    // بالـ Light mode: دائرة رمادي فاتح جداً فوق الخلفية البيضا عشان تبين حدودها.
    final circleColor =
    isDark ? Colors.white.withOpacity(0.08) : AppColor.cLight;

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          final clampedValue = value.clamp(0.0, 1.0);
          return Transform.scale(
            scale: clampedValue,
            child: Opacity(opacity: clampedValue, child: child),
          );
        },
        child: Container(
          width: 280.w,
          height: 280.h,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(24.w),
          child: Lottie.asset(
            lottiePath,
            fit: BoxFit.contain,
            repeat: true,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_outlined,
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : AppColor.cDarkGreyFont,
                size: 80.sp,
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // النقاط + أزرار التنقل
  // ---------------------------------------------------------------
  Widget _buildBottomSection(OnboardingController controller, bool isDark) {
    final nextBg = isDark ? Colors.white : AppColor.themeNavyBlueColor;
    final nextFg = isDark ? AppColor.themeNavyBlueColor : Colors.white;
    final prevBorder =
    isDark ? Colors.white.withOpacity(0.5) : AppColor.themeNavyBlueColor;
    final prevText = isDark ? Colors.white : AppColor.themeNavyBlueColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
      child: Column(
        children: [
          Obx(
                () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.onboardingPages.length,
                    (index) =>
                    _buildDot(index, controller.currentPage.value, isDark),
              ),
            ),
          ),
          SizedBox(height: 36.h),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: nextBg,
                        foregroundColor: nextFg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        elevation: 0,
                      ),
                      child: Text(
                        controller.currentPage.value ==
                            controller.onboardingPages.length - 1
                            ? 'get_started'.tr
                            : 'next'.tr,
                        style: pSemiBold16.copyWith(color: nextFg),
                      ),
                    ),
           ),
                ]),
             );
  }

  Widget _buildDot(int index, int currentPage, bool isDark) {
    final isActive = currentPage == index;
    final activeColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;
    final inactiveColor =
    isDark ? Colors.white.withOpacity(0.4) : AppColor.cBorder;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  // ---------------------------------------------------------------
  // تحويل كود اللون Hex (مثال: '#00B4D8') إلى Color
  // ---------------------------------------------------------------
  Color _hexToColor(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  // ---------------------------------------------------------------
  // تعتيم اللون شوي لعمل تدرّج، ويزيد التعتيم إضافي بالـ Dark mode
  // ---------------------------------------------------------------
  Color _adjustForTheme(Color base, bool isDark, {required double darken}) {
    final extraDark = isDark ? 0.20 : 0.0;
    return Color.lerp(base, Colors.black, darken + extraDark)!;
  }
}