import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import '../../core/controller/auth/auth_controller.dart';

class WelComeScreen extends StatefulWidget {
  const WelComeScreen({super.key});

  @override
  State<WelComeScreen> createState() => _WelComeScreenState();
}

class _WelComeScreenState extends State<WelComeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );


    _animationController.forward();

    authController.checkLogin();

    Future.delayed(const Duration(milliseconds: 500), () {
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          assetImageWidget(
                    image: DefaultImages.storeGoLogo,
              ),

              const SizedBox(height: 50),

              CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColor.themeNavyBlueColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}