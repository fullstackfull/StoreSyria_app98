import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/core/model/product_model.dart';
import '../widget/common_snak_bar_widget.dart';
import 'network_image_widget.dart';

class ProductPickerBottomSheet extends StatefulWidget {
  const ProductPickerBottomSheet({super.key});

  static Future<ProductData?> show(BuildContext context) async {
    final result = await showModalBottomSheet<ProductData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProductPickerBottomSheet(),
    );

    final controller = Get.find<ProductController>();

    if (!controller.isClosed) {
      controller.resetProductPickerState();
    }

    return result;
  }


  @override
  State<ProductPickerBottomSheet> createState() =>
      _ProductPickerBottomSheetState();
}

class _ProductPickerBottomSheetState extends State<ProductPickerBottomSheet> {
  final ProductController productController = Get.find<ProductController>();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  static const Color navyBlue = Color(0xFF172C4E);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isSearchMode =>
      productController.listMode.value == ProductListMode.search;

  @override
  void initState() {
    super.initState();

    if (productController.productList.isEmpty &&
        productController.listMode.value == ProductListMode.normal) {
      productController.getProductData(1);
    }

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (isSearchMode) return;
    if (!productController.isScroll.value) return;
    if (productController.isLoading.value) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      productController.getProductData(
          productController.currantPage.value + 1);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final query = value.trim();
      if (query.isEmpty) {
        await productController.clearSearch();
      } else if (query.length >= 3) {
        await productController.searchProductName(query);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? const Color(0xFF101820) : Colors.white;
    final textColor = isDark ? Colors.white : navyBlue;
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF687386);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6EC);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, dragController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'select_product'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: secondaryTextColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'search_product_hint'.tr,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(() {
                        final loading = productController.isDataAvailable2.value;
                        if (loading) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (searchController.text.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () async {
                              searchController.clear();
                              await productController.clearSearch();
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      filled: true,
                      fillColor:
                      isDark ? const Color(0xFF182331) : const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: navyBlue, width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    final list = productController.productList;
                    final searching = isSearchMode;

                    final loadingFirstPage = searching
                        ? (productController.isDataAvailable2.value &&
                        list.isEmpty)
                        : (productController.isLoading.value && list.isEmpty);

                    if (loadingFirstPage) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'no_products_found'.tr,
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      );
                    }

                    final showLoader =
                        !searching && productController.isScroll.value;

                    return ListView.separated(
                      controller: scrollController,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: list.length + (showLoader ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: borderColor),
                      itemBuilder: (context, index) {
                        if (index >= list.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }

                        final product = list[index];

                        final int stock = product.trackStock ?? 0;
                        final bool inStock = stock > 0;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: productNetworkImage(
                              imageUrl: product.coverImageUrl ?? '',
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              backgroundColor:
                              navyBlue.withOpacity(isDark ? 0.25 : 0.08),
                              iconColor: isDark
                                  ? Colors.white70
                                  : navyBlue,
                              loadingColor: navyBlue,
                            ),
                          ),
                          title: Text(
                            product.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          subtitle: Padding( padding: const EdgeInsets.only(top: 5), child: Align( alignment: Alignment.centerLeft, child: Container( padding: const EdgeInsets.symmetric( horizontal: 7, vertical: 3, ), decoration: BoxDecoration( color: inStock ? Colors.green.withOpacity(.10) : Colors.red.withOpacity(.10), borderRadius: BorderRadius.circular(6), border: Border.all( color: inStock ? Colors.green.withOpacity(.20) : Colors.red.withOpacity(.20), ), ), child: Text( inStock ? '${'in_stock'.tr} ($stock)' : 'out_of_stock'.tr, style: TextStyle( fontSize: 9, fontWeight: FontWeight.w700, color: inStock ? Colors.green[700] : Colors.red, ), ), ), ), ),
                          onTap: inStock
                              ? () => Navigator.of(context).pop(product)
                              : () => commonToast(type: AppSnackBarType.warning,'this_product_is_out_of_stock'.tr),
                          enabled: true,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}