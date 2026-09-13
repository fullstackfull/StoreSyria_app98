import 'dart:io';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';

enum ProductListMode {
  normal,
  search,
  category,
}

class ProductController extends GetxController implements StoreAware {
  static const String _cacheProductKey = 'home_product_list_data';

  ProductRepository productRepository = ProductRepository();

  ProductModel? productModel;
  RxString filterCategory = ''.obs;
  RxString filterCategoryId = ''.obs;
  final RxInt searchTotal = 0.obs;

  Rx<ProductListMode> listMode = ProductListMode.normal.obs;
  RxString searchQuery = ''.obs;

  RxList<ProductData> productList = <ProductData>[].obs;

  List<File> selectedSubImages = [];

  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isDataAvailable = false.obs;
  RxBool isDataAvailable2 = false.obs;
  RxBool isLoading = false.obs;
  RxString imageBaseUrl = ''.obs;
  RxString errorMessage = ''.obs;


  @override
  void onInit() {
    super.onInit();
    _loadCachedProducts();

    StoreChangeService.instance.register(() => this);
  }

  void _loadCachedProducts() {
    final cached = CacheService.get<Map<String, dynamic>>(_cacheProductKey);
    if (cached == null) return;
    try {
      productModel = ProductModel.fromJson(cached);
      productList.value = productModel?.data?.data ?? [];

      isScroll.value =
          productModel?.data?.currentPage != productModel?.data?.lastPage;
    } catch (_) {
      productModel = null;
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
    Loader.showLoader();

    final response = await productRepository.getProductData(page);

    Loader.hideLoader();
    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          productModel = ProductModel.fromJson(data);

          if (page == 1) {
            productList.clear();
            CacheService.save(_cacheProductKey, data);
          }

          productList.addAll(productModel?.data?.data ?? []);

          isScroll.value = page != productModel?.data?.lastPage;
        } else {
          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
          if (currantPage.value == page) {
            currantPage.value -= 1;
          }
        }
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);

        if (currantPage.value == page) {
          currantPage.value -= 1;
        }
      },
    );
  }

  Future<void> searchProductData(String categoryId) async {
    listMode.value = ProductListMode.category;

    searchQuery.value = '';

    isScroll.value = false;

    productList.clear();

    isDataAvailable.value = true;

    final response = await productRepository.searchProductByCategory(
      categoryId: categoryId,
    );

    isDataAvailable.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          final List products = data['data'] ?? [];

          productList.assignAll(
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

  Future<void> searchProductName(String name) async {
    if (name.trim().length < 3) return;

    listMode.value = ProductListMode.search;
    searchQuery.value = name.trim();

    filterCategory.value = '';
    filterCategoryId.value = '';

    isScroll.value = false;

    productList.clear();
    errorMessage.value = '';

    isDataAvailable2.value = true;

    final response = await productRepository.searchProductByName(
      name.trim(),
    );

    isDataAvailable2.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          searchTotal.value = data['data']?['total'] ?? 0;

          final List products = data['data']?['data'] ?? [];

          productList.assignAll(
            products
                .map((e) => ProductData.fromJson(e))
                .toList(),
          );
        } else {
          searchTotal.value = 0;

          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
        }
      },
      onFailure: (reason, message, validationErrors) {
        searchTotal.value = 0;
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
  Future<void> clearSearch() async {
    searchQuery.value = '';

    listMode.value = ProductListMode.normal;

    filterCategory.value = '';
    filterCategoryId.value = '';

    searchTotal.value = 0;

    currantPage.value = 1;
    isScroll.value = true;

    productList.clear();

    errorMessage.value = '';
    isDataAvailable2.value = false;

    await getProductData(1);
  }
}
