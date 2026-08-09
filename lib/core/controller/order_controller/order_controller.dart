// ignore_for_file: avoid_print, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/order_repository.dart';
import 'package:store_go_app/config/repository/search_repository.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/core/model/order_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

class OrderController extends GetxController {
  // ==================== Dependencies ====================
  final TextEditingController searchController = TextEditingController();
  final SearchRepository searchRepository = SearchRepository();
  final OrderRepository orderRepository = OrderRepository();
  final OrderDetailRepository orderDetailRepository = OrderDetailRepository();

  // ==================== Models ====================
  OrderModel? orderModel;
  OrderDetailModel? orderDetailModel;
  OrderDetailData? orderDetail;

  // ==================== Reactive Variables ====================
  // للقائمة والبحث
  RxList<OrderData> orderList = <OrderData>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxBool isDataAvailable = false.obs;

  // للتفاصيل (منفصل عن اللودر الرئيسي)
  RxBool isDetailLoading = false.obs;
  RxDouble extTax = 0.0.obs;

  // للإجراءات (تحديث حالة، ملاحظات، حذف)
  RxBool isUpdatingStatus = false.obs;

  // للفلترة والترقيم
  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxInt selectedStatus = 0.obs;
  RxString errorMessage = ''.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    resetPagination();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ==================== Helpers ====================
  void resetPagination() {
    currantPage.value = 1;
    isScroll.value = true;
    errorMessage.value = '';
  }

  void _setLoading(bool value) {
    isLoading.value = value;
    if (value) errorMessage.value = '';
  }

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

