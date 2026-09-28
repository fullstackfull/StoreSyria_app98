import 'dart:io';
import '../../network_dio/network_dio.dart';
import '../../utils/base_api.dart';
import '../../utils/prefer.dart';

class DeliveryBoyRepository {

  Future<dynamic> getDeliveryBoysData() async {
    String endPoint = '${API.deliveryBoysUrl}${API.storeIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  Future<dynamic> addDeliveryBoyData({
    required Map<String, String> fields,
    Map<String, String>? files,
  }) async {
    String endPoint = '${API.addDeliveryBoyUrl}${API.storeIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.multipartRequest(
      endPoint: endPoint,
      fields: fields,
      files: files,
    );

    return response;
  }

  Future<dynamic> updateDeliveryBoyData({
    required Map<String, dynamic> data,
    required String deliveryBoyId,
  }) async {
    String endPoint = '${API.updateDeliveryBoyUrl}${API.deliveryBoyIdUrl}$deliveryBoyId${API.storeIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.putRequest(
      endPoint,
      data,
    );

    return response;
  }

  Future<dynamic> updatePassDeliveryBoyData({
    required Map<String, dynamic> data,
    required String deliveryBoyId,
  }) async {
    String endPoint = '${API.updatePassDeliveryBoyUrl}${API.deliveryBoyIdUrl}$deliveryBoyId${API.storeIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.postRequest(
      endPoint,
      data,
    );

    return response;
  }

  Future<dynamic> deleteDeliveryBoyData({
    required String deliveryBoyId,
  }) async {
    String endPoint = '${API.deleteDeliveryBoyUrl}${API.deliveryBoyIdUrl}$deliveryBoyId${API.storeIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.deleteRequest(endPoint);

    return response;
  }
}
