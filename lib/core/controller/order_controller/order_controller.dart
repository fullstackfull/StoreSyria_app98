// // ignore_for_file: avoid_print, invalid_use_of_protected_member
//
// import 'dart:developer';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:store_go_app/config/repository/order_repository.dart';
// import 'package:store_go_app/config/repository/search_repository.dart';
// import 'package:store_go_app/core/model/order_detail_model.dart';
// import 'package:store_go_app/core/model/order_model.dart';
// import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
// import 'package:store_go_app/view/widget/loading_widget.dart';
//
// class OrderController extends GetxController {
//   TextEditingController searchController = TextEditingController();
//   SearchRepository searchRepository = SearchRepository();
//   OrderRepository orderRepository = OrderRepository();
//   OrderDetailRepository orderDetailRepository = OrderDetailRepository();
//
//   // Models
//   OrderModel? orderModel;
//   OrderDetailModel? orderDetailModel;
//   OrderDetailData? orderDetail;
//
//   // Reactive Variables
//   RxList<OrderData> orderList = <OrderData>[].obs;
//   RxBool isDataAvailable = false.obs; // للتحميل الأولي أو تحميل التفاصيل
//   RxBool isLoading = false.obs;       // للتحميل العام (Pagination/Search)
//   RxString errorMessage = ''.obs;     // لعرض رسائل الخطأ
//   RxInt currantPage = 1.obs;
//   RxBool isScroll = true.obs;
//   RxString imageBaseUrl = ''.obs;
//   RxDouble extTax = 0.0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // تعيين القيم الافتراضية عند دخول الكونترولر
//     currantPage.value = 1;
//     isScroll.value = true;
//     errorMessage.value = '';
//   }
//
//   // دالة مساعدة لإظهار/إخفاء اللودر وتحديث الحالة
//   void _setLoading(bool value) {
//     isLoading.value = value;
//     if (value) {
//       errorMessage.value = ''; // مسح الخطأ عند بدء التحميل
//     }
//   }
//
//   Future<void> getOrderData(int page) async {
//     if (page == 1) {
//       _setLoading(true);
//       orderList.clear();
//     }
//
//     final result = await orderRepository.getOrderData(page);
//
//     result.fold(
//       onSuccess: (data) {
//         orderModel = OrderModel.fromJson(data);
//
//         orderList.addAll(orderModel?.data?.data ?? []);
//         orderList.refresh();
//
//         isScroll.value =
//             page < (orderModel?.data?.lastPage ?? 1);
//       },
//       onFailure: (reason, message, validationErrors) {
//         errorMessage.value = message;
//         //commonToast(message);
//       },
//     );
//
//     _setLoading(false);
//   }
//
//   Future<void> searchOrderData({required String name}) async {
//     _setLoading(true);
//     final result = await searchRepository.getSearchData(
//       type: "order",
//       name: name,
//     );
//
//     result.fold(
//       onSuccess: (data) {
//         orderList.clear();
//
//         if (data['data'] != null) {
//           for (var item in data['data']) {
//             orderList.add(OrderData.fromJson(item));
//           }
//           orderList.refresh();
//         }
//       },
//       onFailure: (reason, message, validationErrors) {
//         errorMessage.value = message;
//         //commonToast(message);
//       },
//     );
//
//     _setLoading(false);
//   }
//
//   Future<void> getOrderDetailData(String orderId) async {
//
//     isDataAvailable.value = true;
//     orderDetail = null;
//     errorMessage.value = '';
//     extTax.value = 0.0;
//
//     final result =
//     await orderDetailRepository.getOrderDetailData(orderId);
//
//     result.fold(
//       onSuccess: (data) {
//         orderDetailModel = OrderDetailModel.fromJson(data);
//         orderDetail = orderDetailModel?.data;
//
//         extTax.value = 0;
//
//         if (orderDetail?.tax != null) {
//           for (var tax in orderDetail!.tax!) {
//             extTax.value +=
//                 double.tryParse(tax.amountstring ?? "0") ?? 0;
//           }
//         }
//       },
//       onFailure: (reason, message, validationErrors) {
//         errorMessage.value = message;
//         //commonToast(message);
//       },
//     );
//
//     isDataAvailable.value = false;
//   }
//
//   Future<void> deleteOrderData({required String orderId}) async {
//     Loader.showLoader();
//
//     final result =
//     await orderRepository.deleteOrderData(orderId);
//
//     result.fold(
//       onSuccess: (data) {
//         commonToast(data['data']['message']);
//         getOrderData(currantPage.value);
//       },
//       onFailure: (reason, message, validationErrors) {
//         //commonToast(message);
//       },
//     );
//
//     Loader.hideLoader();
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../config/repository/order_repository.dart';
import '../../../config/repository/search_repository.dart';
import '../../../view/widget/common_snak_bar_widget.dart';
import '../../../view/widget/loading_widget.dart';
import '../../model/order_detail_model.dart';
import '../../model/order_model.dart';


class OrderController extends GetxController {
  TextEditingController searchController = TextEditingController();
  SearchRepository searchRepository = SearchRepository();
  OrderRepository orderRepository = OrderRepository();
  OrderDetailRepository orderDetailRepository = OrderDetailRepository();

  // Models
  OrderModel? orderModel;
  OrderDetailModel? orderDetailModel;
  OrderDetailData? orderDetail;

