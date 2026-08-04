// ignore_for_file: avoid_print

import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class SettingRepository {
  saveEmailSettingData({required Map data}) async {
    String endPoint = API.emailSettingUrl;
    var response = await NetworkHttps.postRequest(endPoint, data);
    print("response====>$response");
    return response;
  }

  getEmailSettingData() async {
    String endPoint = API.getEmailSettingUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    print("response====>$response");
    return response;
  }

  setTestMailData({required String email}) async {
    String endPoint = API.testMailUrl;
    var response = await NetworkHttps.postRequest(endPoint, {'store_id': Prefs.getStoreID(), 'email': email});
    print("response====>$response");
    return response;
  }

  deleteStoreData() async {
    String endPoint = API.deleteStoreUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.deleteRequest(endPoint);
    print("response====>$response");
    return response;
  }
}
