// ignore_for_file: must_be_immutable, prefer_const_constructors, avoid_print, prefer_const_constructors_in_immutables

import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_drop_down_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/core/controller/home_controller/tax_controller.dart';

class AddTaxWidget extends StatefulWidget {
  final bool isUpdate;
  final String? taxId;
  final String? name;
  final String? chargeType;
  final String? amount;
  final String? status;

  AddTaxWidget({super.key, required this.isUpdate, this.taxId, this.name, this.chargeType, this.amount, this.status});

  @override
  State<AddTaxWidget> createState() => _AddTaxWidgetState();
}

class _AddTaxWidgetState extends State<AddTaxWidget> {
  TaxController taxController = Get.put(TaxController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate == true) {
      taxController.nameController.text = widget.name!;
      taxController.chargesType.value = widget.chargeType!.capitalizeFirst!;
      taxController.amountController.text = widget.amount!;
      if (widget.status == '1') {
        taxController.isStatus.value = true;
      } else {
        taxController.isStatus.value = false;
      }
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
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  "Add Tax",
                  style: pRegular18.copyWith(
                    color: AppColor.cGreenFont,
                  ),
                ),
                verticalSpace(10),
                horizontalDivider(),
                verticalSpace(10),
                AddProductTextField(
                  controller: taxController.nameController,
                  labelText: 'Name',
                  hintText: "Enter name",
                ),
                verticalSpace(10),
                commonDropdownButtonWidget(
                  labelText: 'Charges Type',
                  hint: 'Select option',
                  value: taxController.chargesTypeList.contains(taxController.chargesType.value)
                      ? taxController.chargesType.value
                      : null,
                  list: taxController.chargesTypeList,
                  onChanged: (value) {
                    taxController.chargesType.value = value;
                  },
                ),
                verticalSpace(10),
                AddProductTextField(
                  controller: taxController.amountController,
                  labelText: 'Amount',
                  hintText: "Enter Amount",
                  keyboardType: TextInputType.number,
                ),
                verticalSpace(10),
                Row(
                  children: [
                    Text(
                      "Status:",
                      style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                    ),
                    horizontalSpace(10),
                    CupertinoSwitch(
                      value: taxController.isStatus.value,
                      onChanged: (value) {
                        taxController.isStatus.value = value;
                        if (value == true) {
                          taxController.status.value = '1';
                        } else {
                          taxController.status.value = '0';
                        }
                        print("-----------${taxController.status.value}");
                      },
                    ),
                  ],
                ),
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
                          if (taxController.nameController.text.isNotEmpty || taxController.amountController.text.isNotEmpty || taxController.chargesType.isNotEmpty) {
                            if (widget.isUpdate == true) {
                              if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                commonToast(AppConstant.demoString);
                              } else {
                                taxController.addTaxData(
                                  isUpdate: widget.isUpdate,
                                  taxId: widget.taxId ?? '',
                                  taxName: taxController.nameController.text.trim(),
                                  type: taxController.chargesType.value.toLowerCase(),
                                  taxAmount: taxController.amountController.text.trim(),
                                  status: taxController.status.value,
                                );
                              }
                            } else {
                              taxController.addTaxData(
                                isUpdate: widget.isUpdate,
                                taxId: widget.taxId ?? '',
                                taxName: taxController.nameController.text.trim(),
                                type: taxController.chargesType.value.toLowerCase(),
                                taxAmount: taxController.amountController.text.trim(),
                                status: taxController.status.value,
                              );
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
      ),
    );
  }
}
