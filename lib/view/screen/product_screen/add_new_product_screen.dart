import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../core/model/create_product_model.dart';
import '../../new_widgets/app_txt_field.dart';
import '../../widget/app_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_drop_down_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/product_controller/add_product_controller.dart';

class AddNewProductScreen extends StatefulWidget {
  final bool isUpdate;
  final String? productId;
  final int? status;
  final String? productName;
  final String? price;
  final String? costPrice;
  final String? salePrice;
  final String? qty;
  final String? productCategories;
  final String? productTax;
  final String? variantName;
  final String? variantProduct;
  final String? productDescription;
  final String? trending;
  final String? categoryId;
  final String? discountType;
  final String? coverImageUrl;
  final List<String>? subImageUrls;
  final String? taxId;
  final String? taxStatus;
  final String? shippingId;
  final double? productWeight;
  final String? trackStock;
  final String? stockStatus;

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
    this.variantProduct,
    this.productDescription,
    this.trending,
    this.status,
    this.salePrice,
    this.costPrice,
    this.taxId,
    this.taxStatus,
    this.shippingId,
    this.productWeight,
    this.trackStock,
    this.stockStatus,
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isUpdate) {
        _initializeData();
        await addProductController.fetchProductDetailForUpdate(widget.productId ?? '');
      } else {
        addProductController.clear();
      }
      await addProductController.getCreateProductData(
          isUpdate: widget.isUpdate);
    });
  }

  void _initializeData() {
    final c = addProductController;

    c.productName.value.text = widget.productName ?? '';
    c.costPriceController.value.text = widget.costPrice?.toString() ?? '';
    c.stockQtyController.value.text = widget.qty ?? '';
    c.priceController.value.text = widget.price?.toString() ?? '';
    c.salePriceController.value.text = widget.salePrice?.toString() ?? '';
    c.productDescriptionController.value.text =
        widget.productDescription ?? '';
    c.categoryId.value = widget.categoryId ?? '';
    c.category.value = widget.productCategories ?? '';

    c.isTrending.value = widget.trending == '1';
    c.trending.value = widget.trending ?? '1';

    c.isStatus.value = widget.status == 1;
    c.status.value = widget.status?.toString() ?? '1';

    c.isVariant.value = widget.variantProduct == '1';
    c.variantType.value = widget.variantProduct ?? '0';

    c.taxIdController.value.text = widget.taxId ?? '';
    c.taxStatus.value = _taxOptions.contains(widget.taxStatus)
        ? widget.taxStatus!
        : 'none';
    c.shippingIdController.value.text = widget.shippingId ?? '';
    c.productWeightController.value.text =
        widget.productWeight?.toString() ?? '';
    c.trackStock.value = widget.trackStock ?? '1';
    c.stockStatus.value = _normalizeStockStatus(widget.stockStatus);

    c.coverImage.value = '';
    c.selectedSubImages.clear();
    c.existingCoverImageUrl.value = widget.coverImageUrl ?? '';
    c.existingSubImages.assignAll(widget.subImageUrls ?? []);
  }

  static const _taxOptions = ['none', 'taxable', 'shipping'];
  static const _stockStatusOptions = ['in_stock', 'out_of_stock', 'on_backorder'];

  String _normalizeStockStatus(String? v) {
    if (v == null || v.isEmpty) return 'in_stock';
    if (_stockStatusOptions.contains(v)) return v;
    if (v == '0') return 'out_of_stock';
    return 'in_stock';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1A2E) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF18263F) : Colors.white;
    final textColor = isDark ? Colors.white : AppColor.cText;
    final hintColor = isDark ? Colors.grey.shade400 : AppColor.cFont;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.08) : AppColor.cBorder;
    final softBg = isDark
        ? AppColor.themeNavyBlueColor.withOpacity(0.16)
        : AppColor.themeNavyBlueColor.withOpacity(0.07);

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
          onNewLabelTap: () {},
        ),
        body: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
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
                      subtitle: null,
                      icon: Icons.inventory_2_outlined,
                      child: _buildBasicInfoSection(textColor, hintColor,
                          borderColor, cardColor, softBg, isDark),
                    ),
                    verticalSpace(16.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "description".tr,
                      subtitle: null,
                      icon: Icons.description_outlined,
                      child: _buildDescriptionSection(textColor, hintColor,
                          borderColor, cardColor, softBg, isDark),
                    ),
                    verticalSpace(16.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "product_images".tr,
                      subtitle: null,
                      icon: Icons.image_outlined,
                      child: _buildImagesSection(
                          textColor, hintColor, borderColor, softBg),
                    ),
                    verticalSpace(16.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "pricing".tr,
                      subtitle: null,
                      icon: Icons.payments_outlined,
                      child: _buildPricingSection(textColor, hintColor,
                          borderColor, cardColor, softBg, isDark),
                    ),
                    verticalSpace(16.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "stock".tr,
                      subtitle: null,
                      icon: Icons.other_houses_outlined,
                      child: _buildInventorySection(
                          textColor, softBg, borderColor),
                    ),
                    verticalSpace(16.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "shipping_and_tax".tr,
                      subtitle: null,
                      icon: Icons.local_shipping_outlined,
                      child: _buildShippingTaxSection(
                          textColor, softBg, borderColor),
                    ),
                    verticalSpace(16.h),
                    _sectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      softBg: softBg,
                      textColor: textColor,
                      title: "product_settings".tr,
                      subtitle: null,
                      icon: Icons.settings_outlined,
                      child: _buildSettingsSection(
                          textColor, softBg, borderColor),
                    ),
                    verticalSpace(26.h),
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
    String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon,
                    size: 18.sp, color: AppColor.themeNavyBlueColor),
              ),
              horizontalSpace(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pSemiBold12.copyWith(
                          fontSize: 15.sp, color: textColor),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: pRegular12.copyWith(
                            fontSize: 11.sp, color: AppColor.cDarkGreyFont),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(16.h),
          Divider(color: borderColor, height: 1),
          verticalSpace(16.h),
          child,
        ],
      ),
    );
  }

