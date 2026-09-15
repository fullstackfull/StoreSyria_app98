import '../../core/model/store_info_model.dart';
import '../../network_dio/network_dio.dart';
import '../../network_dio/result.dart';
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

  Future<Result<Map<String, dynamic>>> updateStoreInfoData({
    required UpdateStoreRequest request,
  }) async {
    final String endPoint =
        API.updateStoreInfoUrl +
            API.storeIdUrl +
            Prefs.getStoreID();

    return await NetworkHttps.multipartRequest(
      endPoint: endPoint,
      fields: request.fields,
      files: request.files,
      multiFiles: const [],
      multiFileKey: '',
    );
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