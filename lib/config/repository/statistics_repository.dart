import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/app_log.dart';

class StatisticRepository {
  getStatisticData() async {
    var endPoint = API.staticsDataUrl + API.storeIdUrl + Prefs.getStoreID();
    var response = await NetworkHttps.getRequest(endPoint);
    AppLog.d("response==========>$response");
    return response;
  }
}
