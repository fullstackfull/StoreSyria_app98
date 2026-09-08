import '../../network_dio/network_dio.dart';
import '../../utils/base_api.dart';
import '../../utils/prefer.dart';

class StoreSettingRepository {

  getStoreInfoData() async {
    String endPoint = API.getStoreInfoUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    print("response====>$response");
    return response;
  }

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

  changeStoreLanguage({required Map<String, dynamic> data}) async {
    String endPoint = API.changeLanguageUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.postRequest(
        endPoint,
        data);
    print("response====>$response");
    return response;
  }

  changeStoreCurrency({required Map<String, dynamic> data}) async {
    String endPoint = API.changeCurrencyUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.postRequest(
        endPoint,
        data);
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