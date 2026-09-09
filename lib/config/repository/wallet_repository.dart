// ignore_for_file: avoid_print

import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class WalletRepository {
  getWalletData({int page = 1}) async {
    String endPoint =
        "${API.walletUrl}${API.storeIdUrl}${Prefs.getStoreID()}&page=$page";
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  addBalanceData(String description,double amount) async {
    String endPoint = "${API.addBalanceUrl}${API.storeIdUrl}${Prefs.getStoreID()}";
    Map<String, dynamic> data = { "amount": amount, "description": description };
    var response = await NetworkHttps.postRequest(
        endPoint,
        data );
    return response;
  }

  deductBalanceData(String description,double amount) async {
    String endPoint = "${API.deductBalanceUrl}${API.storeIdUrl}${Prefs.getStoreID()}";
    Map<String, dynamic> data = { "amount": amount, "description": description };
    var response = await NetworkHttps.postRequest(
        endPoint,
        data );
    return response;
  }
}