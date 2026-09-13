import '../../network_dio/network_dio.dart';
import '../../utils/base_api.dart';
import '../../utils/prefer.dart';

class StoreSettingRepository {

  getStoreCurrencyLang() async {
    String endPoint = API.getStoreCurrencyLangUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }
  getStoreInfoData() async {
    String endPoint = API.getStoreInfoUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  getLanguagesData() async {
    String endPoint = API.languagesUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  getCurrenciesData() async {
    String endPoint = API.currenciesUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  changeStoreLanguage({required Map<String, dynamic> data}) async {
    String endPoint = API.changeLanguageUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.postRequest(
        endPoint,
        data);
    return response;
  }

  changeStoreCurrency({required Map<String, dynamic> data}) async {
    String endPoint = API.changeCurrencyUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.postRequest(
        endPoint,
        data);
    return response;
  }

  deleteStoreData() async {
    String endPoint = API.deleteStoreUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.deleteRequest(endPoint);
    return response;
  }

  getCurrencyRatesData() async {
    String endPoint = API.getCurrencyRatesUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  toggleCurrencyStatus({required Map<String, dynamic> data}) async {
    String endPoint = API.toggleCurrencyStatusUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.putRequest(endPoint, data);
    return response;
  }

  updateCurrencyRate({required Map<String, dynamic> data}) async {
    String endPoint = API.updateCurrencyRateUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.putRequest(endPoint, data);
    return response;
  }

}