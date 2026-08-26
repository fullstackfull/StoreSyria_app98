// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/setting_screen/payment_setting_screen/stripe_screen.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/payment_setting_controller.dart';

import 'bank_transfer_screen.dart';
import 'cod_screen.dart';

class PaymentSettingScreen extends StatefulWidget {
  PaymentSettingScreen({super.key});

  @override
  State<PaymentSettingScreen> createState() => _PaymentSettingScreenState();
}

class _PaymentSettingScreenState extends State<PaymentSettingScreen> {
  PaymentSettingController paymentSettingController =
      Get.put(PaymentSettingController());

  getData() {
    paymentSettingController.getCodPaymentData();
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
      appBar: simpleAppBar(title: ''),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Store Payment Setting",
                style: pRegular20,
              ),
              verticalSpace(20),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: AddProductTextField(
                      controller: paymentSettingController.currencyController,
                      labelText: 'Currency *',
                      hintText: 'USD',
                      onChanged: (value) {},
                    ),
                  ),
                  horizontalSpace(15),
                  Expanded(
                    flex: 1,
                    child: AddProductTextField(
                      controller:
                          paymentSettingController.currencySymbolController,
                      labelText: 'Currency Symbol *',
                      hintText: '\$',
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              verticalSpace(10),
              buildPayment(
                title: 'COD',
                onTap: () {
                  Get.to(() => CODScreen(
                            currency: paymentSettingController
                                .currencyController.text,
                            currencySymbol: paymentSettingController
                                .currencySymbolController.text,
                            description:
                                paymentSettingController.codDescription.value,
                            isCodEnable:
                                paymentSettingController.isCodEnabled.value,
                            image:
                                paymentSettingController.codImage.value,
                          ))!
                      .then((value) => getData());
                },
              ),
              buildPayment(
                title: 'Bank Transfer',
                onTap: () {
                  Get.to(() => BankTransferScreen(
                        currency: paymentSettingController.currencyController.text,
                        currencySymbol: paymentSettingController.currencySymbolController.text,
                      ));
                },
              ),
              buildPayment(
                title: 'Stripe',
                onTap: () {
                  Get.to(() => StripeScreen(
                        currency:
                            paymentSettingController.currencyController.text,
                        currencySymbol: paymentSettingController.currencySymbolController.text,
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPayment({required String title, required Function() onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shadowColor: AppColor.cFont,
        color: AppColor.cBackGround,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          onTap: onTap,
          leading: assetSvdImageWidget(
              image: DefaultImages.cardIcn,
              colorFilter: ColorFilter.mode(AppColor.cLabel, BlendMode.srcIn)),
          title: Text(title, style: pMedium14),
          trailing: Icon(Icons.arrow_right_alt, color: AppColor.cFont),
        ),
      ),
    );
  }
}
