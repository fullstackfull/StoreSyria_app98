// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables

import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/core/controller/profile_controller/profile_controller.dart';


class ProfileScreen extends StatefulWidget {
  final String name;
  final String profileImg;

  ProfileScreen({super.key, required this.name, required this.profileImg});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController profileController = Get.put(ProfileController());

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.nameController.text = widget.name;
    profileController.emailController.text = Prefs.getString(AppConstant.emailId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: AppColor.cBackGround,
        appBar: simpleAppBar(title: "My Account", date: "Monday, 30 Jan"),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColor.themeGreenColor,
                        child: ClipOval(
                          child: profileController.selectedImagePath.value.isNotEmpty
                              ? Image.file(
                                  File(profileController.selectedImagePath.value),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: getImageUrl(widget.profileImg),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => Image.network(
                                    DefaultImages.profileImg,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      horizontalSpace(15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${widget.name}",
                            style: pBold18.copyWith(fontSize: 20),
                          ),
                          Text(
                            "Change your account settings",
                            style: pMedium14.copyWith(color: AppColor.cGreenFont),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                                builder: (context) {
                                  return Container(
                                    height: 250,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        cameraIconWidget(
                                          image: DefaultImages.cameraIcn,
                                          title: "Camera",
                                          function: () {
                                            profileController.pickImage(ImageSource.camera);
                                          },
                                        ),
                                        horizontalSpace(35),
                                        cameraIconWidget(
                                          image: DefaultImages.galleryIcn,
                                          title: "Gallery",
                                          function: () {
                                            profileController.pickImage(ImageSource.gallery);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  assetSvdImageWidget(image: DefaultImages.cameraIcn),
                                  horizontalSpace(6),
                                  Text(
                                    "Change Profile Photo",
                                    style: pRegular10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: horizontalDivider(),
                  ),
                  Text(
                    "Store Theme Settings",
                    style: pRegular20,
                  ),
                  verticalSpace(25),
                  Form(
                    key: profileFormKey,
                    child: Column(
                      children: [
                        AddProductTextField(
                          controller: profileController.nameController,
                          labelText: 'Full Name',
                          hintText: 'Enter name',
                          validator: (value) {
                            return Validator.validateName(value!, "Name");
                          },
                        ),
                        verticalSpace(10),
                        AddProductTextField(
                          controller: profileController.emailController,
                          labelText: 'Email',
                          hintText: 'Enter email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => Validator.validateEmail(value!),
                        ),
                        verticalSpace(26),
                        CommonIconButton(
                          iconData: DefaultImages.whiteDoneIcn,
                          title: 'Save changes',
                          onPressed: () {
                            if (profileFormKey.currentState!.validate()) {
                              if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                commonToast(AppConstant.demoString);
                              } else {
                                profileController.editProfile(name: profileController.nameController.text.trim(), email: profileController.emailController.text.trim(), imagePath: profileController.selectedImagePath.value);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: horizontalDivider(),
                  ),
                  Text(
                    "Password",
                    style: pRegular20,
                  ),
                  verticalSpace(25),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        AddProductTextField(
                          controller: profileController.oldPasswordController,
                          labelText: 'Old Password:',
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
                              profileController.isOldPassword.value = !profileController.isOldPassword.value;
                            },
                            icon: Icon(
                              profileController.isOldPassword.value ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              color: AppColor.cFont,
                            ),
                          ),
                        ),
                        verticalSpace(10),
                        AddProductTextField(
                          controller: profileController.passwordController,
                          labelText: 'Password:',
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
                              profileController.isPassword.value = !profileController.isPassword.value;
                            },
                            icon: Icon(
                              profileController.isPassword.value ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              color: AppColor.cFont,
                            ),
                          ),
                        ),
                        verticalSpace(10),
                        AddProductTextField(
                          controller: profileController.confirmPasswordController,
                          labelText: 'Confirm Password:',
                          hintText: '*************',
                          obscuringCharacter: '*',
                          obscureText: profileController.isConfirmPassword.value,
                          onChanged: (value) {
                            Validator.validateConfirmPassword(value, profileController.passwordController.text);
                          },
                          validator: (value) {
                            return Validator.validateConfirmPassword(value!, profileController.passwordController.text);
                          },
                          suffix: IconButton(
                            onPressed: () {
                              profileController.isConfirmPassword.value = !profileController.isConfirmPassword.value;
                            },
                            icon: Icon(
                              profileController.isConfirmPassword.value ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              color: AppColor.cFont,
                            ),
                          ),
                        ),
                        verticalSpace(26),
                        CommonIconButton(
                          iconData: DefaultImages.whiteDoneIcn,
                          title: 'Save changes',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                commonToast(AppConstant.demoString);
                              } else {
                                profileController.updatePassword(
                                  oldPassword: profileController.oldPasswordController.text.trim(),
                                  newPassword: profileController.passwordController.text.trim(),
                                  confirmPassword: profileController.confirmPasswordController.text.trim(),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 15),
                  //   child: horizontalDivider(),
                  // ),
                  // Text(
                  //   "Delete Account",
                  //   style: pRegular20,
                  // ),
                  // verticalSpace(8),
                  // Text(
                  //   "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy ",
                  //   style: pRegular10.copyWith(color: AppColor.cDarkGreyFont),
                  // ),
                  // verticalSpace(26),
                  // CommonIconButton(
                  //   iconData: DefaultImages.whiteCloseIcn,
                  //   title: 'Delete My Account',
                  //   onPressed: () {},
                  //   btnColor: AppColor.cRed,
                  // ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget cameraIconWidget({String? image, String? title, Function()? function}) {
    return GestureDetector(
      onTap: function,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          assetSvdImageWidget(image: image, height: 40, width: 40),
          verticalSpace(10),
          Text(
            title!,
            style: pRegular20,
          )
        ],
      ),
    );
  }
}
