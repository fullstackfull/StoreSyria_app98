// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, invalid_use_of_protected_member

import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../core/model/create_product_model.dart';
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
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_drop_down_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/product_controller/add_product_controller.dart';

class AddNewProductScreen extends StatefulWidget {
  final bool isUpdate;
  final String? productId;
  final int? status;
  final String? productName;
  final double? price;
  final String? discount;
  final double? salePrice;
  final String? qty;
  final String? productCategories;
  final String? productTax;
  final String? variantName;
  final String? productDescription;
  final String? trending;
  final String? categoryId;
  final String? discountType;
  final String? coverImageUrl;
  final List<String>? subImageUrls;

  const AddNewProductScreen({
    super.key,
    required this.isUpdate,
    this.productId,
    this.price,
    this.productName,
    this.qty,
    this.productCategories,
    this.categoryId,
    this.discountType,
    this.coverImageUrl,
    this.subImageUrls,
    this.productTax,
    this.variantName,
    this.productDescription,
    this.trending,
    this.status,
    this.discount,
    this.salePrice,
  });

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  AddProductController addProductController = Get.find<AddProductController>();
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
      addProductController.priceController.value.text = widget.price.toString() ?? '';
      addProductController.salePriceController.value.text = widget.salePrice.toString() ?? '';
      addProductController.categoryId.value = widget.categoryId ?? '';
      addProductController.category.value = widget.productCategories ?? '';

      addProductController.discountType.value = widget.discountType ?? 'Flat';

      addProductController.isTrending.value = widget.trending == '1';
      addProductController.trending.value = widget.trending ?? '1';
      addProductController.isStatus.value = widget.status == 1;
      addProductController.status.value = widget.status?.toString() ?? '1';

