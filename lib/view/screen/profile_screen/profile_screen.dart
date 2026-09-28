// ignore_for_file: prefer_const_constructors, must_be_immutable
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/profile_controller/profile_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

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
        backgroundColor:
        isDark ? AppColor.cBackGround : const Color(0xffF7F8FA),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileHeader(isDark),

                  const SizedBox(height: 22),

                  _sectionTitle(
                    title: "Account Information",
                    subtitle: "Update your personal information",
                    isDark: isDark,
                  ),

                  const SizedBox(height: 14),

                  _accountCard(isDark),

                  const SizedBox(height: 25),

                  _sectionTitle(
                    title: "Security",
                    subtitle: "Keep your account password secure",
                    isDark: isDark,
                  ),

                  const SizedBox(height: 14),

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

// ---------------------------------------------------------------------------
// PROFILE HEADER
// ---------------------------------------------------------------------------

  Widget _profileHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cDarkGreyFont : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.themeGreenColor,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColor.themeGreenColor.withOpacity(0.12),
                  child: ClipOval(
                    child: _profileImage(),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  profileController.pickImage();
                },
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: AppColor.themeGreenColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColor.cDarkGreyFont
                          : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            "Hello, ${widget.name}",
            textAlign: TextAlign.center,
            style: pBold18.copyWith(
              fontSize: 21,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Manage your account and profile",
            textAlign: TextAlign.center,
            style: pMedium14.copyWith(
              color: AppColor.cGreenFont,
            ),
          ),

          const SizedBox(height: 15),

          GestureDetector(
            onTap: () {
              profileController.pickImage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: AppColor.themeGreenColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: AppColor.themeGreenColor,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    "Change Profile Photo",
                    style: pMedium14.copyWith(
                      color: AppColor.themeGreenColor,
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
        return Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColor.themeGreenColor,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Image.network(
          DefaultImages.profileImg,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        );
      },
    );
  }

// ---------------------------------------------------------------------------
// SECTION TITLE
// ---------------------------------------------------------------------------

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: pRegular20.copyWith(
            fontSize: 19,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: pRegular10.copyWith(
            fontSize: 12,
            color: isDark
                ? Colors.white60
                : AppColor.cDarkGreyFont,
          ),
        ),
      ],
    );
  }

// ---------------------------------------------------------------------------
// ACCOUNT CARD
// ---------------------------------------------------------------------------

  Widget _accountCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cDarkGreyFont : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: profileFormKey,
        child: Column(
          children: [
            _fieldLabel(
              icon: Icons.person_outline,
              title: "Full Name",
            ),

            const SizedBox(height: 8),

            AddProductTextField(
              controller: profileController.nameController,
              labelText: 'Full Name',
              hintText: 'Enter name',
              validator: (value) {
                return Validator.validateName(value!, "Name");
              },
            ),

            const SizedBox(height: 15),

            _fieldLabel(
              icon: Icons.email_outlined,
              title: "Email Address",
            ),

            const SizedBox(height: 8),

            AddProductTextField(
              controller: profileController.emailController,
              labelText: 'Email',
              hintText: 'Enter email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                return Validator.validateEmail(value!);
              },
            ),

            const SizedBox(height: 22),

            _saveButton(
              title: "Save Changes",
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
                      imagePath:
                      profileController.selectedImagePath.value,
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
// PASSWORD CARD
// ---------------------------------------------------------------------------

  Widget _passwordCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cDarkGreyFont : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _fieldLabel(
              icon: Icons.lock_outline,
              title: "Current Password",
            ),

            const SizedBox(height: 8),

            AddProductTextField(
              controller: profileController.oldPasswordController,
              labelText: 'Old Password',
              hintText: '*************',
              obscuringCharacter: '*',
              obscureText: profileController.isOldPassword.value,
              onChanged: (value) {
                Validator.validatePassword(value);
              },
              validator: (value) {
                return Validator.validatePassword(value!);
              },
              suffix: IconButton(
                onPressed: () {
                  profileController.isOldPassword.value =
                  !profileController.isOldPassword.value;
                },
                icon: Icon(
                  profileController.isOldPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColor.cFont,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _fieldLabel(
              icon: Icons.lock_reset_outlined,
              title: "New Password",
            ),

            const SizedBox(height: 8),

            AddProductTextField(
              controller: profileController.passwordController,
              labelText: 'Password',
              hintText: '*************',
              obscuringCharacter: '*',
              obscureText: profileController.isPassword.value,
              onChanged: (value) {
                Validator.validatePassword(value);
              },
              validator: (value) {
                return Validator.validatePassword(value!);
              },
              suffix: IconButton(
                onPressed: () {
                  profileController.isPassword.value =
                  !profileController.isPassword.value;
                },
                icon: Icon(
                  profileController.isPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColor.cFont,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _fieldLabel(
              icon: Icons.verified_user_outlined,
              title: "Confirm Password",
            ),

            const SizedBox(height: 8),

            AddProductTextField(
              controller: profileController.confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: '*************',
              obscuringCharacter: '*',
              obscureText:
              profileController.isConfirmPassword.value,
              onChanged: (value) {
                Validator.validateConfirmPassword(
                  value,
                  profileController.passwordController.text,
                );
              },
              validator: (value) {
                return Validator.validateConfirmPassword(
                  value!,
                  profileController.passwordController.text,
                );
              },
              suffix: IconButton(
                onPressed: () {
                  profileController.isConfirmPassword.value =
                  !profileController.isConfirmPassword.value;
                },
                icon: Icon(
                  profileController.isConfirmPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColor.cFont,
                ),
              ),
            ),

            const SizedBox(height: 22),

            _saveButton(
              title: "Update Password",
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                    commonToast(
                      type: AppSnackBarType.info,
                      AppConstant.demoString,
                    );
                  } else {
                    profileController.updatePassword(
                      oldPassword: profileController
                          .oldPasswordController.text
                          .trim(),
                      newPassword: profileController
                          .passwordController.text
                          .trim(),
                      confirmPassword: profileController
                          .confirmPasswordController.text
                          .trim(),
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
// FIELD LABEL
// ---------------------------------------------------------------------------

  Widget _fieldLabel({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColor.themeGreenColor,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: pMedium14.copyWith(
            fontSize: 13,
          ),
        ),
      ],
    );
  }

// ---------------------------------------------------------------------------
// SAVE BUTTON
// ---------------------------------------------------------------------------

  Widget _saveButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: CommonIconButton(
        iconData: DefaultImages.whiteDoneIcn,
        title: title,
        onPressed: onPressed,
      ),
    );
  }
}

