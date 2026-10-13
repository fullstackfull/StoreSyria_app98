import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/app_log.dart';

class LoyaltyRepository {
  setLoyaltyData({required String status, required String point}) async {
    String endPoint = API.loyaltySettingUrl;
    var response = await NetworkHttps.postRequest(endPoint, {
      'store_id': Prefs.getStoreID(),
      'loyality_program_enabled': status,
      'reward_point': point
    });
    AppLog.d("response====>$response");
    return response;
  }

  getLoyaltySettingData() async {
    String endPoint =
        API.getLoyaltySettingUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    AppLog.d("response====>$response");
    return response;
  }
}
