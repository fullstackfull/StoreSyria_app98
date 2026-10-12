import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class PaymentSettingRepository {

  getPaymentTypesData() async {
    String endPoint = API.paymentTypesUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  // getCodPaymentData() async {
  //   String endPoint = API.getCodPaymentUrl + API.storeIdUrl + Prefs.getStoreID();
  //   var response = await NetworkHttps.getRequest(endPoint);
  //   return response;
  // }
  //
  // getBankPaymentData() async {
  //   String endPoint =
  //       API.getBankPaymentUrl + API.storeIdUrl + Prefs.getStoreID();
  //   var response = await NetworkHttps.getRequest(endPoint);
  //   return response;
  // }
  //
  // getStripePaymentData() async {
  //   String endPoint =
  //       API.getStripePaymentUrl + API.storeIdUrl + Prefs.getStoreID();
  //   var response = await NetworkHttps.getRequest(endPoint);
  //   return response;
  // }
}
