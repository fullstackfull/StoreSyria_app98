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
import '../../../core/model/create_product_model.dart';
import '../../new_widgets/date_filter.dart';
import '../../new_widgets/search_widget.dart';
import '../../new_widgets/shimmer.dart';
import '../../widget/common_appbar_widget.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final bool isBack;
  const ProductsScreen({super.key, required this.isBack});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with AutomaticKeepAliveClientMixin {
  final ProductController productController = Get.find<ProductController>();
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
        productController.imageBaseUrl.value =
            Prefs.getString(AppConstant.imageUrl);
        addProductController.category.value = '';
        addProductController.categoryId.value = '';

        productController.filterCategory.value = '';
        productController.filterCategoryId.value = '';

        productController.errorMessage.value = '';

        getData();
      }
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (productController.listMode.value != ProductListMode.normal) {
      return;
    }

    if (!productController.isScroll.value) return;
    if (productController.isLoading.value) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      productController.currantPage.value += 1;

      productController.getProductData(
        productController.currantPage.value,
      );
    }
  }

  Future<void> getData() async {
    await productController.getProductData(1);

    if (addProductController.categoryTypeList.isEmpty) {
      await addProductController.getCreateProductData(
        isUpdate: false,
      );
    }
  }

  Future<void> _fetchInitialData() async {
    final mode = productController.listMode.value;
    final searchQuery = productController.searchQuery.value.trim();
    final categoryId = productController.filterCategoryId.value;

    productController.errorMessage.value = '';
    productController.currantPage.value = 1;

    if (mode == ProductListMode.search &&
        searchQuery.isNotEmpty) {
      productController.isScroll.value = false;

      await productController.searchProductName(searchQuery);
      return;
    }

    if (mode == ProductListMode.category &&
        categoryId.isNotEmpty) {
      productController.isScroll.value = false;
      productController.productList.clear();

      await productController.searchProductData(categoryId);
      return;
    }

    productController.listMode.value = ProductListMode.normal;
    productController.searchQuery.value = '';
    productController.isScroll.value = true;
    productController.productList.clear();

    await productController.getProductData(1);
  }

  Future<void> _showCategoryFilterBottomSheet() async {
    if (addProductController.categoryTypeList.isEmpty) return;

        final isDark = Theme.of(context).brightness == Brightness.dark;;

    final cardBg =
    isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;

    final backgroundColor =
    isDark ? DarkThemeColor.cBackGround : const Color(0xFFF5F6F8);

    final primaryText =
    isDark ? Colors.white : AppColor.cText;

    final secondaryText =
    isDark ? Colors.grey.shade400 : AppColor.cFont;

    final borderColor =
    isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

    String selectedCategoryId =
        productController.filterCategoryId.value;

    final selected = await showModalBottomSheet<Category?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.78,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    verticalSpace(10.h),

                    Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),

                    verticalSpace(18.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              color: AppColor.themeNavyBlueColor
                                  .withValues(alpha: .10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.filter_list_rounded,
                              color: AppColor.themeNavyBlueColor,
                              size: 22.sp,
                            ),
                          ),

                          horizontalSpace(12.w),

                          Expanded(
                            child: Text(
                              'filter_by_category'.tr,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              selectedCategoryId = '';

                              addProductController.category.value = '';
                              addProductController.categoryId.value = '';

                              productController.filterCategory.value = '';
                              productController.filterCategoryId.value = '';

                              productController.searchQuery.value = '';
                              productController.listMode.value = ProductListMode.normal;

                              productController.currantPage.value = 1;
                              productController.isScroll.value = true;

                              productController.searchResults.clear();
                              productController.categoryResults.clear();
                              productController.searchTotal.value = 0;
                              productController.searchController.clear();

                              productController.errorMessage.value = '';

                              Navigator.pop(sheetContext);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'reset'.tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.themeNavyBlueColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    verticalSpace(16.h),

                    Divider(
                      height: 1,
                      color: borderColor.withValues(alpha: .6),
                    ),

                    verticalSpace(8.h),

                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          8.h,
                          16.w,
                          20.h,
                        ),
                        itemCount:
                        addProductController.categoryTypeList.length,
                        separatorBuilder: (_, __) =>
                            verticalSpace(8.h),
                        itemBuilder: (context, index) {
                          final cat =
                          addProductController.categoryTypeList[index];

                          final categoryId =
                              cat.id?.toString() ?? '';

                          final isSelected =
                              selectedCategoryId == categoryId;

                          return InkWell(
                            borderRadius:
                            BorderRadius.circular(14.r),
                            onTap: () {
                              selectedCategoryId = categoryId;

                              setModalState(() {});

                              Navigator.pop(
                                sheetContext,
                                cat,
                              );
                            },
                            child: AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 180),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 13.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColor.themeNavyBlueColor
                                    .withValues(alpha: .08)
                                    : cardBg,
                                borderRadius:
                                BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.themeNavyBlueColor
                                      : borderColor,
                                  width: isSelected ? 1.3 : 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38.w,
                                    height: 38.w,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColor.themeNavyBlueColor
                                          .withValues(alpha: .12)
                                          : (isDark
                                          ? Colors.white.withValues(alpha: .05)
                                          : Colors.grey.withValues(alpha: .08)),
                                      borderRadius:
                                      BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.category_outlined,
                                      size: 19.sp,
                                      color: isSelected
                                          ? AppColor.themeNavyBlueColor
                                          : secondaryText,
                                    ),
                                  ),

                                  horizontalSpace(12.w),

                                  Expanded(
                                    child: Text(
                                      cat.name ?? '',
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: primaryText,
                                      ),
                                    ),
                                  ),

                                  AnimatedSwitcher(
                                    duration:
                                    const Duration(milliseconds: 180),
                                    child: isSelected
                                        ? Container(
                                      key: const ValueKey('selected'),
                                      width: 26.w,
                                      height: 26.w,
                                      decoration: BoxDecoration(
                                        color: AppColor
                                            .themeNavyBlueColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 17.sp,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Container(
                                      key: const ValueKey('unselected'),
                                      width: 26.w,
                                      height: 26.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      final categoryId = selected.id?.toString() ?? '';

      addProductController.category.value =
          selected.name ?? '';

      addProductController.categoryId.value =
          categoryId;

      productController.filterCategory.value =
          selected.name ?? '';

      productController.filterCategoryId.value =
          categoryId;

      productController.isScroll.value = false;
      productController.currantPage.value = 1;
      productController.searchController.clear();
      productController.searchQuery.value = '';

      productController.searchResults.clear();
      productController.searchTotal.value = 0;

      productController.errorMessage.value = '';

      productController.isLoading.value = true;
      try {
        await productController.searchProductData(
          categoryId,
        );
      } finally {
        productController.isLoading.value = false;
      }
    }
  }

  Future<void> _clearCategoryFilter() async {
    addProductController.category.value = '';
    addProductController.categoryId.value = '';

    productController.filterCategory.value = '';
    productController.filterCategoryId.value = '';

    productController.searchQuery.value = '';
    productController.searchController.clear();

    productController.searchResults.clear();
    productController.searchTotal.value = 0;

    productController.listMode.value = ProductListMode.normal;
    productController.currantPage.value = 1;
    productController.isScroll.value = true;

    productController.productList.clear();

    await _fetchInitialData();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar:  simpleAppBar(
          isBold: true,
          title: "products".tr,
          label: "new_product".tr,
          onNewLabelTap: () => Get.to(
                  () => const AddNewProductScreen(isUpdate: false)),
        ),
        backgroundColor: isDark  ? DarkThemeColor.cBackGround : AppColor.cLight,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchRowWidget(
                      context: context,
                      controller: productController.searchController,
                      hint: 'search'.tr,
                      onChanged: productController.onProductSearchChanged,
                      onClear: () {
                        productController.clearSearch();
                      },
                    ),
                  ),

                  horizontalSpace(10.w),
                  Obx(() {

                    final hasFilter =
                        productController.filterCategoryId.value.isNotEmpty;
                    return GestureDetector(
                      onTap: _showCategoryFilterBottomSheet,
                      child: Container(
                        height: 44.h,
                        width: 44.h,
                        decoration: BoxDecoration(
                          color: hasFilter
                              ? AppColor.themeNavyBlueColor
                              : (isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite),
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color: hasFilter
                                ? AppColor.themeNavyBlueColor
                                : (isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withValues(alpha: .5)),
                          ),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: hasFilter
                              ? AppColor.cWhite
                              : (isDark ? Colors.grey.shade400 : AppColor.cFont),
                        ),
                      ),
                    );
                  }),
                ],
              ),

              verticalSpace(24.h),

              Expanded(
                child: Obx(() {
                  final products =
                  productController.listMode.value == ProductListMode.search
                      ? productController.searchResults
                      : productController.listMode.value == ProductListMode.category
                      ? productController.categoryResults
                      : productController.productList;

                  if (productController.isDataAvailable2.value) {
                    return const ShimmerList(
                      leading: ShimmerLeading.square,
                      lines: 3,
                    );
                  }

                  if (productController.isLoading.value &&
                      productController.currantPage.value == 1) {
                    return const ShimmerGrid();
                  }

                  if (productController.errorMessage.isNotEmpty &&
                      products.isEmpty) {
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

                  if (products.isEmpty) {
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
                              num: productController.listMode.value == ProductListMode.search
                                  ? productController.searchTotal.value
                                  : productController.filterCategoryId.value.isNotEmpty
                                  ? productController.productList.length
                                  : (productController.productModel?.data?.total ?? 0),
                              context: context,
                              title: "all_products".tr,
                              filterLabel:
                              productController.filterCategoryId.value.isNotEmpty
                                  ? addProductController.category.value
                                  : "filter_by_category".tr,
                              onFilterTap:
                              productController.filterCategoryId.value.isNotEmpty
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
                                final product = products[index];

                                return allProductsListItemWidget(
                                  productId: product.id.toString(),
                                  trackStock: product.trackStock == 1,
                                  status: product.status ?? 0,
                                  context: context,
                                  imageUrl: product.coverImageUrl ?? '',
                                  categoryName: product.categoryName ?? '',
                                  productName: product.name ?? '',
                                  price: "${product.salePrice?.toString() ?? ""}  ${productController.currencySymbol.value}",
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
                                      status: product.status,
                                      productId: product.id?.toString(),
                                      productName: product.name,
                                      costPrice: product.costPrice,
                                      trending: product.trending?.toString(),
                                      qty: product.productStock?.toString(),
                                      productTax: product.retuenText,
                                      variantName: product.variantAttribute?.toString(),
                                      productCategories: product.categoryName,
                                      categoryId: product.categoryId?.toString(),
                                      discountType: product.discountType,
                                      coverImageUrl: product.coverImageUrl,
                                      //subImageUrls: product.subImages,
                                      price: product.price,
                                      salePrice: product.salePrice,
                                      productDescription: product.description,
                                    ),
                                  ),
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
                              childCount: products.length,                            ),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220.w,
                              crossAxisSpacing: 14.w,
                              mainAxisSpacing: 16.h,
                              mainAxisExtent: 290.h,
                            ),
                          ),
                        ),


                        if (productController.listMode.value ==
                            ProductListMode.normal &&
                            productController.isScroll.value)                          SliverToBoxAdapter(
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
