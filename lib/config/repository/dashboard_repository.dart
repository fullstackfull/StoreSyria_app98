// ignore_for_file: avoid_print

import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/network_dio/network_dio.dart';

class DashboardRepository {
  getImageBaseData() async {
    var response = await NetworkHttps.getRequest(API.imageBaseUrl);
    return response;
  }

  getDashBoardData() async {
    var response = await NetworkHttps.postRequest(API.dashboardUrl, {});
    return response;
  }

  setStoreIdData({required String storeId}) async {
    var response = await NetworkHttps.postRequest(API.changeStoreUrl, {'store_id': storeId});
    return response;
  }
}
