import 'dart:io';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/config/repository/product_repository.dart';

class ProductController extends GetxController {
  ProductRepository productRepository = ProductRepository();

  ProductModel? productModel;

  RxList<ProductData> productList = <ProductData>[].obs;

  List<File> selectedSubImages = [];

  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isDataAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxString imageBaseUrl = ''.obs;
  RxString errorMessage = ''.obs;

  Future<void> getProductData(int page) async {
    isLoading.value = true;
    Loader.showLoader();

    final response = await productRepository.getProductData(page);

    Loader.hideLoader();

    response.fold(
      onSuccess: (data) {
        isLoading.value = false;
        if (data['status'] == 1) {
          productModel = ProductModel.fromJson(data);

          if (page == 1) {
            productList.clear();
          }

          productList.addAll(productModel?.data?.data ?? []);

          isScroll.value =
              currantPage.value != productModel?.data?.lastPage;
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

  Future<void> searchProductData(String categoryId) async {
    isDataAvailable.value = true;

    final response = await productRepository.searchProductData(
      categoryId: categoryId,
    );

    isDataAvailable.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          productList.clear();

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
}