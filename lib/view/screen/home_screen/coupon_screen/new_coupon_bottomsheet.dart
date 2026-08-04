// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';

class AddNewCouponWidget extends StatefulWidget {
  final bool isUpdate;
  final String? couponId;
  final String? name;
  final String? discount;
  final String? limit;
  final String? date;
  final String? code;
  final String? flat;
  final String? status;

  AddNewCouponWidget({Key? key, required this.isUpdate, this.name, this.discount, this.limit, this.date, this.code, this.flat, this.status, this.couponId}) : super(key: key);

  @override
  State<AddNewCouponWidget> createState() => _AddNewCouponWidgetState();
}

class _AddNewCouponWidgetState extends State<AddNewCouponWidget> {
  NewCouponController newCouponController = Get.put(NewCouponController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate == true) {
      newCouponController.couponNameController.text = widget.name!;
      newCouponController.discountController.text = widget.discount!;
      newCouponController.limitController.text = widget.limit ?? '';
      newCouponController.expDateController.text = widget.date ?? '';
      newCouponController.couponController.text = widget.code!;
      if (widget.flat == 'flat') {
        newCouponController.isFlat.value = true;
      } else {
        newCouponController.isFlat.value = false;
      }
      if (widget.status == '1') {
        newCouponController.isStatus.value = true;
      } else {
        newCouponController.isStatus.value = false;
      }
    } else {
      newCouponController.isStatus.value = true;
      newCouponController.isFlat.value = true;
      newCouponController.couponNameController.clear();
      newCouponController.discountController.clear();
      newCouponController.limitController.clear();
      newCouponController.expDateController.clear();
      newCouponController.couponController.clear();
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
      child: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  "New Coupon",
                  style: pRegular18.copyWith(
                    color: AppColor.cGreenFont,
                  ),
                ),
                verticalSpace(10),
                horizontalDivider(),
                verticalSpace(10),
                AddProductTextField(
                  controller: newCouponController.couponNameController,
                  labelText: 'Name:',
                  hintText: 'Enter Name',
                ),
                verticalSpace(10),
                Row(
                  children: [
                    CupertinoSwitch(
                      value: newCouponController.isFlat.value,
                      onChanged: (value) {
                        newCouponController.isFlat.value = value;
                        if (value == true) {
                          newCouponController.couponType.value = 'flat';
                        } else {
                          newCouponController.couponType.value = 'percentage';
                        }
                      },
                    ),
                    horizontalSpace(10),
                    Text(
                      "Flat Discount",
                      style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                    ),
                  ],
                ),
                verticalSpace(10),
                AddProductTextField(
                  controller: newCouponController.discountController,
                  labelText: 'Discount:',
                  hintText: 'Enter Discount',
                  keyboardType: TextInputType.number,
                ),
                verticalSpace(10),
                AddProductTextField(
                  controller: newCouponController.limitController,
                  labelText: 'Limit:',
                  hintText: 'Enter Limit',
                  keyboardType: TextInputType.number,
                ),
                verticalSpace(10),
                AddProductTextField(
                  controller: newCouponController.expDateController,
                  labelText: 'Expiry Date:',
                  hintText: 'Enter Expiry Date',
                  readOnly: true,
                  onTap: () {
                    newCouponController.pickDate(context);
                  },
                ),
                verticalSpace(10),
                Text(
                  "Code:",
                  style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                ),
                verticalSpace(10),
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    dashPattern: [3, 3],
                    radius: const Radius.circular(25),
                    color: AppColor.cGreenFont,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: newCouponController.couponController,
                            decoration: InputDecoration(
                              hintText: 'Generate Code',
                              hintStyle: pMedium12.copyWith(color: AppColor.cFont),
                              border: InputBorder.none,
                            ),
                            cursorColor: AppColor.themeNavyBlueColor,
                            style: pBold16.copyWith(color: AppColor.cGreenFont),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CommonIconButton(
                            iconData: DefaultImages.generateIcn,
                            title: 'Generate',
                            onPressed: () {
                              newCouponController.generateCodeData();
                            },
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          if (newCouponController.couponNameController.text.isNotEmpty ||
                              newCouponController.discountController.text.isNotEmpty ||
                              newCouponController.limitController.text.isNotEmpty ||
                              newCouponController.couponController.text.isNotEmpty ||
                              newCouponController.expDateController.text.isNotEmpty) {
                            if (widget.isUpdate == true) {
                              if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                commonToast(AppConstant.demoString);
                              } else {
                                newCouponController.addCoupon(
                                    isUpdate: widget.isUpdate,
                                    couponId: widget.couponId ?? '',
                                    couponName: newCouponController.couponNameController.text.trim(),
                                    couponType: newCouponController.couponType.value,
                                    disAmount: newCouponController.discountController.text.trim(),
                                    couponLimit: newCouponController.limitController.text.trim(),
                                    date: newCouponController.expDateController.text.trim(),
                                    code: newCouponController.couponController.text.trim(),
                                    );
                              }
                            } else {
                              newCouponController.addCoupon(
                                  isUpdate: widget.isUpdate,
                                  couponId: widget.couponId ?? '',
                                  couponName: newCouponController.couponNameController.text.trim(),
                                  couponType: newCouponController.couponType.value,
                                  disAmount: newCouponController.discountController.text.trim(),
                                  couponLimit: newCouponController.limitController.text.trim(),
                                  date: newCouponController.expDateController.text.trim(),
                                  code: newCouponController.couponController.text.trim(),
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
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
