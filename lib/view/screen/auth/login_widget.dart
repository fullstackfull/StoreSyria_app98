import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/core/controller/auth/auth_controller.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/powered_by_lynomia.dart';
import '../../new_widgets/app_txt_field.dart';
import '../../widget/app_dialog.dart';

class NormalLoginWidget extends StatefulWidget {
  NormalLoginWidget({super.key});

  @override
  State<NormalLoginWidget> createState() => _NormalLoginWidgetState();
}

class _NormalLoginWidgetState extends State<NormalLoginWidget> {
  AuthController authController = Get.find<AuthController>();
  GlobalKey<FormState> formKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    authController.emailController.clear();
    authController.passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 50.h,
                ),
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
                              image: isDark ? DefaultImages.storeGoLogoDark : DefaultImages.storeGoLogo,
                              width: 180.w,
                              height: 100.h,
                            ),

                            /// Login title
                            Text(
                              "login".tr,
                              style: pSemiBold27
                            ),

                            SizedBox(height: 10.h),

                            /// Description
                            Text(
                              "please login to continue to your store!".tr,
                              textAlign: TextAlign.center,
                              style: pMedium14.copyWith(
                                fontSize: 15.sp,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: 30.h),

                            /// Email
                            AppTextField(
                              title: "email".tr,
                              hint: "name@company.com",
                              icon: Icons.email_outlined,
                              controller: authController.emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => Validator.validateEmail(value!),
                            ),

                            SizedBox(height: 20.h),

                            /// Password
                            Obx(
                                  () => AppTextField(
                                title: "password".tr,
                                hint: "••••••••",
                                icon: Icons.lock_outline,
                                controller: authController.passwordController,
                                obscureText: authController.isObscure.value,
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                value!.isEmpty ? "password is required".tr : null,
                                suffix: IconButton(
                                  // Accessible name: this control has no visible text.
                                  tooltip: authController.isObscure.value ? 'show_password'.tr : 'hide_password'.tr,
                                  onPressed: () {
                                    authController.isObscure.value = !authController.isObscure.value;
                                  },
                                  splashRadius: 20,
                                  icon: Icon(
                                    authController.isObscure.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 23.sp,
                                    color: Get.isDarkMode ? Colors.white60 : const Color(0xFF687386),
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
                                    FocusScope.of(context)
                                        .unfocus();

                                    if (formKey.currentState!
                                        .validate()) {
                                      await authController
                                          .loginAuth(
                                        email: authController
                                            .emailController
                                            .text
                                            .trim(),
                                        password: authController
                                            .passwordController
                                            .text
                                            .trim(),
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
                              child: Text(
                                "or continue with".tr,
                                style: pRegular12.copyWith(
                                  fontSize: 13.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            SizedBox(height: 15.h),

                            /// Social buttons
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
                                ),
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
          ],
        ),
      ),
    );
  }
}