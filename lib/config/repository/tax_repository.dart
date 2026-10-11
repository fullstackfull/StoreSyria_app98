// ignore_for_file: avoid_print

import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class TaxRepository {
  getTaxData(int page) async {
    String endPoint = "${API.taxListUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page";
    var response = await NetworkHttps.getRequest(endPoint);
    print("response==========>$response");
    return response;
  }

  addTaxData({
    required bool isUpdate,
    required String taxId,
    required String taxName,
    required String type,
    required String taxAmount,
    required String status,
  }) async {
    String endPoint = isUpdate == true ? API.updateTaxUrl : API.addTaxUrl;
    Map data = isUpdate == true
        ? {
            'store_id': Prefs.getStoreID(),
            'tax_id': taxId,
            'name': taxName,
            'tax_type': type,
            'tax_amount': taxAmount,
            'status': status
          }
        : {
            'store_id': Prefs.getStoreID(),
            'name': taxName,
            'tax_type': type,
            'tax_amount': taxAmount,
            'status': status
          };
    var response = await NetworkHttps.postRequest(endPoint, data);
    print("response==========>$response");
    return response;
  }

  deleteTaxData(String taxId) async {
    String endPoint = API.deleteTaxUrl +
        API.storeIdUrl +
        Prefs.getStoreID() +
        API.taxIdUrl +
        taxId;
    var response = await NetworkHttps.deleteRequest(endPoint);
    print("response==========>$response");
    return response;
  }
}
