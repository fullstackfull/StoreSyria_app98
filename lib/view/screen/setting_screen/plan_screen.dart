// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/setting_controller/plan_controller.dart';

class PlanScreen extends StatelessWidget {
  PlanScreen({Key? key}) : super(key: key);
  PlanController planController = Get.put(PlanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cBackGround,
      appBar: simpleAppBar(title: "Plans", date: ""),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Manage Plans",
                  style: pRegular20,
                ),
                verticalSpace(15),
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColor.themeGreenColor),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Free Plan",
                            style: pSemiBold19,
                          ),
                          Container(
                              decoration:
                                  BoxDecoration(color: AppColor.cLightGreen, borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Text(
                                "Active",
                                style: pMedium12.copyWith(color: AppColor.cGreenFont),
                              ))
                        ],
                      ),
                      verticalSpace(14),
                      Text(
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy ",
                        style: pRegular12.copyWith(color: AppColor.cDarkGreyFont),
                      ),
                      verticalSpace(10),
                      Text.rich(
                        TextSpan(
                          text: '630.00',
                          style: pBold30.copyWith(
                            fontSize: 31,
                          ), // default text style
                          children: <TextSpan>[
                            TextSpan(
                              text: ' USD ',
                              style: pMedium10.copyWith(
                                color: AppColor.cDarkGreyFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: horizontalDivider(),
                      ),
                      moreEmailWidget(backGroundColor: AppColor.cBackGround, totalEmail: "10,000", totalTask: "10,000"),
                    ],
                  ),
                ),
                verticalSpace(15),
                Text(
                  "Other Plans",
                  style: pRegular20,
                ),
                verticalSpace(15),
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: AppColor.themeNavyBlueColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Standard Plan",
                        style: pSemiBold19.copyWith(color: AppColor.cWhiteFont),
                      ),
                      verticalSpace(14),
                      Text(
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy ",
                        style: pRegular12.copyWith(color: AppColor.cFont),
                      ),
                      verticalSpace(10),
                      Text.rich(
                        TextSpan(
                          text: '630.00',
                          style: pBold30.copyWith(
                            fontSize: 31,
                            color: AppColor.cWhiteFont,
                          ), // default text style
                          children: <TextSpan>[
                            TextSpan(
                              text: ' USD ',
                              style: pMedium10.copyWith(
                                color: AppColor.cDarkGreyFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: horizontalDivider(),
                      ),
                      moreEmailWidget(
                          backGroundColor: AppColor.themeNavyBlueColor,
                          totalEmail: "10,000",
                          totalTask: "10,000",
                          textColor: AppColor.cWhiteFont),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: horizontalDivider(),
                      ),
                      CommonIconButton(
                        iconData: DefaultImages.upgradeIcn,
                        title: 'Upgrade',
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget moreEmailWidget({
    String? totalEmail,
    String? totalTask,
    Color? backGroundColor,
    Color? textColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: backGroundColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColor.themeGreenColor,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(color: AppColor.cLightGreen, borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    "More Emails",
                    style: pMedium12.copyWith(color: textColor ?? AppColor.cGreenFont),
                  ),
                ),
                verticalSpace(10),
                Text(
                  totalEmail!,
                  style: pMedium24.copyWith(color: textColor ?? AppColor.cLabel),
                ),
                verticalSpace(10),
                Text(
                  "Emails",
                  style: pRegular12.copyWith(color: textColor ?? AppColor.cLabel),
                ),
              ],
            ),
          ),
        ),
        horizontalSpace(15),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColor.themeGreenColor,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    decoration: BoxDecoration(color: AppColor.cLightGreen, borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      "More Tasks",
                      style: pMedium12.copyWith(color: textColor ?? AppColor.cGreenFont),
                    )),
                verticalSpace(10),
                Text(
                  totalTask!,
                  style: pMedium24.copyWith(color: textColor ?? AppColor.cLabel),
                ),
                verticalSpace(10),
                Text(
                  "Tasks",
                  style: pRegular12.copyWith(color: textColor ?? AppColor.cLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
