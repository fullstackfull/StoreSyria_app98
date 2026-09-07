import '../../network_dio/network_dio.dart';
import '../../utils/base_api.dart';
import '../../utils/prefer.dart';

class StoreSettingRepository {

  getLanguagesData() async {
    String endPoint = API.languagesUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    print("response====>$response");
    return response;
  }

  getCurrenciesData() async {
    String endPoint = API.currenciesUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
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