// ignore_for_file: avoid_print
import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class CategoryRepository {
  getCategoriesData(int page) async {
    String endPoint = "${API.categoryListUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page";
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  deleteCategoriesData({
    required int categoryId,
  }) async {
    String endPoint = API.deleteCategoryUrl +
        API.storeIdUrl +
        Prefs.getStoreID() +
        API.categoryIdUrl +
        categoryId.toString();
    var response = await NetworkHttps.deleteRequest(endPoint);
    return response;
  }
}