// --- Basic info ---
  Widget _buildBasicInfoSection(Color textColor, Color hintColor,
      Color borderColor, Color cardColor, Color softBg, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("product_name_required".tr, textColor),
        AppTextField(
          controller: addProductController.productName.value,
          hint: 'enter_product_name'.tr,
          icon: Icons.inventory_2_outlined,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) => Validator.validateRequired(value ?? ''),
        ),
        verticalSpace(16.h),
        _requiredLabel('category'.tr, textColor),
        commonDropdownButtonWidget<Category>(
          labelText: '',
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
            if (cat == null) return "please_select_category".tr;
            return null;
          },
        ),
      ],
    );
  }

// --- Description ---
  Widget _buildDescriptionSection(Color textColor, Color hintColor,
      Color borderColor, Color cardColor, Color softBg, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('product_description'.tr),
        AppTextField(
          controller: addProductController.productDescriptionController.value,
          hint: 'enter_product_description'.tr,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

// --- Pricing ---
  Widget _buildPricingSection(Color textColor, Color hintColor,
      Color borderColor, Color cardColor, Color softBg, bool isDark) {
    final c = addProductController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _requiredLabel('price'.tr, textColor),
                  AppTextField(
                    controller: c.priceController.value,
                    hint: 'enter_price'.tr,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final requiredError =
                      Validator.validateRequired(value ?? '');
                      if (requiredError != null) return requiredError;
                      if (double.tryParse((value ?? '').trim()) == null) {
                        return 'invalid_price'.tr;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('sale_price'.tr),
                  AppTextField(
                    controller: c.salePriceController.value,
                    hint: 'enter_sale_price'.tr,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      // سعر الخصم اختياري
                      if (value == null || value.trim().isEmpty) return null;

                      final salePrice = double.tryParse(value.trim());
                      if (salePrice == null) return 'invalid_price'.tr;

                      final regularPrice =
                      double.tryParse(c.priceController.value.text.trim());
                      if (regularPrice != null && salePrice >= regularPrice) {
                        return 'Must be less than price.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        verticalSpace(16.h),
        _requiredLabel('costPrice'.tr, textColor),
        AppTextField(
          controller: c.costPriceController.value,
          hint: 'enter_cost_price'.tr,
          icon: Icons.payments_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final requiredError = Validator.validateRequired(value ?? '');
            if (requiredError != null) return requiredError;

            final costPrice = double.tryParse((value ?? '').trim());
            if (costPrice == null) return 'invalid_price'.tr;

            final price = double.tryParse(c.priceController.value.text.trim());
            if (price != null && costPrice > price) {
              return 'Cost price must be less than or equal to price.';
            }
            return null;
          },
        ),
      ],
    );
  }

// --- Inventory ---
  Widget _buildInventorySection(
      Color textColor, Color softBg, Color borderColor) {
    final c = addProductController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: softBg,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: _toggleRow(
            icon: Icons.inventory_2_outlined,
            label: 'track_stock'.tr,
            textColor: textColor,
            value: c.trackStock.value == '1',
            onChanged: (v) => c.trackStock.value = v ? '1' : '0',
          ),
        ),
        verticalSpace(16.h),
        _requiredLabel('stock'.tr, textColor),
        AppTextField(
          controller: c.stockQtyController.value,
          hint: 'enter_stock'.tr,
          icon: Icons.other_houses_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (c.trackStock.value != '1') return null;
            return Validator.validateRequired(value ?? '');
          },
        ),
        verticalSpace(16.h),
        _label('stock_status'.tr),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: _stockStatusOptions.map((opt) {
            return _choiceChip(
              label: opt.tr,
              selected: c.stockStatus.value == opt,
              textColor: textColor,
              borderColor: borderColor,
              onTap: () => c.stockStatus.value = opt,
            );
          }).toList(),
        ),
      ],
    );
  }

