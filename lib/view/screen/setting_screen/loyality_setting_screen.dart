// ignore_for_file: must_be_immutable, avoid_print, prefer_const_constructors_in_immutables

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/core/controller/setting_controller/loyality_controller.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  LoyaltyProgramScreen({super.key});

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> {
  LoyaltyController loyaltyController = Get.put(LoyaltyController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() {
    loyaltyController.getLoyaltyData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: AppColor.cBackGround,
        appBar: simpleAppBar(title: "", date: ""),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(
            () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Store Loyalty Program",
                    style: pRegular20,
                  ),
                  verticalSpace(25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Status:",
                        style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                      ),
                      horizontalSpace(10),
                      CupertinoSwitch(
                        value: loyaltyController.isStatus.value,
                        onChanged: (value) {
                          loyaltyController.isStatus.value = value;
                          if (value == true) {
                            loyaltyController.status.value = 'on';
                          } else {
                            loyaltyController.status.value = 'off';
                          }
                          print("-----------${loyaltyController.status.value}");
                        },
                        activeColor: AppColor.themeGreenColor,
                      ),
                    ],
                  ),
                  verticalSpace(20),
                  AddProductTextField(
                    controller: loyaltyController.rewardPointController,
                    labelText: 'Reward points on orders of \$1000',
                    hintText: 'Enter reward',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {},
                  ),
                  verticalSpace(25),
                  Center(
                    child: CommonIconButton(
                      iconData: DefaultImages.whiteDoneIcn,
                      title: 'Save changes',
                      onPressed: () {
                        if (loyaltyController.rewardPointController.text.isNotEmpty) {
                          if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                            commonToast(AppConstant.demoString);
                          } else {
                            loyaltyController.setLoyaltyData(status: loyaltyController.status.value, point: loyaltyController.rewardPointController.text.trim());
                          }
                        } else {
                          commonToast("Please enter points");
                        }
                      },
                      btnColor: AppColor.themeGreenColor,
                      bColor: AppColor.themeGreenColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
