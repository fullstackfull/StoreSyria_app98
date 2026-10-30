import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/profile_controller/profile_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../new_widgets/app_txt_field.dart';
import '../../new_widgets/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String profileImg;

  ProfileScreen({
    super.key,
    required this.name,
    required this.profileImg,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    profileController.nameController.text = widget.name;
    profileController.emailController.text =
        Prefs.getString(AppConstant.emailId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cLight,
        appBar: simpleAppBar(
          title: "My Account",
          label: null,
          isBack: true,
          isBold: true,
          onNewLabelTap: () {},
        ),
        body: SafeArea(
          child: Obx(
                () => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileHeader(isDark),
                  const SizedBox(height: 20),
                  _accountCard(isDark),
                  const SizedBox(height: 16),
                  _passwordCard(isDark),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _profileHeader(bool isDark) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColor.themeNavyBlueColor,
            AppColor.blueColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.themeNavyBlueColor
                .withValues(alpha: isDark ? 0.45 : 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          PositionedDirectional(
            end: -40,
            top: -50,
            child: _decorCircle(160, Colors.white.withValues(alpha: 0.06)),
          ),
          PositionedDirectional(
            start: -30,
            bottom: -60,
            child: _decorCircle(
                130, AppColor.themeNavyBlueColor.withValues(alpha: 0.18)),
          ),
          PositionedDirectional(
            end: 40,
            bottom: 30,
            child: _decorCircle(18, Colors.white.withValues(alpha: 0.10)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
            child: Column(
              children: [
                _avatar(),
                const SizedBox(height: 14),
                Text(
                  "Hello, ${widget.name}",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pBold18.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage your account and profile",
                  textAlign: TextAlign.center,
                  style: pMedium12.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    profileController.pickImage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Change Profile Photo",
                          style: pMedium12.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _avatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient ring
        Hero(
          tag: "123",
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColor.themeNavyBlueColor,
                  Colors.white.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.themeNavyBlueColor,
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColor.themeNavyBlueColor.withValues(alpha: 0.15),
                child: ClipOval(
                  child: _profileImage(),
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          end: 0,
          bottom: 2,
          child: GestureDetector(
            onTap: () {
              profileController.pickImage();
            },
            child: Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: AppColor.themeNavyBlueColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.themeNavyBlueColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

// ---------------------------------------------------------------------------
// PROFILE IMAGE
// ---------------------------------------------------------------------------

  Widget _profileImage() {
    if (profileController.selectedImagePath.value.isNotEmpty) {
      return Image.file(
        File(profileController.selectedImagePath.value),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
      );
    }

    return CachedNetworkImage(
      imageUrl: getImageUrl(widget.profileImg),
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return const AppShimmer(
          child: ShimmerCircle(size: 96),
        );
      },
      // لا يوجد طلب لطرف ثالث هنا: البديل محلي.
      //
      // This used to fetch the UPSTREAM VENDOR's avatar from
      // apps.rajodiya.com when the merchant had none of their own, and only
      // fell back to this icon if that third-party request also failed. The
      // icon was always the real terminal state, so going straight to it
      // changes nothing a user reaches on purpose -- it removes a request to
      // a third party nobody here has a contract with, and the traffic leak
      // that came with it.
      errorWidget: (context, url, error) {
        return const Icon(
          Icons.person,
          size: 44,
          color: Colors.white,
        );
      },
    );
  }

// ---------------------------------------------------------------------------
// SECTION CARD (shared shell for both cards)
// ---------------------------------------------------------------------------

  Widget _sectionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? DarkThemeColor.cBorder
              : AppColor.cBorder.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        AppColor.themeNavyBlueColor,
                        AppColor.blueColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: pSemiBold16.copyWith(
                          color: isDark ? Colors.white : AppColor.cLabel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: pRegular12.copyWith(
                          color: isDark
                              ? Colors.white60
                              : AppColor.cDarkGreyFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? DarkThemeColor.cBorder : AppColor.cDivider,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _accountCard(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      icon: Icons.manage_accounts_outlined,
      title: "Account Information",
      subtitle: "Update your personal information",
      child: Form(
        key: profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              title: 'Full Name',
              hint: 'Enter name',
              icon: Icons.person_outline,
              controller: profileController.nameController,
              validator: (value) => Validator.validateName(value!, "Name"),
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'Email Address',
              hint: 'Enter email',
              icon: Icons.email_outlined,
              controller: profileController.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => Validator.validateEmail(value!),
            ),
            const SizedBox(height: 22),
            AppButton(
              text: "Save Changes",
              isLoading: profileController.isLoading2.value,
              onPressed: () {
                if (profileFormKey.currentState!.validate()) {
                  if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                    commonToast(
                      type: AppSnackBarType.info,
                      AppConstant.demoString,
                    );
                  } else {
                    profileController.editProfile(
                      name: profileController.nameController.text.trim(),
                      email: profileController.emailController.text.trim(),
                      imagePath: profileController.selectedImagePath.value,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordCard(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      icon: Icons.shield_outlined,
      title: "Security",
      subtitle: "Keep your account password secure",
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              title: 'Current Password',
              hint: '*************',
              icon: Icons.lock_outline,
              controller: profileController.oldPasswordController,
              obscureText: profileController.isOldPassword.value,
              validator: (value) => Validator.validatePassword(value!),
              suffix: _visibilityToggle(
                isDark: isDark,
                obscured: profileController.isOldPassword.value,
                onPressed: () {
                  profileController.isOldPassword.value =
                  !profileController.isOldPassword.value;
                },
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'New Password',
              hint: '*************',
              icon: Icons.lock_reset_outlined,
              controller: profileController.passwordController,
              obscureText: profileController.isPassword.value,
              validator: (value) => Validator.validatePassword(value!),
              suffix: _visibilityToggle(
                isDark: isDark,
                obscured: profileController.isPassword.value,
                onPressed: () {
                  profileController.isPassword.value =
                  !profileController.isPassword.value;
                },
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'Confirm Password',
              hint: '*************',
              icon: Icons.verified_user_outlined,
              controller: profileController.confirmPasswordController,
              obscureText: profileController.isConfirmPassword.value,
              textInputAction: TextInputAction.done,
              validator: (value) => Validator.validateConfirmPassword(
                value!,
                profileController.passwordController.text,
              ),
              suffix: _visibilityToggle(
                isDark: isDark,
                obscured: profileController.isConfirmPassword.value,
                onPressed: () {
                  profileController.isConfirmPassword.value =
                  !profileController.isConfirmPassword.value;
                },
              ),
            ),
            const SizedBox(height: 22),
            AppButton(
              text: "Update Password",
              isLoading: profileController.isLoading.value,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                    commonToast(
                      type: AppSnackBarType.info,
                      AppConstant.demoString,
                    );
                  } else {
                    profileController.updatePassword(
                      oldPassword:
                      profileController.oldPasswordController.text.trim(),
                      newPassword:
                      profileController.passwordController.text.trim(),
                      confirmPassword:
                      profileController.confirmPasswordController.text.trim(),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
// ---------------------------------------------------------------------------
// PASSWORD VISIBILITY TOGGLE
// ---------------------------------------------------------------------------

  Widget _visibilityToggle({
    required bool isDark,
    required bool obscured,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      // Accessible name: this control has no visible text.
      tooltip: obscured ? 'show_password'.tr : 'hide_password'.tr,
      onPressed: onPressed,
      splashRadius: 20,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: isDark ? Colors.white60 : AppColor.cFont,
      ),
    );
  }
}
