// ignore_for_file: must_be_immutable, prefer_const_constructors, avoid_print, prefer_const_constructors_in_immutables

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_drop_down_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/core/controller/home_controller/shipping_controller.dart';

class AddShippingWidget extends StatefulWidget {
  final bool isUpdate;
  final String? shippingId;
  final String? name;
  final String? description;

  AddShippingWidget({super.key, required this.isUpdate, this.shippingId, this.name, this.description});

  @override
  State<AddShippingWidget> createState() => _AddShippingWidgetState();
}

class _AddShippingWidgetState extends State<AddShippingWidget> {
  ShippingController shippingController = Get.put(ShippingController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate == true) {
      shippingController.nameController.text = widget.name!;
      shippingController.descriptionController.text = widget.description!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height / 1.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: AppColor.cBackGround,
      ),
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  children: [
                    assetSvdImageWidget(
                      image: DefaultImages.closeIcn,
                      colorFilter: ColorFilter.mode(AppColor.cGreenFont, BlendMode.srcIn),
                    ),
                    horizontalSpace(8),
                    Text(
                      "Close",
                      style: pSemiBold12.copyWith(
                        color: AppColor.cGreenFont,
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace(8),
              Text(
                "Create",
                style: pRegular12,
              ),
              verticalSpace(10),
              Text(
                "Add Shipping",
                style: pRegular18.copyWith(
                  color: AppColor.cGreenFont,
                ),
              ),
              verticalSpace(10),
              horizontalDivider(),
              verticalSpace(10),
              AddProductTextField(
                controller: shippingController.nameController,
                labelText: 'Name',
                hintText: "Enter name",
              ),
              verticalSpace(10),
              commonDropdownButtonWidget(
                labelText: 'Charges Type',
                hint: 'Select option',
                value: shippingController.chargesType.value,
                list: shippingController.chargesTypeList,
                onChanged: (value) {
                  shippingController.chargesType.value = value;
                },
              ),
              verticalSpace(10),
              AddProductTextField(
                controller: shippingController.amountController,
                labelText: 'Amount',
                hintText: "Enter Amount",
                keyboardType: TextInputType.number,
              ),
              verticalSpace(10),
              AddProductTextField(
                controller: shippingController.durationController,
                labelText: 'Return Order Duration',
                hintText: "Enter Return Order Duration",
                keyboardType: TextInputType.number,
              ),
              verticalSpace(10),
              Text(
                "Image:",
                style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
              ),
              verticalSpace(15),
              GestureDetector(
                onTap: () async {
                  shippingController.imagePath.value = await shippingController.pickFile();
                },
                child: addAttachmentWidget(
                  shippingController.imagePath.value == '' ? "Add attachment..." : shippingController.imagePath.value.split('/').last,
                ),
              ),
              verticalSpace(10),
              AddProductTextField(controller: shippingController.descriptionController, labelText: 'Description', hintText: "Enter Description", maxLines: 3),
              verticalSpace(25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: CommonIconButton(
                        title: 'Close',
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
                      title: widget.isUpdate == true ? "Update" : 'Create',
                      iconData: DefaultImages.whiteDoneIcn,
                      onPressed: () {
                        if (shippingController.nameController.text.isNotEmpty &&
                            shippingController.amountController.text.isNotEmpty &&
                            shippingController.durationController.text.isNotEmpty &&
                            shippingController.descriptionController.text.isNotEmpty &&
                            shippingController.imagePath.isNotEmpty) {
                          print("----->(${shippingController.imagePath.value})");
                          if (widget.isUpdate == true) {
                            if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                              commonToast(AppConstant.demoString);
                            } else {
                              shippingController.addShippingData(
                                  isUpdate: widget.isUpdate,
                                  shippingId: widget.shippingId ?? '',
                                  name: shippingController.nameController.text.trim(),
                                  description: shippingController.descriptionController.text.trim());
                            }
                          } else {
                            shippingController.addShippingData(
                                isUpdate: widget.isUpdate,
                                shippingId: widget.shippingId ?? '',
                                name: shippingController.nameController.text.trim(),
                                description: shippingController.descriptionController.text.trim());
                          }
                        } else {
                          commonToast("Please fill all field");
                        }
                      },
                      width: 240,
                      height: 35,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
