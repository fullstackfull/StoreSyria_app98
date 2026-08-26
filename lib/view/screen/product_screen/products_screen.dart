// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/product_controller/add_product_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/screen/product_screen/add_new_product_screen.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../core/model/create_product_model.dart';
import '../../new_widgets/date_filter.dart';
import '../../new_widgets/header_widget.dart';
import '../../new_widgets/search_widget.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final bool isBack;
  const ProductsScreen({super.key, required this.isBack});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with AutomaticKeepAliveClientMixin {
  final ProductController productController = Get.find<ProductController>();
  final AddProductController addProductController =
  Get.put(AddProductController());
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

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
        productController.imageBaseUrl.value =
            Prefs.getString(AppConstant.imageUrl);
        addProductController.category.value = "";
        addProductController.categoryId.value = "";
        productController.productList.clear();
        getData();
      }
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // The filtered/search endpoint (searchProductData) has no pagination,
    // so we only auto-load more pages for the plain unfiltered list.
    if (!productController.isScroll.value) return;
    if (addProductController.categoryId.value.isNotEmpty) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      productController.currantPage.value += 1;
      productController.getProductData(productController.currantPage.value);
    }
  }

  Future<void> getData() async {
    await productController.getProductData(productController.currantPage.value);

    if (addProductController.categoryTypeList.isEmpty) {
      await addProductController.getCreateProductData(isUpdate: false);

      if (addProductController.categoryTypeList.isNotEmpty) {
        if (addProductController.category.value.isEmpty) {
          addProductController.category.value =
              addProductController.categoryTypeList.first.name ?? "";
          addProductController.categoryId.value =
              addProductController.categoryTypeList.first.id?.toString() ??
                  "";
        }
      }
    }
  }

  Future<void> _fetchInitialData() async {
    productController.currantPage.value = 1;
    productController.isScroll.value = true;
    productController.productList.clear();
    await getData();
  }

  Future<void> _showCategoryFilterBottomSheet() async {
    if (addProductController.categoryTypeList.isEmpty) return;
    final isDark = Get.isDarkMode;
    final cardBg = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final primaryText = isDark ? Colors.white : AppColor.cText;

    final selected = await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            verticalSpace(12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            verticalSpace(16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'filter_by_category'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
              ),
            ),
            verticalSpace(10.h),
            ...addProductController.categoryTypeList.map((cat) {
              final isSelected =
                  addProductController.category.value == cat.name;
              return ListTile(
                title: Text(
                  cat.name ?? '',
                  style: TextStyle(fontSize: 14.sp, color: primaryText),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle,
                    color: AppColor.themeNavyBlueColor)
                    : null,
                onTap: () => Navigator.pop(context, cat),
              );
            }),
            verticalSpace(10.h),
          ],
        );
      },
    );

    if (selected != null) {
      final categoryId = selected.id?.toString() ?? '';

      addProductController.category.value = selected.name ?? '';
      addProductController.categoryId.value = categoryId;

      // searchProductData has no pagination (see repository: it's a plain
      // POST with store_id + category_id), so stop auto-loading more pages.
      productController.isScroll.value = false;
      productController.currantPage.value = 1;

      await productController.searchProductData(categoryId);
    }
  }

  void _clearCategoryFilter() {
    addProductController.category.value = '';
    addProductController.categoryId.value = '';
    productController.isScroll.value = true;
    _fetchInitialData();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark  ? DarkThemeColor.cBackGround : const Color(0xFFF5F6F8),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              HeaderWidget(
                context: context,
                title: "products".tr,
                label: "new_product".tr,
                onNewLabelTap: () => Get.to(() => AddNewProductScreen(isUpdate: false)),
              ),

              verticalSpace(16.h),

              Row(
                children: [
                  Expanded(
                    child: SearchRowWidget(
                      context: context,
                      controller: searchController,
                      hint: 'search'.tr,
                      onChanged: (value) {
                        //ToDO :: api search product
                      },
                    ),
                  ),

                  horizontalSpace(10.w),
                  Obx(() {
                    final hasFilter =
                        addProductController.category.value.isNotEmpty;
                    return GestureDetector(
                      onTap: _showCategoryFilterBottomSheet,
                      child: Container(
                        height: 44.h,
                        width: 44.h,
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkThemeColor.cCardBackground
                              : AppColor.cWhite,
                          borderRadius: BorderRadius.circular(30.r),
                          border: hasFilter
                              ? Border.all(
                              color: AppColor.themeNavyBlueColor,
                              width: 1.2)
                              : null,
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: hasFilter
                              ? AppColor.themeNavyBlueColor
                              : (isDark
                              ? Colors.grey.shade400
                              : AppColor.cFont),
                        ),
                      ),
                    );
                  }),
                ],
              ),

              verticalSpace(24.h),

              Expanded(
                child: Obx(() {
                  if (productController.isLoading.value &&
                      productController.currantPage.value == 1) {
                    return const Center(
                      child: LoadingWidget(),
                    );
                  }

                  if (productController.errorMessage.isNotEmpty &&
                      productController.productList.isEmpty) {
                    return RefreshIndicator(
                      backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
                      onRefresh: _fetchInitialData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .6,
                            child: Center(
                              child: ErrorState(
                                message: productController.errorMessage.value,
                                onRetry: _fetchInitialData,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (productController.productList.isEmpty) {
                    return RefreshIndicator(
                      backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
                      onRefresh: _fetchInitialData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .6,
                            child: Center(
                              child: EmptyState(
                                message: "no_products_found".tr,
                                icon: Icons.production_quantity_limits,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
                    onRefresh: _fetchInitialData,
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15.h),
                            child: sectionHeaderWithFilterWidget(
                              isFilter: false,
                              num: addProductController.categoryId.value.isNotEmpty
                                  ? productController.productList.length
                                  : (productController.productModel?.data?.total ?? 0),
                              context: context,
                              title: "all_products".tr,
                              filterLabel:
                              addProductController.category.value.isNotEmpty
                                  ? addProductController.category.value
                                  : "filter_by_category".tr,
                              onFilterTap:
                              addProductController.category.value.isNotEmpty
                                  ? _clearCategoryFilter
                                  : _showCategoryFilterBottomSheet,
                            ),
                          ),
                        ),

                        // Products Grid
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final product =
                                productController.productList[index];

                                return allProductsListItemWidget(
                                  productId: product.id.toString(),
                                  trackStock: product.trackStock == 1,
                                  status: product.status!,
                                  context: context,
                                  imageUrl: product.coverImageUrl ?? '',
                                  categoryName: product.categoryName ?? '',
                                  productName: product.name ?? '',
                                  price: product.price?.toString() ?? '0',

                                  salePrice:
                                  (product.salePrice != null &&
                                      product.salePrice != product.price)
                                      ? product.salePrice.toString()
                                      : null,

                                  stock: product.productStock?.toString() ?? '-',

                                  stockStatus: product.stockStatus,

                                  rating: product.averageRating?.toDouble() ?? 0.0,

                                  hasVariant: product.variantProduct == 1,

                                  onTap: () => Get.to(
                                        () => ProductDetailScreen(
                                      product: product,
                                      categoryId: product.categoryId?.toString() ?? '',
                                      productId: product.id?.toString() ?? '',
                                      id: product.id.toString(),
                                    ),
                                  ),

                                  viewFun: () => Get.to(
                                        () => ProductDetailScreen(
                                      product: product,
                                      categoryId: product.categoryId?.toString() ?? '',
                                      productId: product.id?.toString() ?? '',
                                      id: product.id.toString(),
                                    ),
                                  ),

                                  showChangeAction: true,

                                  changeFun: () => Get.to(
                                        () => AddNewProductScreen(
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
                                    ),
                                  )?.then((_) => getData()),

                                  deleteFun: () {
                                    AppDialog.showCustomDialog(
                                      context: context,
                                      title: 'delete'.tr,
                                      message: 'deleteProduct'.tr,
                                      lottieAsset: 'assets/lottie/delete_icon.json',
                                      confirmColor: Colors.red,
                                      onConfirm: () async {
                                        await productController.deleteProductData(
                                          productId: product.id.toString(),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              childCount: productController.productList.length,
                            ),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220.w,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                              mainAxisExtent: 255.h,
                            ),
                          ),
                        ),


                        if (productController.isScroll.value)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.themeNavyBlueColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}