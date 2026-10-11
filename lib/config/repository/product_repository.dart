// ignore_for_file: avoid_print

import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class ProductRepository {
  Future<Result<Map<String, dynamic>>> getProductData(int page) async {
    String endPoint =
        "${API.productListUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page";
    return await NetworkHttps.getRequest(endPoint);
  }

  Future<Result<Map<String, dynamic>>> searchProductByName(String name) async {
    String endPoint =
        "${API.searchProductUrl}${API.storeIdUrl}${Prefs.getStoreID()}";
    final data = {"name" : name};
    return await NetworkHttps.postRequest(endPoint,data);
  }

  Future<Result<Map<String, dynamic>>> getCreateProductData() async {
    String endPoint =
        API.createProductUrl + API.storeIdUrl + Prefs.getStoreID();
    return await NetworkHttps.getRequest(endPoint);
  }

  Future<Result<Map<String, dynamic>>> getProductDetailData(
      String productId) async {
    String endPoint = API.viewProductUrl +
        API.storeIdUrl +
        Prefs.getStoreID() +
        API.productIdUrl +
        productId;

    return await NetworkHttps.getRequest(endPoint);
  }

  Future<Result<Map<String, dynamic>>> deleteProductData(
      String productId) async {
    String endPoint = API.deleteProductListUrl +
        API.storeIdUrl +
        Prefs.getStoreID() +
        API.productIdUrl +
        productId;

    return await NetworkHttps.deleteRequest(endPoint);
  }

  Future<Result<Map<String, dynamic>>> searchProductByCategory({
    required String categoryId,
  }) async {
    return await NetworkHttps.postRequest(
      API.searchProductListUrl,
      {
        'store_id': Prefs.getStoreID(),
        'category_id': categoryId,
      },
    );
  }

  Future<Result<Map<String, dynamic>>> addProduct({
    required bool isUpdate,
    required Map<String, String> fields,
    required Map<String, String> files,
    required List<String> multiFiles,
  }) async {
    return await NetworkHttps.multipartRequest(
      endPoint: isUpdate
          ? API.updateProductUrl
          : API.addProductUrl,
      fields: fields,
      files: files,
      multiFiles: multiFiles,
      multiFileKey: 'product_image[]',
    );
  }
}