// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';
import 'package:store_go_app/core/model/onboarding_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GetBuilder<OnboardingController>(
        builder: (controller) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _getColor(controller.currentPage.value, 0),
                  _getColor(controller.currentPage.value, 1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Skip Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Obx(() => controller.currentPage.value < controller.onboardingPages.length - 1
                          ? TextButton(
                              onPressed: controller.skipOnboarding,
                              child: Text(
                                'skip'.tr,
                                style: pMedium16.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            )
                          : SizedBox()),
                    ),
                  ),

                  // PageView Content
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

                  // Bottom Section - Dots & Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                    child: Column(
                      children: [
                        // Page Indicator Dots
                        Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                controller.onboardingPages.length,
                                (index) => _buildDot(
                                  index,
                                  controller.currentPage.value,
                                ),
                              ),
                            )),

                        SizedBox(height: 40.h),

                        // Navigation Buttons
                        Obx(() => Row(
                              children: [
                                // Previous Button (except on first page)
                                if (controller.currentPage.value > 0)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: controller.previousPage,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 16.h),
                                      ),
                                      child: Text(
                                        'previous'.tr,
                                        style: pSemiBold16.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(width: 0),

                                if (controller.currentPage.value > 0) SizedBox(width: 16.w),

                                // Next/Done Button
                                Expanded(
                                  flex: controller.currentPage.value > 0 ? 1 : 2,
                                  child: ElevatedButton(
                                    onPressed: controller.nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColor.themeNavyBlueColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 16.h),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      controller.currentPage.value == controller.onboardingPages.length - 1
                                          ? 'get_started'.tr
                                          : 'next'.tr,
                                      style: pSemiBold16.copyWith(
                                        color: AppColor.themeNavyBlueColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingModel page, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration/Image
          Expanded(
            flex: 3,
            child: _buildAnimatedIllustration(page.image),
          ),

          SizedBox(height: 40.h),

          // Title
          Text(
            page.title,
            style: pSemiBold27.copyWith(
              color: Colors.white,
              fontSize: 28.sp,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            page.description,
            style: pRegular16.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIllustration(String imagePath) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          // التأكد من أن القيمة محصورة بين 0.0 و 1.0
          final clampedValue = value.clamp(0.0, 1.0);
          
          return Transform.scale(
            scale: clampedValue,
            child: Opacity(
              opacity: clampedValue,
              child: child,
            ),
          );
        },
        child: Container(
          width: 300.w,
          height: 300.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: assetSvdImageWidget(
              image: imagePath,
              width: 200.w,
              height: 200.h,
              colorFilter: ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, int currentPage) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: currentPage == index ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Color _getColor(int currentPage, int index) {
    final colors = [
      AppColor.themeGreenColor,
      AppColor.themeNavyBlueColor,
      AppColor.cBottomNavyBlueColor,
    ];
    return colors[currentPage % colors.length];
  }
}
