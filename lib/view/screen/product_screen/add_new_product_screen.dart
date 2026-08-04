// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, invalid_use_of_protected_member

import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'product_widget.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_drop_down_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/product_controller/add_product_controller.dart';

class AddNewProductScreen extends StatefulWidget {
  final bool isUpdate;
  final String? productId;
  final String? productName;
  final String? qty;
  final String? productCategories;
  final String? productTax;
  final String? variantName;
  final String? productDescription;
  final String? priceController;
  final String? disAmountController;
  final String? trending;

  const AddNewProductScreen({
    super.key,
    required this.isUpdate,
    this.productId,
    this.productName,
    this.qty,
    this.productCategories,
    this.productTax,
    this.variantName,
    this.productDescription,
    this.priceController,
    this.disAmountController,
    this.trending,
  });

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  AddProductController addProductController = Get.put(AddProductController());
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      getData();
    });
  }

  void _initializeData() {
    if (widget.isUpdate) {
      addProductController.productName.value.text = widget.productName ?? '';
      addProductController.stockQtyController.value.text = widget.qty ?? '';
      addProductController.productDescriptionController.value.text = widget.productDescription ?? '';
      addProductController.priceController.value.text = widget.priceController ?? '';
      addProductController.disAmountController.value.text = widget.disAmountController ?? '';
    } else {
      addProductController.clear();
    }
  }

  void getData() async {
    await addProductController.getCreateProductData(isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround;
    final textColor = isDark ? Colors.white : AppColor.cText;
    final hintColor = isDark ? Colors.grey.shade400 : AppColor.cFont;
    final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: simpleAppBar(
          title: widget.isUpdate ? "update_product".tr : "new_product".tr,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Obx(() {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(textColor, hintColor, borderColor),
                      verticalSpace(20.h),
                      _buildDescriptionSection(textColor, hintColor, borderColor),
                      verticalSpace(20.h),
                      _buildImagesSection(textColor, hintColor),
                      verticalSpace(20.h),
                      _buildPricingSection(textColor, hintColor, borderColor),
                      verticalSpace(30.h),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // --- Extracted Widgets ---

  Widget _buildBasicInfoSection(Color textColor, Color hintColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddProductTextField(
          controller: addProductController.productName.value,
          labelText: "product_name_required".tr,
          hintText: 'product_name_hint'.tr,
          onChanged: (value) {
            Validator.validateRequired(value);
          },
          validator: (value) {
            return Validator.validateRequired(value!);
          },
        ),
        verticalSpace(10.h),
        Text(
          "category".tr,
          style: pMedium12.copyWith(
            color: AppColor.cDarkGreyFont,
          ),
        ),
        verticalSpace(10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35.r),
            border: Border.all(color: borderColor),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
          child: DropdownButtonFormField<String>(
            value: addProductController.category.value.isEmpty
                ? null
                : addProductController.categoryTypeList.any((e) => e.name == addProductController.category.value)
                ? addProductController.category.value
                : null,
            hint: Text('select_category'.tr, style: pRegular12.copyWith(color: hintColor)),
            items: addProductController.categoryTypeList.map((data) {
              return DropdownMenuItem<String>(
                value: data.name,
                child: Text(
                  data.name!,
                  style: pRegular12,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                addProductController.category.value = value;
                final selectedCat = addProductController.categoryTypeList.firstWhereOrNull((c) => c.name == value);
                if (selectedCat != null) {
                  addProductController.categoryId.value = selectedCat.id.toString();
                }
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty || addProductController.categoryId.value.isEmpty) {
                return "please_select_category".tr;
              }
              return null;
            },
            icon: assetSvdImageWidget(
              image: DefaultImages.dropDownIcn,
              colorFilter: ColorFilter.mode(AppColor.cLabel, BlendMode.srcIn),
            ),
            isExpanded: true,
            style: pRegular12,
            borderRadius: BorderRadius.circular(35.r),
            dropdownColor: AppColor.themeGreenColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
        verticalSpace(10.h),
      ],
    );
  }

  Widget _buildDescriptionSection(Color textColor, Color hintColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddProductTextField(
          controller: addProductController.productDescriptionController.value,
          labelText: 'product_description'.tr,
          hintText: 'product_description'.tr,
          maxLines: 4,
          validator: (value) {
            return Validator.validateRequired(value!);
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: horizontalDivider(),
        ),
      ],
    );
  }

  Widget _buildImagesSection(Color textColor, Color hintColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "product_image".tr,
          style: pRegular16,
        ),
        verticalSpace(8.h),
        Text(
          "cover_image".tr,
          style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
        ),
        verticalSpace(10.h),
        GestureDetector(
          onTap: () async {
            final path = await addProductController.pickFile();
            if (path != null) addProductController.coverImage.value = path;
          },
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: [3, 3],
              radius: Radius.circular(25.r),
              color: AppColor.cGreenFont,
            ),
            child: Padding(
              padding: EdgeInsets.all(15.w),
              child: SizedBox(
                height: 99.h,
                child: addProductController.coverImage.value == ''
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outlined, size: 30.sp, color: AppColor.themeNavyBlueColor),
                    horizontalSpace(10.w),
                    Text(
                      "drop_files_upload".tr,
                      style: pSemiBold12,
                    ),
                  ],
                )
                    : Image.file(File(addProductController.coverImage.value)),
              ),
            ),
          ),
        ),
        verticalSpace(20.h),
        Text(
          "sub_images".tr,
          style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
        ),
        verticalSpace(10.h),
        GestureDetector(
          onTap: () {
            addProductController.getImages();
          },
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: [3, 3],
              radius: Radius.circular(25.r),
              color: AppColor.cGreenFont,
            ),
            child: Padding(
              padding: EdgeInsets.all(15.w),
              child: SizedBox(
                height: 100.h,
                child: addProductController.selectedSubImages.isEmpty
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outlined, size: 30.sp, color: AppColor.themeNavyBlueColor),
                    horizontalSpace(10.w),
                    Text(
                      "choose_file".tr,
                      style: pSemiBold12,
                    ),
                  ],
                )
                    : ListView.builder(
                  itemCount: addProductController.selectedSubImages.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                        child: Image.file(
                          File(addProductController.selectedSubImages[index]),
                        ));
                  },
                ),
              ),
            ),
          ),
        ),
        verticalSpace(15.h),
      ],
    );
  }

  Widget _buildPricingSection(Color textColor, Color hintColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CupertinoSwitch(
                  value: addProductController.isTrending.value,
                  onChanged: (value) {
                    addProductController.isTrending.value = value;
                    if (value == true) {
                      addProductController.trending.value = '1';
                    } else {
                      addProductController.trending.value = '0';
                    }
                  },
                  activeColor: AppColor.themeGreenColor,
                  thumbColor: AppColor.cWhite,
                  trackColor: AppColor.cFont,
                ),
                horizontalSpace(8.w),
                Text(
                  "trending".tr,
                  style: pRegular12,
                ),
              ],
            ),
          ],
        ),
        verticalSpace(15.h),
        AddProductTextField(
            controller: addProductController.priceController.value,
            labelText: 'price'.tr,
            hintText: 'enter_price'.tr,
            validator: (value) {
              return Validator.validateRequired(value!);
            },
            keyboardType: TextInputType.number),
        verticalSpace(10.h),
        commonDropdownButtonWidget(
          labelText: 'discount_type'.tr,
          hint: 'select_option'.tr,
          value: addProductController.discountType.value,
          list: addProductController.discountTypeList,
          validator: (value) {
            return Validator.validateRequired(value!);
          },
          onChanged: (value) {
            addProductController.discountType.value = value;
          },
        ),
        verticalSpace(15.h),
        AddProductTextField(
            controller: addProductController.disAmountController.value,
            labelText: 'discount_amount'.tr,
            hintText: 'enter_discount'.tr,
            validator: (value) {
              return Validator.validateRequired(value!);
            },
            keyboardType: TextInputType.number),
        AddProductTextField(
          controller: addProductController.stockQtyController.value,
          labelText: 'stock'.tr,
          hintText: 'enter_stock'.tr,
          keyboardType: TextInputType.number,
          validator: (value) {
            return Validator.validateRequired(value!);
          },
        ),
        verticalSpace(15.h),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonIconButton(
            title: 'close'.tr,
            iconData: DefaultImages.closeIcn,
            onPressed: () {
              Get.back();
            },
            width: 75.w,
            height: 35.h,
            btnColor: AppColor.cButton,
            textColor: AppColor.cDarkGreyFont),
        CommonIconButton(
          title: widget.isUpdate ? "update".tr : 'create'.tr,
          iconData: DefaultImages.whiteDoneIcn,
          onPressed: () {
            final isFormValid = formKey.currentState!.validate();
            if (!isFormValid) {
              return;
            }

            if (addProductController.coverImage.value == '') {
              commonToast("please_add_cover_image".tr);
              return;
            }

            if (addProductController.selectedSubImages.isEmpty) {
              commonToast("please_add_sub_image".tr);
              return;
            }

            if (widget.isUpdate == true) {
              if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                commonToast(AppConstant.demoString);
              } else {
                _submitProductData();
              }
            } else {
              _submitProductData();
            }
          },
          width: 200.w,
          height: 35.h,
        ),
      ],
    );
  }
  void _submitProductData() {
    addProductController.addProductData(
      isUpdate: widget.isUpdate,
      tag: addProductController.groupValue.value,
      name: addProductController.productName.value.text.trim(),
      categoryId: addProductController.categoryId.value,
      productId: widget.productId ?? '',
      description: addProductController.productDescriptionController.value.text.trim(),
      price: addProductController.priceController.value.text.trim(),
      discountType: addProductController.discountType.value,
      discountAmount: addProductController.disAmountController.value.text.trim(),
      productStock: addProductController.stockQtyController.value.text.trim(),
      trending: addProductController.trending.value,
      productOtherDescription: addProductController.otherDescriptionController.value.text.trim(),
      productMoreDescription: addProductController.moreInfoController.value.text.trim(),
      coverImage: addProductController.coverImage.value,
      otherDescriptionImage: addProductController.otherDescriptionImage.value,
      moreInformationImage: addProductController.moreInformationImage.value,
      selectedSubImages: addProductController.selectedSubImages.value,
    );
  }
}