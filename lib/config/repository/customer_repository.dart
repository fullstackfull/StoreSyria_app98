import '../../network_dio/network_dio.dart';
import '../../utils/base_api.dart';
import '../../utils/prefer.dart';

class CustomerRepository {

  Future<dynamic> getCustomersData(int page) async {
    String endPoint = '${API.customersUrl}${API.pageUrl}$page';

    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  Future<dynamic> getStatesData() async {
    String endPoint = '${API.getStatesUrl}?country_id=215';

    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  Future<dynamic> addCustomerData({
    required Map<String, dynamic> data,
  }) async {
    String endPoint = '${API.addCustomerUrl}${API.storeIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.postRequest(
      endPoint,
      data,
    );

    return response;
  }

  Future<dynamic> deleteCustomerData({
    required String customerId,
  }) async {
    String endPoint = '${API.deleteCustomerUrl}${API.customerIdUrl}${customerId}${API.andStoreIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.deleteRequest(endPoint);

    return response;
  }

  Future<dynamic> getCustomerOrdersData({
    required String customerId,
    required int page,
  }) async {
    String endPoint =
        '${API.customerOrdersUrl}?id=$customerId${API.andStoreIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page';

    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }
}