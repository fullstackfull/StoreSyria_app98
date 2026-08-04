// ignore_for_file: avoid_print

import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class StatisticRepository {
  getStatisticData() async {
    var endPoint = API.staticsDataUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    print("response==========>$response");
    return response;
  }
}
