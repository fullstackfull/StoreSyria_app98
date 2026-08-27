// ignore_for_file: must_be_immutable, avoid_print, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/core/controller/auth/auth_controller.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/widget/common_text_field.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/powered_by_lynomia.dart';
import '../../widget/app_dialog.dart';

class NormalLoginWidget extends StatefulWidget {
  NormalLoginWidget({super.key});

  @override
  State<NormalLoginWidget> createState() => _NormalLoginWidgetState();
}

class _NormalLoginWidgetState extends State<NormalLoginWidget> {
  AuthController authController =  Get.find<AuthController>();
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
      authController.emailController.clear();
      authController.passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [

        /// Background
        Positioned.fill(
        child: Image.asset(
        Get.isDarkMode
        ? "assets/images/login_dark.png"
            : "assets/images/login_light.png",
          fit: BoxFit.cover,
        ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 50.h),
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 430.w),
                child: Card(
                  elevation: 12.h,
                  color: Get.isDarkMode
                      ? const Color(0xff2d3446)
                      : Colors.white,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        /// Logo
                        assetImageWidget(
                          image: DefaultImages.storeGoLogo,
                          width: 180.w,
                          height: 100.h,
                        ),
                        Text(
                          "login".tr,
                          style: pBold24,
                        ),

                        SizedBox(height: 10.h),

                        Text(
                          "please login to continue to your store!".tr,
                          style: pMedium14.copyWith(
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 30.h),

                        /// Email
                        CommonTextField(
                          prefix: DefaultImages.envelopeIcn,
                          controller: authController.emailController,
                          labelText: "email".tr,
                          hintText: "name@company.com",
                          validator: (value) =>
                              Validator.validateEmail(value!),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(height: 20.h),

                        /// Password
                        Obx(
                              () => CommonTextField(
                            prefix: DefaultImages.lockIcn,
                            controller:
                            authController.passwordController,
                            labelText: "password".tr,
                            hintText: "••••••••",
                            obscureText:
                            authController.isObscure.value,
                            obscuringCharacter: "•",
                            validator: (value) =>
                            value!.isEmpty
                                ? "password is required".tr
                                : null,
                            suffix: IconButton(
                              onPressed: () {
                                authController.isObscure.value =
                                !authController.isObscure.value;
                              },
                              icon: Icon(
                                authController.isObscure.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15.h),

                        /// Login Button
                        Obx(
                              () => SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              isLoading:
                              authController.isLoading.value,
                              text: "login".tr,
                              onPressed:
                              authController.isLoading.value
                                  ? null
                                  : () async {
                                FocusScope.of(context).unfocus();
                                if (formKey.currentState!.validate()) {
                                  await authController.loginAuth(
                                    email: authController.emailController.text.trim(),
                                    password: authController.passwordController.text.trim(),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 30.h),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10.h),
                              child: Text("or continue with".tr,style: pRegular12.copyWith(color: Colors.grey)),),
                        SizedBox(height: 15.h),

                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: "Apple",
                                height: 45.h,
                                image: "assets/images/apple.png",
                                isIcon: true,
                                outlined: true,
                                onPressed: () {},
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: AppButton(
                                text: "Google",
                                height: 45.h,
                                image: "assets/images/google.png",
                                isIcon: true,
                                tintIcon: false,
                                outlined: true,
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15.h),
                        PoweredByLynomia(),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),
      ]),
    ));
  }
}