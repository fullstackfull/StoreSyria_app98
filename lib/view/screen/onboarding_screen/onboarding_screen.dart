import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';
import 'package:store_go_app/core/model/onboarding_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<OnboardingController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cLight,
        body: Obx(() {
          final accent = _accentFor(
            _hexToColor(
              controller
                  .onboardingPages[controller.currentPage.value].backgroundColor,
            ),
            isDark,
          );

          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                  Color.lerp(DarkThemeColor.cBackGround, accent, 0.22)!,
                  DarkThemeColor.cBackGround,
                ]
                    : [
                  Color.lerp(AppColor.cWhite, accent, 0.10)!,
                  AppColor.cLight,
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // دوائر زخرفية ناعمة بالخلفية بلون الصفحة الحالية
                _buildBackgroundBlob(
                  accent: accent,
                  isDark: isDark,
                  size: 260.w,
                  top: -90.h,
                  start: -80.w,
                ),
                _buildBackgroundBlob(
                  accent: accent,
                  isDark: isDark,
                  size: 180.w,
                  top: 220.h,
                  end: -70.w,
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(controller, isDark, accent),
                      Expanded(
                        child: PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: controller.updatePage,
                          itemCount: controller.onboardingPages.length,
                          itemBuilder: (context, index) {
                            final page = controller.onboardingPages[index];
                            return _buildOnboardingPage(
                              page,
                              isDark,
                              _accentFor(_hexToColor(page.backgroundColor),
                                  isDark),
                            );
                          },
                        ),
                      ),
                      _buildBottomSection(controller, isDark, accent),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------
  // دائرة زخرفية شفافة بالخلفية
  // ---------------------------------------------------------------
  Widget _buildBackgroundBlob({
    required Color accent,
    required bool isDark,
    required double size,
    required double top,
    double? start,
    double? end,
  }) {
    return PositionedDirectional(
      top: top,
      start: start,
      end: end,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: isDark ? 0.22 : 0.14),
                accent.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // الشريط العلوي: عدّاد الخطوات + زر التخطي
  // ---------------------------------------------------------------
  Widget _buildTopBar(
      OnboardingController controller, bool isDark, Color accent) {
    final chipBg = isDark
        ? DarkThemeColor.cCardBackground.withValues(alpha: 0.85)
        : AppColor.cWhite;
    final chipBorder = isDark ? DarkThemeColor.cBorder : AppColor.cDivider;
    final textColor = isDark ? Colors.white : AppColor.cLabel;
    final total = controller.onboardingPages.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() {
        final current = controller.currentPage.value;
        final isLast = current >= total - 1;

        return Row(
          children: [
            // عدّاد الخطوات (1 / 3)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${current + 1} / $total',
                style: pSemiBold14.copyWith(
                  color: isDark ? Colors.white : AppColor.themeNavyBlueColor,
                ),
              ),
            ),
            Spacer(),
            AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              opacity: isLast ? 0 : 1,
              child: IgnorePointer(
                ignoring: isLast,
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  style: TextButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    backgroundColor: chipBg,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(color: chipBorder),
                    ),
                  ),
                  child: Text(
                    'skip'.tr,
                    style: pMedium14.copyWith(color: textColor),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------
  // صفحة واحدة من الأونبوردينغ (Lottie + عنوان + وصف)
  // ---------------------------------------------------------------
  Widget _buildOnboardingPage(OnboardingModel page, bool isDark, Color accent) {
    final titleColor = isDark ? Colors.white : AppColor.cLabel;
    final descColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: _buildAnimatedIllustration(page.lottiePath, isDark, accent),
          ),
          SizedBox(height: 28.h),
          Text(
            page.title.tr,
            style: pBold24.copyWith(
              color: titleColor,
              fontSize: 25.sp,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          // خط صغير بلون الصفحة تحت العنوان
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              page.description.tr,
              style: pRegular16.copyWith(
                color: descColor,
                fontSize: 15.sp,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Lottie داخل كرت دائري مع حلقات وتوهج وتأثير دخول ناعم
  // ---------------------------------------------------------------
  Widget _buildAnimatedIllustration(
      String lottiePath, bool isDark, Color accent) {
    final cardColor =
    isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final ringColor = accent.withValues(alpha: isDark ? 0.20 : 0.14);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          final clampedValue = value.clamp(0.0, 1.0);
          return Transform.scale(
            scale: 0.85 + (0.15 * value),
            child: Opacity(opacity: clampedValue, child: child),
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w, maxHeight: 300.w),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 1.5),
              ),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: isDark ? 0.10 : 0.07),
                ),
                child: Container(
                  padding: EdgeInsets.all(22.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardColor,
                    border: Border.all(
                      color: isDark ? DarkThemeColor.cBorder : AppColor.cDivider,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: isDark ? 0.30 : 0.18),
                        blurRadius: 40,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Lottie.asset(
                    lottiePath,
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_outlined,
                        color: isDark
                            ? DarkThemeColor.cSecondaryText
                            : AppColor.cDarkGreyFont,
                        size: 80.sp,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // النقاط + زر التالي / ابدأ
  // ---------------------------------------------------------------
  Widget _buildBottomSection(
      OnboardingController controller, bool isDark, Color accent) {
    final buttonGradient = isDark
        ? [AppColor.blueColor, AppColor.themeGreenColor]
        : [AppColor.themeNavyBlueColor, AppColor.blueColor];
    final shadowColor =
    (isDark ? AppColor.themeGreenColor : AppColor.blueColor)
        .withValues(alpha: isDark ? 0.25 : 0.30);

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
      child: Obx(() {
        final current = controller.currentPage.value;
        final isLast = current == controller.onboardingPages.length - 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.onboardingPages.length,
                    (index) => _buildDot(index, current, isDark, accent),
              ),
            ),
            SizedBox(height: 28.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: buttonGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.nextPage,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 250),
                          child: Text(
                            isLast ? 'get_started'.tr : 'next'.tr,
                            key: ValueKey(isLast),
                            style: pSemiBold16.copyWith(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLast ? Icons.check_rounded : Icons.arrow_forward,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDot(int index, int currentPage, bool isDark, Color accent) {
    final isActive = currentPage == index;
    final activeColor = isDark ? accent : AppColor.themeNavyBlueColor;
    final inactiveColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: isActive ? 28.w : 8.w,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }


  Color _hexToColor(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  Color _accentFor(Color base, bool isDark) {
    final luminance = base.computeLuminance();
    if (isDark) {
      if (luminance < 0.08) {
        return Color.lerp(base, AppColor.themeGreenColor, 0.65)!;
      }
      return base;
    }
    if (luminance > 0.5) return Color.lerp(base, Colors.black, 0.25)!;
    return base;
  }
}