  // ==================== Orders List & Pagination ====================
  Future<void> getOrderData(
      int page, {
        int? deliveredStatus,
        DateTime? fromDate,
        DateTime? toDate,
      }) async {
    // منع التحميل المتكرر أثناء البحث أو إذا انتهت الصفحات
    if ((isSearching.value && page > 1) || (!isScroll.value && page > 1)) return;

    if (page == 1) {
      _setLoading(true);
      orderList.clear();
    }

    try {
      final result = await orderRepository.getOrderData(
        page,
        deliveredStatus: deliveredStatus,
        fromDate: fromDate,
        toDate: toDate,
      );

      result.fold(
        onSuccess: (data) {
          orderModel = OrderModel.fromJson(data);
          final newItems = orderModel?.data?.data ?? [];

          // منع التكرار عند إضافة عناصر جديدة
          final existingIds = orderList.map((e) => e.id).toSet();
          for (var item in newItems) {
            if (!existingIds.contains(item.id)) {
              orderList.add(item);
            }
          }

          isScroll.value = page < (orderModel?.data?.lastPage ?? 1);
          isDataAvailable.value = orderList.isNotEmpty;
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value = message;
          commonToast(message);
        },
      );
    } catch (e) {
      errorMessage.value = 'حدث خطأ غير متوقع أثناء جلب الطلبات';
      print('❌ getOrderData Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Search ====================
  Future<void> searchOrderData({required String name}) async {
    if (name.isEmpty) {
      isSearching.value = false;
      resetPagination();
      await getOrderData(1);
      return;
    }

    isSearching.value = true;
    _setLoading(true);

    try {
      final result = await searchRepository.getSearchData(
        type: "order",
        name: name,
      );

      result.fold(
        onSuccess: (data) {
          orderList.clear();
          final responseData = data['data'];

          if (responseData is List) {
            for (var item in responseData) {
              orderList.add(OrderData.fromJson(item));
            }
            isDataAvailable.value = true;
          } else {
            isDataAvailable.value = false;
          }
          isScroll.value = false; // تعطيل الترقيم أثناء البحث
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value = message;
          commonToast(message);
        },
      );
    } catch (e) {
      errorMessage.value = 'فشل البحث عن الطلبات';
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Order Details ====================
  /// ⚠️ مهم: هذه الدالة تستخدم isDetailLoading وليس isLoading
  /// مما يمنع تداخل اللودر مع شاشة القائمة
  Future<void> getOrderDetailData(String orderId) async {
    isDetailLoading.value = true;
    orderDetail = null;
    extTax.value = 0.0;
    errorMessage.value = '';

    try {
      final result = await orderDetailRepository.getOrderDetailData(orderId);

      result.fold(
        onSuccess: (data) {
          orderDetailModel = OrderDetailModel.fromJson(data);
          orderDetail = orderDetailModel?.data;

          // حساب الضريبة بشكل آمن
          if (orderDetail?.tax != null) {
            double totalTax = 0;
            for (final tax in orderDetail!.tax!) {
              totalTax += double.tryParse(tax.amountstring ?? "0") ?? 0;
            }
            extTax.value = totalTax;
          }
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value = message;
          commonToast(message);
        },
      );
    } catch (e) {
      errorMessage.value = 'خطأ في تحليل بيانات الطلب';
      print('❌ getOrderDetailData Parsing Error: $e');
      commonToast(errorMessage.value);
    } finally {
      // ✅ ضمان إيقاف اللودر دائماً حتى في حال حدوث Exception
      isDetailLoading.value = false;
    }
  }

  // ==================== Status Update ====================
  Future<bool> updateOrderStatus({
    required String productOrderId,
    required int deliveredStatus,
    required String paymentStatus,
    String? note,
  }) async {
    isUpdatingStatus.value = true;

    // تنظيف الـ ID من رمز #
    String cleanId = productOrderId.startsWith('#')
        ? productOrderId.substring(1)
        : productOrderId;

    bool success = false;

    try {
      final result = await orderRepository.updateOrderStatus(
        productOrderId: cleanId,
        deliveredStatus: deliveredStatus,
        paymentStatus: paymentStatus,
        note: note,
      );

      result.fold(
        onSuccess: (data) {
          success = true;
          // تحديث محلي فوري لتجنب إعادة التحميل
          if (orderDetail != null) {
            orderDetail!.orderStatus = deliveredStatus;
            orderDetail!.orderStatusText = _getStatusText(deliveredStatus);
            orderDetail = orderDetail; // Trigger reactive update
          }
          commonToast(data['message'] ?? 'تم تحديث الحالة بنجاح');
        },
        onFailure: (reason, message, validationErrors) {
          success = false;
          commonToast(message);
        },
      );
    } catch (e) {
      commonToast('فشل الاتصال بالخادم');
    } finally {
      isUpdatingStatus.value = false;
    }

    return success;
  }

  // ==================== Notes Management ====================
  Future<bool> createOrderNote({
    required int orderId,
    required String noteType,
    required String note,
  }) async {
    isUpdatingStatus.value = true;
    bool success = false;

    try {
      final result = await orderRepository.createNote(
        orderId: orderId,
        noteType: noteType,
        note: note,
      );

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
    } catch (e) {
      commonToast('خطأ أثناء إضافة الملاحظة');
    } finally {
      isUpdatingStatus.value = false;
    }

    return success;
  }

  Future<bool> deleteOrderNote({
    required int orderId,
    required int noteId,
  }) async {
    isUpdatingStatus.value = true;
    bool success = false;

    try {
      final result = await orderRepository.deleteNote(
        orderId: orderId,
        noteId: noteId,
      );

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
    } catch (e) {
      commonToast('خطأ أثناء حذف الملاحظة');
    } finally {
      isUpdatingStatus.value = false;
    }

    return success;
  }

  // ==================== Delete Order ====================
  Future<void> deleteOrderData({required String orderId}) async {
    _setLoading(true);

    try {
      final result = await orderRepository.deleteOrderData(orderId);

      result.fold(
        onSuccess: (data) {
          commonToast(data['data']['message']);
          orderList.removeWhere((element) => element.id.toString() == orderId);

          // تحديث حالة البيانات بعد الحذف
          isDataAvailable.value = orderList.isNotEmpty;

          // إعادة تحميل الصفحة الأولى للحفاظ على التسلسل
          resetPagination();
          getOrderData(1);
        },
        onFailure: (reason, message, validationErrors) {
          commonToast(message);
        },
      );
    } catch (e) {
      commonToast('فشل حذف الطلب');
    } finally {
      _setLoading(false);
    }
  }
}