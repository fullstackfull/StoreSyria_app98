import 'package:intl/intl.dart';
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import '../../core/model/create_order_model.dart';
import '../../network/result.dart';
import 'package:store_go_app/utils/app_log.dart';

class OrderRepository {

  Future<dynamic> assignOrderToDelivery({
    required Map<String, dynamic> data,
  }) async {
    String endPoint = '${API.assignOrderUrl}${API.storeIdUrl}${Prefs.getStoreID()}';

    var response = await NetworkHttps.postRequest(
      endPoint,
      data,
    );

    return response;
  }

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
    AppLog.d("response==========>$response");
    return response;
  }

  getTopOrdersData()  async {
    String endPoint = "${API.topOrdersUrl}${API.storeIdUrl}${Prefs.getStoreID()}";
    var response = await NetworkHttps.getRequest(endPoint);
    AppLog.d("response==========>$response");
    return response;
  }

  Future<Result<Map<String, dynamic>>> createOrder({
    required CreateOrderRequest request,
  }) async {
    final String endPoint =
        "${API.createOrderUrl}${API.storeIdUrl}${Prefs.getStoreID()}";

    final body = request.toJson();

    AppLog.d("createOrder body==========>$body");

    final response = await NetworkHttps.postRequest(
      endPoint,
      body,
    );

    AppLog.d("createOrder response==========>$response");

    return response;
  }

  deleteOrderData(orderId) async {
    String endPoint = API.deleteOrderUrl + API.storeIdUrl + Prefs.getStoreID() + API.orderIdUrl + orderId;
    var response = await NetworkHttps.deleteRequest(endPoint);
    AppLog.d("response==========>$response");
    return response;
  }

  updateOrderStatus({
    required String productOrderId,
    required int deliveredStatus,
    required String paymentStatus,
    String? note,
  }) async {
    String endPoint = "/orders/update-status";

    var body = {
      'product_order_id': productOrderId,
      'delivered_status': deliveredStatus,
      'payment_status': paymentStatus,
      'note': note ?? '',
    };

    AppLog.d("updateOrderStatus body==========>$body");

    var response = await NetworkHttps.postRequest(endPoint, body);
    AppLog.d("updateOrderStatus response==========>$response");
    return response;
  }

  createNote({
    required int orderId,
    required String noteType,
    required String note,
  }) async {
    String endPoint = "/orders/notes/create";

    var body = {
      'store_id': Prefs.getStoreID(),
      'order_id': orderId,
      'note_type': noteType,
      'note': note,
    };

    AppLog.d("createNote body==========>$body");

    var response = await NetworkHttps.postRequest(endPoint, body);
    AppLog.d("createNote response==========>$response");
    return response;
  }

  deleteNote({
    required int orderId,
    required int noteId,
  }) async {
    String endPoint = "/orders/notes/delete?store_id=${Prefs.getStoreID()}&order_id=$orderId&note_id=$noteId";

    AppLog.d("deleteNote endPoint==========>$endPoint");

    var response = await NetworkHttps.deleteRequest(endPoint);
    AppLog.d("deleteNote response==========>$response");
    return response;
  }
}

class OrderDetailRepository {
  getOrderDetailData(orderId) async {
    String endPoint = API.viewOrderUrl + API.storeIdUrl + Prefs.getStoreID() + API.orderIdUrl + orderId;
    var response = await NetworkHttps.getRequest(endPoint);
    AppLog.d("response==========>$response");
    return response;
  }
}