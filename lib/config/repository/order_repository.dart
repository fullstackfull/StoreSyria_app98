// // ignore_for_file: avoid_print
//
// import 'package:store_go_app/network_dio/network_dio.dart';
// import 'package:store_go_app/utils/base_api.dart';
// import 'package:store_go_app/utils/prefer.dart';
//
// class OrderRepository {
//   getOrderData(int page) async {
//     String endPoint = "${API.orderListUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page";
//     var response = await NetworkHttps.getRequest(endPoint);
//     print("response==========>$response");
//     return response;
//   }
//   deleteOrderData(orderId) async {
//     String endPoint = API.deleteOrderUrl + API.storeIdUrl + Prefs.getStoreID() + API.orderIdUrl + orderId;
//     var response = await NetworkHttps.deleteRequest(endPoint);
//     print("response==========>$response");
//     return response;
//   }
// }
//
// class OrderDetailRepository {
//   getOrderDetailData(orderId) async {
//     String endPoint = API.viewOrderUrl + API.storeIdUrl + Prefs.getStoreID() + API.orderIdUrl + orderId;
//     var response = await NetworkHttps.getRequest(endPoint);
//     print("response==========>$response");
//     return response;
//   }
// }

// ignore_for_file: avoid_print

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

  // ⭐⭐⭐ تحديث حالة الطلب ⭐⭐⭐
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

    print("updateOrderStatus body==========>$body");

    var response = await NetworkHttps.postRequest(endPoint, body);
    print("updateOrderStatus response==========>$response");
    return response;
  }

  // ⭐⭐⭐ جديد: إنشاء ملاحظة ⭐⭐⭐
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

    print("createNote body==========>$body");

    var response = await NetworkHttps.postRequest(endPoint, body);
    print("createNote response==========>$response");
    return response;
  }

  // ⭐⭐⭐ جديد: حذف ملاحظة ⭐⭐⭐
  deleteNote({
    required int orderId,
    required int noteId,
  }) async {
    String endPoint = "/orders/notes/delete?store_id=${Prefs.getStoreID()}&order_id=$orderId&note_id=$noteId";

    print("deleteNote endPoint==========>$endPoint");

    var response = await NetworkHttps.deleteRequest(endPoint);
    print("deleteNote response==========>$response");
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