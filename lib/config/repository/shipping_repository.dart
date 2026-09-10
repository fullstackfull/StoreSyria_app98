// ignore_for_file: avoid_print

import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class ShippingRepository {
  getShippingData(int page) async {
    String endPoint = "${API.shippingListUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page";
    var response = await NetworkHttps.getRequest(endPoint);
    print("response==========>$response");
    return response;
  }

  addShippingData({
    required bool isUpdate,
    required String shippingId,
    required String name,
    required String description,
  }) async {
    final endPoint = isUpdate
        ? API.updateShippingUrl
        : API.addShippingUrl;

    final fields = isUpdate
        ? {
      'store_id': Prefs.getStoreID(),
      'shipping_id': shippingId,
      'name': name,
      'description': description,
    }
        : {
      'store_id': Prefs.getStoreID(),
      'name': name,
      'description': description,
    };

    var response =  await NetworkHttps.postRequest(
      endPoint,
      fields,
    );
    print("response==========>$response");
    return response;
  }

  deleteShippingData(String shippingId) async {
    String endPoint = API.deleteShippingUrl +
        API.storeIdUrl +
        Prefs.getStoreID() +
        API.shippingIdUrl +
        shippingId;
    var response = await NetworkHttps.deleteRequest(endPoint);
    print("response==========>$response");
    return response;
  }
}
