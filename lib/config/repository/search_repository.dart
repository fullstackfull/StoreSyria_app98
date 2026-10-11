import 'dart:developer';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/network/network.dart';

class SearchRepository {
  getSearchData({
    required String type,
    required String name,
  }) async {
    var endPoint = API.searchDataUrl;
    var data = {'store_id': Prefs.getStoreID(), 'type': type, 'name': name};
    var response = await NetworkHttps.postRequest(endPoint, data);
    log('response====>$response');
    return response;
  }
}
