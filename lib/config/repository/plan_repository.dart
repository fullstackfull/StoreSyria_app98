import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class PlanRepository {
  getMyPlanData() async {
    String endPoint = "${API.myPlanUrl}${API.storeIdUrl}${Prefs.getStoreID()}";
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }
}
