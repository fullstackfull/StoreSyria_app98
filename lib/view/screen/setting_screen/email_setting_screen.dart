// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/email_setting_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';

class EmailSettingScreen extends StatefulWidget {
  const EmailSettingScreen({super.key});

  @override
  State<EmailSettingScreen> createState() => _EmailSettingScreenState();
}

class _EmailSettingScreenState extends State<EmailSettingScreen> {
  EmailSettingController emailSettingController = Get.put(EmailSettingController());

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  getData() {
    emailSettingController.getEmailSettingData();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cBackGround,
      appBar: simpleAppBar(
          title: "Store Email Setting".tr,
          isBack: true,
          label: null,
          onNewLabelTap: () {  }),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddProductTextField(
                    controller: emailSettingController.mailDriver,
                    labelText: 'Mail Driver:'.tr,
                    hintText: 'Enter Mail Driver'.tr,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  AddProductTextField(
                    controller: emailSettingController.mailHost,
                    labelText: 'Mail Host:'.tr,
                    hintText: 'Mail Driver'.tr,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  AddProductTextField(
                    controller: emailSettingController.mailPort,
                    labelText: 'Mail Port:'.tr,
                    hintText: 'Enter Mail Driver'.tr,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  AddProductTextField(
                    controller: emailSettingController.mailUserName,
                    labelText: 'Mail Username:'.tr,
                    hintText: 'Enter Mail Driver'.tr,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  AddProductTextField(
                    controller: emailSettingController.mailPassword,
                    labelText: 'Mail Password:'.tr,
                    hintText: 'Enter Password'.tr,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  AddProductTextField(
                    controller: emailSettingController.mailEncryption,
                    labelText: 'Mail Encryption:'.tr,
                    hintText: 'Enter Encryption'.tr,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  AddProductTextField(
                    controller: emailSettingController.mailFromAddress,
                    labelText: 'Mail From Address:'.tr,
                    hintText: 'Enter From Address'.tr,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  AddProductTextField(
                    controller: emailSettingController.mailFromName,
                    labelText: 'Mail From Name:'.tr,
                    hintText: 'Enter Mail Driver'.tr,
                    validator: (value) {
                      return Validator.validateRequired(value!);
                    },
                    obscureText: Prefs.getBool(AppConstant.isDemoMode),
                    obscuringCharacter: '*',
                  ),
                  verticalSpace(20),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          title: 'Send Test Mail'.tr,
                          btnColor: AppColor.themeNavyBlueColor,
                          fontSize: 12,
                          textColor: AppColor.cWhite,
                          // width: 180,
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                backgroundColor: AppColor.cBackGround,
                                barrierColor: AppColor.cGreyOpacity,
                                isScrollControlled: true,
                                isDismissible: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: Container(
                                      height: Get.height / 2,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        ),
                                        color: AppColor.cBackGround,
                                      ),
                                      padding: EdgeInsets.all(24),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Send Test Mail".tr,
                                              style: pRegular20.copyWith(
                                                color: AppColor.cGreenFont,
                                              ),
                                            ),
                                            verticalSpace(10),
                                            horizontalDivider(),
                                            verticalSpace(10),
                                            AddProductTextField(
                                              controller: emailSettingController.emailController,
                                              labelText: 'Email:'.tr,
                                              hintText: 'Enter Email'.tr,
                                              keyboardType: TextInputType.emailAddress,
                                            ),
                                            verticalSpace(25),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: CommonIconButton(
                                                        title: 'close'.tr,
                                                        iconData: DefaultImages.closeIcn,
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        width: 75,
                                                        height: 35,
                                                        btnColor: AppColor.cButton,
                                                        textColor: AppColor.cDarkGreyFont),
                                                  ),
                                                  horizontalSpace(15),
                                                  Expanded(
                                                    flex: 2,
                                                    child: CommonIconButton(
                                                      title: 'Send'.tr,
                                                      iconData: DefaultImages.whiteDoneIcn,
                                                      onPressed: () {
                                                        if (emailSettingController.emailController.text.isNotEmpty) {
                                                          emailSettingController.sendTextEmailData(email: emailSettingController.emailController.text.trim());
                                                        } else {
                                                          commonToast(type: AppSnackBarType.info, "Please fill email field");
                                                        }
                                                      },
                                                      width: 240,
                                                      height: 35,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                        ),
                      ),
                      horizontalSpace(15),
                      Expanded(
                        child: CommonIconButton(
                          iconData: DefaultImages.whiteDoneIcn,
                          title: 'Save changes'.tr,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                commonToast(type: AppSnackBarType.info, AppConstant.demoString);
                              } else {
                                emailSettingController.saveEmailSettingData(
                                  mailDriver: emailSettingController.mailDriver.text.trim(),
                                  mailHost: emailSettingController.mailHost.text.trim(),
                                  mailPort: emailSettingController.mailPort.text.trim(),
                                  mailUserName: emailSettingController.mailUserName.text.trim(),
                                  mailPassword: emailSettingController.mailPassword.text.trim(),
                                  mailEncryption: emailSettingController.mailEncryption.text.trim(),
                                  mailFromAddress: emailSettingController.mailFromAddress.text.trim(),
                                  mailFromName: emailSettingController.mailFromName.text.trim(),
                                );
                              }
                            }
                          },
                          btnColor: AppColor.themeGreenColor,
                          width: 180,
                          bColor: AppColor.themeGreenColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
