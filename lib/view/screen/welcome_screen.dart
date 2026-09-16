import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import '../../core/controller/auth/auth_controller.dart';
import '../../core/controller/onboarding_controller/onboarding_controller.dart';

class WelComeScreen extends StatefulWidget {
  const WelComeScreen({super.key});

  @override
  State<WelComeScreen> createState() => _WelComeScreenState();
}

class _WelComeScreenState extends State<WelComeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final AuthController authController = Get.find<AuthController>();
  final OnboardingController onboardingController = OnboardingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

      print('🔍 التحقق في Welcome Screen:');
      print('   OnBoarding: $isOnboardingCompleted');
      print('   Logged In: $isLoggedIn');

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
    return Scaffold(
      backgroundColor: AppColor.cWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        assetImageWidget(
                  image: DefaultImages.storeGoLogo,
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                minHeight: 5,
                color: AppColor.themeNavyBlueColor,
                backgroundColor: AppColor.cBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}