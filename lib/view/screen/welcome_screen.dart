import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import '../../core/controller/auth/auth_controller.dart';
import '../../core/controller/onboarding_controller/onboarding_controller.dart';
import 'package:store_go_app/utils/app_log.dart';

class WelComeScreen extends StatefulWidget {
  const WelComeScreen({super.key});

  @override
  State<WelComeScreen> createState() => _WelComeScreenState();
}

class _WelComeScreenState extends State<WelComeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _barFade;
  final AuthController authController = Get.find<AuthController>();
  final OnboardingController onboardingController = OnboardingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _barFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _animationController.forward();

    _checkAndNavigate();

    Future.delayed(const Duration(milliseconds: 500), () {
    });
  }

  void _checkAndNavigate() {
    Future.delayed(Duration(milliseconds: 1500), () {
      final isOnboardingCompleted = onboardingController.isOnboardingCompleted;
      final isLoggedIn = Prefs.getToken().isNotEmpty;

      AppLog.d('🔍 التحقق في Welcome Screen:');
      AppLog.d('   OnBoarding: $isOnboardingCompleted');
      AppLog.d('   Logged In: $isLoggedIn');

      if (!isOnboardingCompleted) {
        Get.offAllNamed('/onboarding');
      } else if (isLoggedIn) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // دوائر زخرفية ناعمة بالخلفية
          PositionedDirectional(
            top: -90.h,
            end: -70.w,
            child: _GlowCircle(
              size: 240.w,
              color: AppColor.themeGreenColor.withOpacity(isDark ? 0.14 : 0.12),
            ),
          ),
          PositionedDirectional(
            bottom: -110.h,
            start: -80.w,
            child: _GlowCircle(
              size: 280.w,
              color: AppColor.themeNavyBlueColor.withOpacity(isDark ? 0.22 : 0.08),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: SizedBox(
                        width: 250.w,
                        child: assetImageWidget(
                          image: isDark ? DefaultImages.storeGoLogoDark : DefaultImages.storeGoLogo,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  FadeTransition(
                    opacity: _barFade,
                    child: SizedBox(
                      width: 140.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          minHeight: 4.h,
                          color: AppColor.themeGreenColor,
                          backgroundColor: isDark
                              ? DarkThemeColor.cBorder
                              : AppColor.themeGreenColor.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
