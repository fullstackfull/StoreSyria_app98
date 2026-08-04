// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/product_controller/add_product_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/order_screen/order_screen.dart';
import 'package:store_go_app/view/screen/product_screen/add_new_product_screen.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../core/model/create_product_model.dart';
import '../../widget/app_dialog.dart';
import '../../widget/error_empty_state.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final bool isBack;
  const ProductsScreen({super.key, required this.isBack});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with AutomaticKeepAliveClientMixin {
  final ProductController productController = Get.put(ProductController());
  final AddProductController addProductController = Get.put(AddProductController());
  final ScrollController scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        productController.currantPage.value = 1;
        productController.isScroll.value = true;
        productController.imageBaseUrl.value = Prefs.getString(AppConstant.imageUrl);
        addProductController.category.value = "";
        addProductController.categoryId.value = "";
        productController.productList.clear();
        getData();
      }
    });

    scrollController.addListener(() {
      if (productController.isScroll.value &&
          scrollController.offset >= scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        productController.currantPage.value += 1;
        productController.getProductData(productController.currantPage.value);
      }
    });
  }

  Future<void> getData() async {
    await productController.getProductData(productController.currantPage.value);

    if (addProductController.categoryTypeList.isEmpty) {
      await addProductController.getCreateProductData(isUpdate: false);

      if (addProductController.categoryTypeList.isNotEmpty) {
        if (addProductController.category.value.isEmpty) {
          addProductController.category.value = addProductController.categoryTypeList.first.name ?? "";
          addProductController.categoryId.value = addProductController.categoryTypeList.first.id?.toString() ?? "";
        }
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround;
    final cardBg = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5);
    final primaryText = isDark ? Colors.white : AppColor.cText;
    final secondaryText = isDark ? Colors.grey.shade400 : AppColor.cFont;
    final accentColor = AppColor.themeNavyBlueColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: simpleAppBar(isBack: widget.isBack, title: "products".tr),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonIconButton(
                title: 'add_product'.tr,
                iconData: DefaultImages.addCircleIcn,
                onPressed: () => Get.to(() => const AddNewProductScreen(isUpdate: false)),
                height: 51.h,
                textColor: Colors.white,
                btnColor: accentColor,
                bColor: accentColor,
              ),
              verticalSpace(15.h),

              // --- قسم الفلتر (كما هو) ---
              Obx(() {
                return Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: borderColor),
                    color: cardBg,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
                  child: DropdownButtonFormField<String>(
                    value: addProductController.categoryTypeList.isNotEmpty &&
                        addProductController.categoryTypeList.any((e) => e.name == addProductController.category.value)
                        ? addProductController.category.value
                        : null,
                    hint: Text('filter_by_category'.tr, style: TextStyle(fontSize: 12.sp, color: secondaryText)),
                    items: addProductController.categoryTypeList.map((data) {
                      return DropdownMenuItem<String>(
                        value: data.name,
                        child: Text(data.name ?? '', style: TextStyle(fontSize: 12.sp, color: primaryText)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        addProductController.category.value = value;
                        final selectedCat = addProductController.categoryTypeList.firstWhere(
                              (e) => e.name == value,
                          orElse: () => Category(id: 0, name: ''),
                        );
                        addProductController.categoryId.value = selectedCat.id?.toString() ?? '';
                        productController.searchProductData(selectedCat.id?.toString() ?? '');
                      }
                    },
                    icon: assetSvdImageWidget(image: DefaultImages.dropDownIcn, colorFilter: ColorFilter.mode(secondaryText, BlendMode.srcIn)),
                    isExpanded: true,
                    style: TextStyle(fontSize: 12.sp, color: primaryText),
                    dropdownColor: cardBg,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                );
              }),
              verticalSpace(15.h),
              Text("all_products".tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: primaryText)),
              verticalSpace(10.h),

              // --- قسم القائمة والريفرش ---
              Expanded(
                child: Obx(() {
                  /// حالة التحميل الأولي
                  if (productController.isLoading.value && productController.currantPage.value == 1) {
                    return const Center(child: LoadingWidget());
                  }

                  /// بناء المحتوى القابل للريفرش
                  return RefreshIndicator(
                    onRefresh: () async {
                      // إعادة تعيين الصفحة إلى 1 عند السحب
                      productController.currantPage.value = 1;
                      productController.productList.clear();
                      await getData();
                    },
                    child: ListView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(), // مهم جداً للريفرش
                      children: [
                        /// حالة الخطأ
                        if (productController.errorMessage.isNotEmpty && productController.productList.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: ErrorState(
                                message: productController.errorMessage.value,
                                onRetry: () {
                                  productController.currantPage.value = 1;
                                  getData();
                                },
                              ),
                            ),
                          ),

                        /// حالة الفراغ
                        if (productController.productList.isEmpty && productController.errorMessage.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: EmptyState(
                                message: "no_orders_found".tr,
                                icon: Icons.receipt_long_outlined,
                              ),
                            ),
                          ),

                        /// قائمة المنتجات
                        if (productController.productList.isNotEmpty)
                          ...productController.productList.map((product) {
                            return GestureDetector(
                              onTap: () => Get.to(() => ProductDetailScreen(
                                categoryId: product.categoryId?.toString() ?? "",
                                productId: product.id?.toString() ?? "",
                                id: product.id.toString(),
                              )),
                              child: allProductWidget(
                                index: 0, // لا نحتاج index هنا لأننا نستخدم map
                                image: '${productController.imageBaseUrl.value}${product.coverImagePath ?? ''}',
                                title: product.categoryName ?? "uncategorized".tr,
                                subTitle: product.name ?? "no_name".tr,
                                amount: '\$${product.finalPrice ?? "0"}',
                                initialRating: double.tryParse(product.averageRating?.toString() ?? "0") ?? 0.0,
                                deleteFun: () {
                                  AppDialog.showCustomDialog(
                                    iconColor: AppColor.cRedText,
                                    confirmColor: AppColor.cRedText,
                                    context: context,
                                    onConfirm: () => productController.deleteProductData(productId: product.id?.toString() ?? ""),
                                  );
                                },
                                viewFun: () => Get.to(() => ProductDetailScreen(
                                  categoryId: product.categoryId?.toString() ?? "",
                                  productId: product.id?.toString() ?? "",
                                  id: product.id.toString(),
                                )),
                                changeFun: () => Get.to(() => AddNewProductScreen(
                                  isUpdate: true,
                                  productId: product.id?.toString(),
                                  productName: product.name,
                                  trending: product.trending?.toString(),
                                  qty: product.productStock?.toString(),
                                  disAmountController: product.discountPrice,
                                  priceController: product.originalPrice,
                                  productTax: product.retuenText,
                                  variantName: product.variantAttribute?.toString(),
                                  productCategories: product.categoryName,
                                  productDescription: product.description,
                                ))?.then((_) => getData()),
                              ),
                            );
                          }).toList(),

                        /// مؤشر التحميل السفلي (Pagination)
                        if (productController.isScroll.value && productController.productList.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}