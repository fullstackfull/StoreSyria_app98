import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/app_log.dart';

class SettingRepository {
  saveEmailSettingData({required Map data}) async {
    String endPoint = API.emailSettingUrl;
    var response = await NetworkHttps.postRequest(endPoint, data);
    AppLog.d("response====>$response");
    return response;
  }

  getEmailSettingData() async {
    String endPoint = API.getEmailSettingUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    AppLog.d("response====>$response");
    return response;
  }

  setTestMailData({required String email}) async {
    String endPoint = API.testMailUrl;
    var response = await NetworkHttps.postRequest(endPoint, {'store_id': Prefs.getStoreID(), 'email': email});
    AppLog.d("response====>$response");
    return response;
  }
}