      addProductController.existingCoverImageUrl.value = widget.coverImageUrl ?? '';
      addProductController.existingSubImages.assignAll(widget.subImageUrls ?? []);
    } else {
      addProductController.clear();
    }
  }

  void getData() async {
   // await addProductController.getCreateProductData(isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Color(0xFF14181F) : Color(0xFFF6F7F9);
    final cardColor = isDark ? Color(0xFF1E2530) : Colors.white;
    final textColor = isDark ? Colors.white : AppColor.cText;
    final hintColor = isDark ? Colors.grey.shade400 : AppColor.cFont;
    final borderColor = AppColor.cBorder;
    final softBg = isDark
        ? AppColor.themeNavyBlueColor.withOpacity(0.18)
        : AppColor.themeNavyBlueColor.withOpacity(0.06);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: simpleAppBar(
          isBack: true,
          title: widget.isUpdate ? "update_product".tr : "new_product".tr,
          label: null,
          onNewLabelTap: () { },
        ),
        body: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "basic_information".tr,
                      icon: Icons.inventory_2_outlined,
                      child: _buildBasicInfoSection(textColor, hintColor, borderColor, cardColor, softBg, isDark),
                    ),
                    verticalSpace(14.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "description".tr,
                      icon: Icons.description_outlined,
                      child: _buildDescriptionSection(textColor, hintColor, borderColor, cardColor, softBg, isDark),
                    ),
                    verticalSpace(14.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "product_images".tr,
                      icon: Icons.image_outlined,
                      child: _buildImagesSection(textColor, hintColor, borderColor, softBg),
                    ),
                    verticalSpace(14.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "price_and_stock".tr,
                      icon: Icons.payments_outlined,
                      child: _buildPricingSection(textColor, hintColor, borderColor, cardColor, softBg, isDark),
                    ),
                    verticalSpace(24.h),
                    _buildActionButtons(),
                    verticalSpace(10.h),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // --- Section card ---
  Widget _sectionCard({
    required Color cardColor,
    required Color borderColor,
    required Color softBg,
    required Color textColor,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 16.sp, color: AppColor.themeNavyBlueColor),
              ),
              horizontalSpace(8.w),
              Text(
                title,
                style: pSemiBold12.copyWith(fontSize: 14.sp, color: textColor),
              ),
            ],
          ),
          verticalSpace(14.h),
          child,
        ],
      ),
    );
  }

  // --- Extracted Widgets ---

  Widget _buildBasicInfoSection(
      Color textColor, Color hintColor, Color borderColor, Color cardColor, Color softBg, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddProductTextField(
          controller: addProductController.productName.value,
          labelText: "product_name_required".tr,
          hintText: 'enter_product_name'.tr,
          onChanged: (value) {
            Validator.validateRequired(value);
          },
          validator: (value) {
            return Validator.validateRequired(value!);
          },
        ),
        verticalSpace(14.h),
        commonDropdownButtonWidget<Category>(
          labelText: 'category'.tr,
          hint: 'select_category'.tr,
          value: addProductController.categoryTypeList.firstWhereOrNull(
                (c) => c.id.toString() == addProductController.categoryId.value,
          ),
          list: addProductController.categoryTypeList,
          itemLabel: (cat) => cat.name ?? "",
          onChanged: (cat) {
            if (cat != null) {
              addProductController.categoryId.value = cat.id.toString();
              addProductController.category.value = cat.name ?? "";
            }
          },
          validator: (cat) {
            if (cat == null) {
              return "please_select_category".tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(
      Color textColor, Color hintColor, Color borderColor, Color cardColor, Color softBg, bool isDark) {

    final bool hasCurrentDescription = widget.isUpdate &&
        (widget.productDescription?.trim().isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCurrentDescription) ...[
          Text(
            "current_description_readonly".tr,
            style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
          ),
          verticalSpace(8.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 80.h, maxHeight: 200.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor.withOpacity(0.5)),
            ),
            child: SingleChildScrollView(
              child: Html(
                data: widget.productDescription ?? '',
                style: {
                  "body": Style(
                    fontSize: FontSize(13.sp),
                    color: textColor,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "p": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                },
              ),
            ),
          ),
          verticalSpace(16.h),
          Divider(color: borderColor),
          verticalSpace(16.h),

          Text(
            "new_description_optional".tr,
            style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
          ),
          verticalSpace(8.h),
        ],
        AddProductTextField(
          controller: addProductController.productDescriptionController.value,
          labelText: hasCurrentDescription ? null : 'product_description'.tr,
          hintText: hasCurrentDescription
              ? 'enter_new_description_replace'.tr
              : 'product_description'.tr,
          maxLines: 5,
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImagesSection(Color textColor, Color hintColor, Color borderColor, Color softBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "cover_image".tr,
          style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
        ),
        verticalSpace(8.h),
        GestureDetector(
          onTap: () async {
            final path = await addProductController.pickImage();
            if (path != null) addProductController.coverImage.value = path;
          },
          child: Container(
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                dashPattern: [4, 4],
                strokeWidth: 1.2,
                radius: Radius.circular(16.r),
                color: AppColor.themeNavyBlueColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w),
                child: SizedBox(
                  height: 99.h,
                  width: double.infinity,
                  child: Builder(
                    builder: (_) {
                      if (addProductController.coverImage.value.isNotEmpty) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: Image.file(
                                File(addProductController.coverImage.value),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: _removeImageButton(
                                onTap: () => addProductController.coverImage.value = '',
                              ),
                            ),
                          ],
                        );
                      }
                      if (addProductController.existingCoverImageUrl.value.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Image.network(
                            addProductController.existingCoverImageUrl.value,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => _uploadPlaceholder(textColor),
                          ),
                        );
                      }
                      return _uploadPlaceholder(textColor);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        verticalSpace(18.h),
        Text(
          "sub_images".tr,
          style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
        ),
        verticalSpace(8.h),
        GestureDetector(
          onTap: () {
            addProductController.getImages();
          },
          child: Container(
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                dashPattern: [4, 4],
                strokeWidth: 1.2,
                radius: Radius.circular(16.r),
                color: AppColor.themeNavyBlueColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w),
                child: SizedBox(
                  height: 100.h,
                  width: double.infinity,
                  child: Builder(
                    builder: (_) {
                      final hasExisting = addProductController.existingSubImages.isNotEmpty;
                      final hasNew = addProductController.selectedSubImages.isNotEmpty;

                      if (!hasExisting && !hasNew) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 28.sp, color: AppColor.themeNavyBlueColor),
                            verticalSpace(6.h),
                            Text(
                              "choose_files".tr,
                              style: pSemiBold12.copyWith(color: textColor),
                            ),
                          ],
                        );
                      }

                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...List.generate(
                            addProductController.existingSubImages.length,
                                (index) {
                              final url = addProductController.existingSubImages[index];
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        width: 90.w,
                                        height: 100.h,
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: _removeImageButton(
                                        onTap: () => addProductController.existingSubImages.removeAt(index),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // الصور الجديدة (محلية)
                          ...List.generate(
                            addProductController.selectedSubImages.length,
                                (index) {
                              final path = addProductController.selectedSubImages[index];
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                        width: 90.w,
                                        height: 100.h,
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: _removeImageButton(
                                        onTap: () => addProductController.selectedSubImages.removeAt(index),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _uploadPlaceholder(Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 28.sp, color: AppColor.themeNavyBlueColor),
        verticalSpace(6.h),
        Text(
          "drop_files_upload".tr,
          style: pSemiBold12.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _removeImageButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: 14.sp, color: Colors.white),
      ),
    );
  }
  Widget _buildPricingSection(
      Color textColor, Color hintColor, Color borderColor, Color cardColor, Color softBg, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: softBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "trending".tr,
                    style: pRegular12.copyWith(color: textColor),
                  ),
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
                    activeColor: AppColor.themeNavyBlueColor,
                    thumbColor: AppColor.cWhite,
                    trackColor: AppColor.cFont,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "status".tr,
                    style: pRegular12.copyWith(color: textColor),
                  ),
                  CupertinoSwitch(
                    value: addProductController.isStatus.value,
                    onChanged: (value) {
                      addProductController.isStatus.value = value;

                      if (value == true) {
                        addProductController.status.value = 1.toString();
                      } else {
                        addProductController.status.value = 0.toString();
                      }
                    },
                    activeColor: AppColor.themeNavyBlueColor,
                    thumbColor: AppColor.cWhite,
                    trackColor: AppColor.cFont,
                  ),
                ],
              ),
            ],
          ),
        ),
        verticalSpace(16.h),
        AddProductTextField(
            controller: addProductController.priceController.value,
            labelText: 'price'.tr,
            hintText: 'enter_price'.tr,
            validator: (value) {
              return Validator.validateRequired(value!);
            },
            keyboardType: TextInputType.number
        ),
        verticalSpace(12.h),
        AddProductTextField(
            controller: addProductController.costPriceController.value,
            labelText: 'costPrice'.tr,
            hintText: 'enter_cost_price'.tr,
            validator: (value) {
              return Validator.validateRequired(value!);
            },
            keyboardType: TextInputType.number
        ),
        verticalSpace(12.h),
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
        verticalSpace(12.h),
        AddProductTextField(
            controller: addProductController.salePriceController.value,
            labelText: 'discount_amount'.tr,
            hintText: 'enter_discount'.tr,
            validator: (value) {
              return Validator.validateRequired(value!);
            },
            keyboardType: TextInputType.number),
        verticalSpace(12.h),
        AddProductTextField(
          controller: addProductController.stockQtyController.value,
          labelText: 'stock'.tr,
          hintText: 'enter_stock'.tr,
          keyboardType: TextInputType.number,
          validator: (value) {
            return Validator.validateRequired(value!);
          },
        ),
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
            width: 90.w,
            height: 42.h,
            btnColor: AppColor.cButton,
            textColor: AppColor.cDarkGreyFont),
        CommonIconButton(
          title: widget.isUpdate ? "update".tr : 'create'.tr,
          iconData: DefaultImages.whiteDoneIcn,
          onPressed: () {
            final isFormValid = formKey.currentState!.validate();
            if (!isFormValid) return;

            final hasCover = addProductController.coverImage.value.isNotEmpty ||
                addProductController.existingCoverImageUrl.value.isNotEmpty;

            if (!hasCover) {
              commonToast("please_add_cover_image".tr);
              return;
            }

            final hasSubImages = addProductController.selectedSubImages.isNotEmpty ||
                addProductController.existingSubImages.isNotEmpty;

            if (!hasSubImages) {
              commonToast("please_add_sub_image".tr);
              return;
            }

            _submitProductData();
          },
          width: 190.w,
          height: 42.h,
        ),
      ],
    );
  }

  void _submitProductData() {
    addProductController.addProductData(
      costPrice: addProductController.costPriceController.value.text.trim(),
      status: widget.status.toString(),
      isUpdate: widget.isUpdate,
      tag: addProductController.groupValue.value,
      name: addProductController.productName.value.text.trim(),
      categoryId: addProductController.categoryId.value,
      productId: widget.productId ?? '',
      description: addProductController.productDescriptionController.value.text.trim().isNotEmpty
          ? addProductController.productDescriptionController.value.text.trim()
          : (widget.isUpdate ? '' : ''),
      price: addProductController.priceController.value.text.trim(),
      salePrice: addProductController.salePriceController.value.text.trim(),
      discountType: addProductController.discountType.value,
      discountAmount: addProductController.salePriceController.value.text.trim(),
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