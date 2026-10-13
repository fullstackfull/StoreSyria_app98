import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/network/network.dart';

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