// --- Shipping & tax ---
  Widget _buildShippingTaxSection(
      Color textColor, Color softBg, Color borderColor) {
    final c = addProductController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('product_weight'.tr),
                  AppTextField(
                    controller: c.productWeightController.value,
                    hint: 'enter_product_weight'.tr,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final w = double.tryParse(value.trim());
                      if (w == null || w < 0) {
                        return 'invalid_product_weight'.tr;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('shipping_id'.tr),
                  AppTextField(
                    controller: c.shippingIdController.value,
                    hint: 'enter_shipping_id'.tr,
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
          ],
        ),
        verticalSpace(16.h),
        _label('tax_status'.tr),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: _taxOptions.map((opt) {
            return _choiceChip(
              label: opt.tr,
              selected: c.taxStatus.value == opt,
              textColor: textColor,
              borderColor: borderColor,
              onTap: () {
                c.taxStatus.value = opt;
                if (opt == 'none') c.taxIdController.value.clear();
              },
            );
          }).toList(),
        ),
        if (c.taxStatus.value != 'none') ...[
          verticalSpace(16.h),
          _label('tax_id'.tr),
          AppTextField(
            controller: c.taxIdController.value,
            hint: 'enter_tax_id'.tr,
            icon: Icons.receipt_long_outlined,
            keyboardType: TextInputType.text,
          ),
        ],
      ],
    );
  }

  // --- Labels ---
  Widget _requiredLabel(String label, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          style: pMedium12.copyWith(
              color: AppColor.cDarkGreyFont, fontSize: 14.sp),
          children: [
            TextSpan(text: label),
            TextSpan(
              text: ' *',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: pMedium12.copyWith(
            color: AppColor.cDarkGreyFont, fontSize: 14.sp),
      ),
    );
  }

  Widget _uploadPlaceholder(Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined,
            size: 30.sp, color: AppColor.themeNavyBlueColor),
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
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Icon(Icons.close, size: 14.sp, color: Colors.white),
      ),
    );
  }

  // --- Choice chip (مخصص بالكامل، ما بيتأثر بألوان ثيم التطبيق) ---
  Widget _choiceChip({
    required String label,
    required bool selected,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final navy = AppColor.themeNavyBlueColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? navy.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? navy : borderColor),
        ),
        child: Text(
          label,
          style: pMedium12.copyWith(
            fontSize: 12.sp,
            color: selected ? navy : textColor,
          ),
        ),
      ),
    );
  }

  // --- Settings (trending / variant / status) ---
  Widget _buildSettingsSection(
      Color textColor, Color softBg, Color borderColor) {
    final c = addProductController;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          _toggleRow(
            icon: Icons.check_circle_outline_rounded,
            label: "status".tr,
            textColor: textColor,
            value: c.isStatus.value,
            onChanged: (value) {
              c.isStatus.value = value;
              c.status.value = value ? '1' : '0';
            },
          ),
          Divider(color: borderColor, height: 1),
          _toggleRow(
            icon: Icons.trending_up_rounded,
            label: "trending".tr,
            textColor: textColor,
            value: c.isTrending.value,
            onChanged: (value) {
              c.isTrending.value = value;
              c.trending.value = value ? '1' : '0';
            },
          ),
          Divider(color: borderColor, height: 1),
          _toggleRow(
            icon: Icons.tune_rounded,
            label: "variant_type".tr,
            textColor: textColor,
            value: c.isVariant.value,
            onChanged: (value) {
              c.isVariant.value = value;
              c.variantType.value = value ? '1' : '0';
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required Color textColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColor.themeNavyBlueColor),
              horizontalSpace(8.w),
              Text(
                label,
                style: pRegular12.copyWith(color: textColor, fontSize: 13.sp),
              ),
            ],
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.themeNavyBlueColor,
            thumbColor: AppColor.cWhite,
            trackColor: AppColor.cFont,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          text: 'close'.tr,
          onPressed: () {
            Get.back();
          },
          width: 90.w,
          height: 44.h,
          backgroundColor: AppColor.cBorder,
          textColor: AppColor.cDarkGreyFont,
        ),
        AppButton(
          isLoading: addProductController.isAddLoading.value,
          text: widget.isUpdate ? "update".tr : 'create'.tr,
          onPressed: () {
            final isFormValid = formKey.currentState?.validate() ?? false;
            if (!isFormValid) return;

            final hasCover =
                addProductController.coverImage.value.isNotEmpty ||
                    addProductController.existingCoverImageUrl.value.isNotEmpty;

            if (!hasCover) {
              commonToast(type: AppSnackBarType.info, "please_add_cover_image".tr);
              return;
            }

            final hasSubImages =
                addProductController.selectedSubImages.isNotEmpty ||
                    addProductController.existingSubImages.isNotEmpty;

            if (!hasSubImages) {
              commonToast(type: AppSnackBarType.info, "please_add_sub_image".tr);
              return;
            }

            _submitProductData();
          },
          width: 190.w,
          height: 44.h,
        ),
      ],
    );
  }
  // --- Images ---
  Widget _buildImagesSection(
      Color textColor, Color hintColor, Color borderColor, Color softBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("cover_image".tr, textColor),
        GestureDetector(
          onTap: () async {
            final path = await addProductController.pickImage();
            if (path != null) {
              addProductController.coverImage.value = path;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                dashPattern: [5, 5],
                strokeWidth: 1.3,
                radius: Radius.circular(18.r),
                color: AppColor.themeNavyBlueColor.withOpacity(0.6),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w),
                child: SizedBox(
                  height: 110.h,
                  width: double.infinity,
                  child: Obx(() {
                    // صورة جديدة اختارها المستخدم من الجهاز
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
                            top: 6,
                            right: 6,
                            child: _removeImageButton(
                              onTap: () {
                                addProductController.coverImage.value = '';
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    // صورة قديمة موجودة على السيرفر
                    if (addProductController
                        .existingCoverImageUrl.value.isNotEmpty) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: Image.network(
                              addProductController.existingCoverImageUrl.value,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  _uploadPlaceholder(textColor),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: _removeImageButton(
                              onTap: () {
                                addProductController
                                    .existingCoverImageUrl.value = '';
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return _uploadPlaceholder(textColor);
                  }),
                ),
              ),
            ),
          ),
        ),
        verticalSpace(20.h),
        _requiredLabel("sub_images".tr, textColor),
        GestureDetector(
          onTap: () async {
            await addProductController.getImages();
          },
          child: Container(
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                dashPattern: [5, 5],
                strokeWidth: 1.3,
                radius: Radius.circular(18.r),
                color: AppColor.themeNavyBlueColor.withOpacity(0.6),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w),
                child: SizedBox(
                  height: 110.h,
                  width: double.infinity,
                  child: Obx(() {
                    final existing = addProductController.existingSubImages;
                    final selected = addProductController.selectedSubImages;

                    if (existing.isEmpty && selected.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 30.sp,
                              color: AppColor.themeNavyBlueColor),
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
                        ...List.generate(existing.length, (index) {
                          final url = existing[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    width: 92.w,
                                    height: 108.h,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 92.w,
                                      height: 108.h,
                                      color: Colors.black12,
                                      child: const Icon(
                                          Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: _removeImageButton(
                                    onTap: () => addProductController
                                        .existingSubImages
                                        .removeAt(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        ...List.generate(selected.length, (index) {
                          final path = selected[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                    width: 92.w,
                                    height: 108.h,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: _removeImageButton(
                                    onTap: () => addProductController
                                        .selectedSubImages
                                        .removeAt(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitProductData() {
    final c = addProductController;

    addProductController.addProductData(
      existingCoverImageUrl: c.existingCoverImageUrl.value,
      variant: c.variantType.value,
      costPrice: c.costPriceController.value.text.trim(),
      status: c.status.value,
      isUpdate: widget.isUpdate,
      name: c.productName.value.text.trim(),
      categoryId: c.categoryId.value,
      productId: widget.productId ?? '',
      description: c.productDescriptionController.value.text.trim(),
      price: c.priceController.value.text.trim(),
      salePrice: c.salePriceController.value.text.trim(),
      productStock: c.stockQtyController.value.text.trim().isEmpty
          ? '0'
          : c.stockQtyController.value.text.trim(),
      trending: c.trending.value,
      // Images
      coverImage: c.coverImage.value,
      selectedSubImages: c.selectedSubImages,

      // Tax / shipping / stock
      taxId: c.taxStatus.value == 'none'
          ? ''
          : c.taxIdController.value.text.trim(),
      taxStatus: c.taxStatus.value,
      shippingId: c.shippingIdController.value.text.trim(),
      productWeight: c.productWeightController.value.text.trim(),
      trackStock: c.trackStock.value,
      stockStatus: c.stockStatus.value,
    );
  }
}