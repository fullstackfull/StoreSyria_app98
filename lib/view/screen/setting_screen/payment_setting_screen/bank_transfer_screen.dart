// ignore_for_file: must_be_immutable, prefer_const_constructors_in_immutables

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/bank_transfer_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/payment_setting_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

class BankTransferScreen extends StatefulWidget {
  final String currency;
  final String currencySymbol;

  BankTransferScreen({super.key, required this.currency, required this.currencySymbol});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  PaymentSettingController paymentSettingController = Get.put(PaymentSettingController());

  BankTransferController bankTransferController = Get.put(BankTransferController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() {
    bankTransferController.getBankPaymentData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: AppColor.cBackGround,
        appBar: simpleAppBar(
            title: "Bank Transfer",
            isBack: true,
            label: null,
            onNewLabelTap: () {  }),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Status:",
                          style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                        ),
                        horizontalSpace(10),
                        CupertinoSwitch(
                          value: bankTransferController.isStatus.value,
                          onChanged: (value) {
                            bankTransferController.isStatus.value = value;
                            if (value == true) {
                              bankTransferController.status.value = 'on';
                            } else {
                              bankTransferController.status.value = 'off';
                            }
                            print("-----------${bankTransferController.status.value}");
                          },
                          activeColor: AppColor.themeGreenColor,
                        ),
                      ],
                    ),
                    verticalSpace(10),
                    AddProductTextField(
                      controller: bankTransferController.descriptionController,
                      labelText: 'Description',
                      hintText: 'Bank Transfer add bank details here',
                      maxLines: 6,
                    ),
                    verticalSpace(10),
                    Text(
                      "Image",
                      style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                    ),
                    verticalSpace(10),
                    CommonIconButton(
                      title: "Choose file here",
                      iconData: DefaultImages.whiteUploadIcn,
                      onPressed: () {
                        bankTransferController.pickImages();
                      },
                    ),
                    verticalSpace(15),
                    SizedBox(
                      width: 150,
                      height: 80,
                      child: bankTransferController.imagePath.value == ''
                          ? CachedNetworkImage(
                              imageUrl: getImageUrl(bankTransferController.networkImage.value),
                              placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) => SizedBox(),
                              fit: BoxFit.cover,
                            )
                          : Image.file(File(bankTransferController.imagePath.value)),
                    ),
                    verticalSpace(25),
                    CommonButton(
                      title: "Save",
                      onPressed: () {
                        if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                          commonToast(AppConstant.demoString);
                        } else {
                          bankTransferController.setBankTransferData(
                              currencyName: widget.currency,
                              currency: widget.currencySymbol,
                              status: bankTransferController.status.value,
                              bankInfo: bankTransferController.descriptionController.text.trim(),
                              image: bankTransferController.imagePath.value);
                        }
                      },
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
