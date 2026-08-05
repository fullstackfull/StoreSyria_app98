// ignore_for_file: avoid_print

import 'package:intl/intl.dart';
import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class OrderRepository {
  getOrderData(
      int page,
      {int? deliveredStatus,
        DateTime? fromDate,
        DateTime? toDate,
      })  async {
    String endPoint = "${API.orderListUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page";
    if (deliveredStatus != null) {
      endPoint += "${API.andStatusUrl}$deliveredStatus";
    }
    if (fromDate != null) {
      endPoint += "${API.andFromDateUrl}${DateFormat('yyyy-MM-dd').format(fromDate)}";
    }

    if (toDate != null) {
      endPoint += "${API.andToDateUrl}${DateFormat('yyyy-MM-dd').format(toDate)}";
    }

    var response = await NetworkHttps.getRequest(endPoint);
    print("response==========>$response");
    return response;
  }
  deleteOrderData(orderId) async {
    String endPoint = API.deleteOrderUrl + API.storeIdUrl + Prefs.getStoreID() + API.orderIdUrl + orderId;
    var response = await NetworkHttps.deleteRequest(endPoint);
    print("response==========>$response");
    return response;
  }
}

class OrderDetailRepository {
  getOrderDetailData(orderId) async {
    String endPoint = API.viewOrderUrl + API.storeIdUrl + Prefs.getStoreID() + API.orderIdUrl + orderId;
    var response = await NetworkHttps.getRequest(endPoint);
    print("response==========>$response");
    return response;
  }
}