  // Reactive Variables
  RxList<OrderData> orderList = <OrderData>[].obs;
  RxBool isDataAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxBool isUpdatingStatus = false.obs; // ⭐ جديد: للتحميل أثناء تحديث الحالة
  RxString errorMessage = ''.obs;
  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxString imageBaseUrl = ''.obs;
  RxDouble extTax = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    currantPage.value = 1;
    isScroll.value = true;
    errorMessage.value = '';
  }

  void _setLoading(bool value) {
    isLoading.value = value;
    if (value) {
      errorMessage.value = '';
    }
  }

  Future<void> getOrderData(int page) async {
    if (page == 1) {
      _setLoading(true);
      orderList.clear();
    }

    final result = await orderRepository.getOrderData(page);

    result.fold(
      onSuccess: (data) {
        orderModel = OrderModel.fromJson(data);
        orderList.addAll(orderModel?.data?.data ?? []);
        orderList.refresh();
        isScroll.value = page < (orderModel?.data?.lastPage ?? 1);
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
      },
    );

    _setLoading(false);
  }

  Future<void> searchOrderData({required String name}) async {
    _setLoading(true);
    final result = await searchRepository.getSearchData(
      type: "order",
      name: name,
    );

    result.fold(
      onSuccess: (data) {
        orderList.clear();
        if (data['data'] != null) {
          for (var item in data['data']) {
            orderList.add(OrderData.fromJson(item));
          }
          orderList.refresh();
        }
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
      },
    );

    _setLoading(false);
  }

  Future<void> getOrderDetailData(String orderId) async {
    isDataAvailable.value = true;
    orderDetail = null;
    errorMessage.value = '';
    extTax.value = 0.0;

    final result = await orderDetailRepository.getOrderDetailData(orderId);

    result.fold(
      onSuccess: (data) {
        orderDetailModel = OrderDetailModel.fromJson(data);
        orderDetail = orderDetailModel?.data;
        extTax.value = 0;

        if (orderDetail?.tax != null) {
          for (var tax in orderDetail!.tax!) {
            extTax.value += double.tryParse(tax.amountstring ?? "0") ?? 0;
          }
        }
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
      },
    );

    isDataAvailable.value = false;
  }

  // ⭐⭐⭐ دالة جديدة: تحديث حالة الطلب ⭐⭐⭐
  Future<bool> updateOrderStatus({
    required String productOrderId,
    required int deliveredStatus,
    required String paymentStatus,
    String? note,
  }) async {
    isUpdatingStatus.value = true;

    // ⭐ أزل # من بداية الـ ID
    String cleanId = productOrderId.startsWith('#')
        ? productOrderId.substring(1)
        : productOrderId;

    final result = await orderRepository.updateOrderStatus(
      productOrderId: cleanId,
      deliveredStatus: deliveredStatus,
      paymentStatus: paymentStatus,
      note: note,
    );

    bool success = false;

    result.fold(
      onSuccess: (data) {
        success = true;
        // تحديث الحالة محلياً بدون إعادة تحميل
        if (orderDetail != null) {
          orderDetail!.orderStatus = deliveredStatus;
          orderDetail!.orderStatusText = _getStatusText(deliveredStatus);
          orderDetail = orderDetail; // Trigger Rx update
        }
        commonToast(data['message'] ?? 'تم تحديث الحالة بنجاح');
      },
      onFailure: (reason, message, validationErrors) {
        success = false;
        commonToast(message);
      },
    );

    isUpdatingStatus.value = false;
    return success;
  }

  // ⭐ مساعد: الحصول على نص الحالة
  String _getStatusText(int status) {
    switch (status) {
      case 0: return 'Pending';
      case 1: return 'Delivered';
      case 2: return 'Cancel';
      case 3: return 'Return';
      case 4: return 'Confirmed';
      case 5: return 'Picked Up';
      case 6: return 'Shipped';
      default: return 'Unknown';
    }
  }

  Future<void> deleteOrderData({required String orderId}) async {
    Loader.showLoader();
    final result = await orderRepository.deleteOrderData(orderId);

    result.fold(
      onSuccess: (data) {
        commonToast(data['data']['message']);
        getOrderData(currantPage.value);
      },
      onFailure: (reason, message, validationErrors) {},
    );

    Loader.hideLoader();
  }

  // ⭐⭐⭐ جديد: إنشاء ملاحظة ⭐⭐⭐
  Future<bool> createOrderNote({
    required int orderId,
    required String noteType,
    required String note,
  }) async {
    isUpdatingStatus.value = true;

    final result = await orderRepository.createNote(
      orderId: orderId,
      noteType: noteType,
      note: note,
    );

    bool success = false;

    result.fold(
      onSuccess: (data) {
        success = true;
        commonToast(data['message'] ?? 'تم إضافة الملاحظة بنجاح');
      },
      onFailure: (reason, message, validationErrors) {
        success = false;
        commonToast(message);
      },
    );

    isUpdatingStatus.value = false;
    return success;
  }

  // ⭐⭐⭐ جديد: حذف ملاحظة ⭐⭐⭐
  Future<bool> deleteOrderNote({
    required int orderId,
    required int noteId,
  }) async {
    isUpdatingStatus.value = true;

    final result = await orderRepository.deleteNote(
      orderId: orderId,
      noteId: noteId,
    );

    bool success = false;

    result.fold(
      onSuccess: (data) {
        success = true;
        commonToast(data['message'] ?? 'تم حذف الملاحظة بنجاح');
      },
      onFailure: (reason, message, validationErrors) {
        success = false;
        commonToast(message);
      },
    );

    isUpdatingStatus.value = false;
    return success;
  }
}