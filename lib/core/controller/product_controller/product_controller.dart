import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';
import '../../../network_dio/result.dart';

enum ProductListMode {
  normal,
  search,
  category,
}

class ProductController extends GetxController implements StoreAware {
  static const String _cacheProductKey = 'home_product_list_data';

  ProductRepository productRepository = ProductRepository();
  final RxList<ProductData> categoryResults = <ProductData>[].obs;
  RxString currencySymbol = ''.obs;

  ProductModel? productModel;
  RxString filterCategory = ''.obs;
  RxString filterCategoryId = ''.obs;
  final RxInt searchTotal = 0.obs;

  Rx<ProductListMode> listMode = ProductListMode.normal.obs;
  RxString searchQuery = ''.obs;

  RxList<ProductData> productList = <ProductData>[].obs;
  final TextEditingController searchController = TextEditingController();

  List<File> selectedSubImages = [];

  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isDataAvailable = false.obs;
  RxBool isDataAvailable2 = false.obs;
  RxBool isLoading = false.obs;
  RxString imageBaseUrl = ''.obs;
  RxString errorMessage = ''.obs;
  final RxList<ProductData> searchResults = <ProductData>[].obs;
  Timer? _productSearchDebounce;


  @override
  void onInit() {
    super.onInit();
    _loadCachedProducts();

    StoreChangeService.instance.register(() => this);
  }

  void _loadCachedProducts() {
    final cached =
    CacheService.get<Map<String, dynamic>>(_cacheProductKey);

    if (cached == null) return;

    try {
      productModel = ProductModel.fromJson(cached);

      currencySymbol.value =
          productModel?.data?.currencySymbol ?? '';

      productList.value =
          productModel?.data?.data ?? [];

      isScroll.value =
          productModel?.data?.currentPage !=
              productModel?.data?.lastPage;
    } catch (_) {
      productModel = null;
      currencySymbol.value = '';
    }
  }

  @override
  void resetForStoreChange() {
    productModel = null;
    productList.clear();

    listMode.value = ProductListMode.normal;
    searchQuery.value = '';

    filterCategory.value = '';
    filterCategoryId.value = '';

    currantPage.value = 1;
    isScroll.value = true;

    CacheService.clear(_cacheProductKey);

    getProductData(1);
  }

  Future<void> getProductData(int page) async {
    if (listMode.value != ProductListMode.normal) {
      return;
    }

    if (isLoading.value) return;

    isLoading.value = true;

    if (page == 1) {
      Loader.showLoader();
    }

    try {
      final response = await productRepository.getProductData(page);

      response.fold(
        onSuccess: (data) {
          if (data['status'] == 1) {
            productModel = ProductModel.fromJson(data);

            currencySymbol.value =
                productModel?.data?.currencySymbol ?? '';

            final newProducts =
                productModel?.data?.data ?? <ProductData>[];

            if (page == 1) {
              productList.clear();
              CacheService.save(_cacheProductKey, data);
            }

            productList.addAll(newProducts);

            currantPage.value = page;

            final lastPage = productModel?.data?.lastPage ?? page;

            isScroll.value = page < lastPage;
          } else {
            commonToast(
              data['data']?['message'] ??
                  data['message'] ??
                  'Error',
            );

            if (page > 1 && currantPage.value == page) {
              currantPage.value = page - 1;
            }
          }
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value = message;

          commonToast(message);

          if (page > 1 && currantPage.value == page) {
            currantPage.value = page - 1;
          }
        },
      );
    } finally {
      if (page == 1) {
      }

      isLoading.value = false;
    }
  }

  Future<void> searchProductData(String categoryId) async {
    listMode.value = ProductListMode.category;

    searchQuery.value = '';
    isScroll.value = false;

    categoryResults.clear();

    isDataAvailable.value = true;

    final response = await productRepository.searchProductByCategory(
      categoryId: categoryId,
    );

    isDataAvailable.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          final List products = data['data'] ?? [];

          categoryResults.assignAll(
            products
                .map((e) => ProductData.fromJson(e))
                .toList(),
          );
        } else {
          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
        }
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);
      },
    );
  }

  void onProductSearchChanged(String value) {
    _productSearchDebounce?.cancel();

    final query = value.trim();

    if (query.length < 3) {
      if (query.isEmpty &&
          listMode.value == ProductListMode.search) {
        clearSearch();
      }

      return;
    }

    _productSearchDebounce = Timer(
      const Duration(milliseconds: 600),
          () {
        searchProductName(query);
      },
    );
  }

  Future<void> searchProductName(String name) async {
    if (name.trim().length < 3) return;

    listMode.value = ProductListMode.search;
    searchQuery.value = name.trim();

    filterCategory.value = '';
    filterCategoryId.value = '';

    isScroll.value = false;

    searchResults.clear();
    errorMessage.value = '';
    isDataAvailable2.value = true;

    final response =
    await productRepository.searchProductByName(name.trim());

    isDataAvailable2.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          searchTotal.value = data['data']?['total'] ?? 0;

          final List products =
              data['data']?['data'] ?? [];

          searchResults.assignAll(
            products
                .map((e) => ProductData.fromJson(e))
                .toList(),
          );

          errorMessage.value = '';
        } else {
          searchTotal.value = 0;
          searchResults.clear();
          errorMessage.value = '';
        }
      },
      onFailure: (reason, message, validationErrors) {
        searchTotal.value = 0;
        searchResults.clear();
        isScroll.value = false;

        if (reason == FailureReason.notFound) {
          errorMessage.value = '';
          return;
        }

        errorMessage.value = message;
        commonToast(message);
      },
    );
  }

  Future<void> deleteProductData({
    required String productId,
  }) async {
    //Loader.showLoader();

    final response =
    await productRepository.deleteProductData(productId);


    //Loader.hideLoader();

    response.fold(
      onSuccess: (data) async {
        commonToast(
          data['data']?['message'] ??
              data['message'] ??
              'Deleted',
        );

        productList.clear();
        currantPage.value = 1;

        await getProductData(1);
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);
      },
    );
  }

  void resetProductPickerState() {
    if (isClosed) return;

    searchQuery.value = '';
    listMode.value = ProductListMode.normal;

    filterCategory.value = '';
    filterCategoryId.value = '';

    searchTotal.value = 0;

    errorMessage.value = '';
    isDataAvailable2.value = false;

    currantPage.value = 1;
    isScroll.value = true;
  }


  void clearSearch() {
    _productSearchDebounce?.cancel();

    searchController.clear();

    searchQuery.value = '';
    listMode.value = ProductListMode.normal;

    filterCategory.value = '';
    filterCategoryId.value = '';

    searchTotal.value = 0;
    searchResults.clear();

    errorMessage.value = '';
    isDataAvailable2.value = false;

    currantPage.value = 1;
    isScroll.value = true;
  }

  @override
  void onClose() {
    _productSearchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
