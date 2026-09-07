// ignore_for_file: avoid_print, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/order_repository.dart';
import 'package:store_go_app/config/repository/search_repository.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/core/model/order_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';

import '../../model/top_order_model.dart';

class OrderController extends GetxController implements StoreAware {
  static const String _cacheOrderKey = 'home_order_list_data';

  // ==================== Dependencies ====================
  final TextEditingController searchController = TextEditingController();
  final SearchRepository searchRepository = SearchRepository();
  final OrderRepository orderRepository = OrderRepository();
  final OrderDetailRepository orderDetailRepository =
  OrderDetailRepository();

  // ==================== Models ====================
  OrderModel? orderModel;
  OrderDetailModel? orderDetailModel;
  OrderDetailData? orderDetail;

  // ==================== Reactive Variables ====================
  RxList<OrderData> orderList = <OrderData>[].obs;

  RxBool isDataAvailable = false.obs;
  RxDouble extTax = 0.0.obs;
  RxInt selectedStatus = 0.obs;
  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isSearching = false.obs;
  RxBool isDetailLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxList<OrderData> topOrderList = <OrderData>[].obs;
  RxBool isLoadingTopOrders = false.obs;

  // ==================== Loading States ====================

// Orders
  RxBool isLoadingOrders = false.obs;
  RxBool isLoadingMoreOrders = false.obs;

// Search
  RxBool isSearchingOrders = false.obs;

// Order Details
  RxBool isLoadingOrderDetails = false.obs;

// Update Order Status
  RxBool isUpdatingOrderStatus = false.obs;

// Create Note
  RxBool isCreatingOrderNote = false.obs;

// Delete Note
  RxBool isDeletingOrderNote = false.obs;

// Delete Order
  RxBool isDeletingOrder = false.obs;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();

    resetPagination();

    _loadCachedOrders();

    getTopOrderData();

    StoreChangeService.instance.register(() => this);
  }

  void _loadCachedOrders() {
    final cached =
    CacheService.get<Map<String, dynamic>>(_cacheOrderKey);

    if (cached == null) return;

    try {
      orderModel = OrderModel.fromJson(cached);

      orderList.value = orderModel?.data?.data ?? [];

      currantPage.value =
          orderModel?.data?.currentPage ?? 1;

      isScroll.value =
          currantPage.value <
              (orderModel?.data?.lastPage ?? 1);

      isDataAvailable.value = orderList.isNotEmpty;
    } catch (_) {
      orderModel = null;
    }
  }

  @override
  void resetForStoreChange() {
    orderModel = null;

    orderList.clear();

    CacheService.clear(_cacheOrderKey);

    selectedStatus.value = 0;

    resetPagination();

    getOrderData(1);
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

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'pending'.tr;

      case 1:
        return 'delivered'.tr;

      case 2:
        return 'cancel'.tr;

      case 3:
        return 'return'.tr;

      case 4:
        return 'confirmed'.tr;

      case 5:
        return 'picked_up'.tr;

      case 6:
        return 'shipped'.tr;

      default:
        return 'unknown'.tr;
    }
  }

  // ==================== Orders List & Pagination ====================

  Future<void> getOrderData(
      int page, {
        int? deliveredStatus,
        DateTime? fromDate,
        DateTime? toDate,
      }) async {
    if (page > 1 && isLoadingMoreOrders.value) return;

    if (page > 1 && !isScroll.value) return;

    if (isSearching.value && page > 1) return;

    if (page == 1) {
      isLoadingOrders.value = true;

      orderList.clear();

      currantPage.value = 1;
    } else {
      isLoadingMoreOrders.value = true;
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

          final existingIds =
          orderList.map((e) => e.id).toSet();

          for (final item in newItems) {
            if (!existingIds.contains(item.id)) {
              orderList.add(item);
            }
          }

          currantPage.value = page;

          final lastPage =
              orderModel?.data?.lastPage ?? page;

          isScroll.value = page < lastPage;

          isDataAvailable.value =
              orderList.isNotEmpty;

          if (page == 1 &&
              deliveredStatus == null &&
              fromDate == null &&
              toDate == null) {
            CacheService.save(
              _cacheOrderKey,
              data,
            );
          }
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value =
              'failed_to_load_orders'.tr;

          commonToast(
            'failed_to_load_orders'.tr,
          );
        },
      );
    } catch (e) {
      errorMessage.value =
          'unexpected_error_loading_orders'.tr;

      commonToast(
        'unexpected_error_loading_orders'.tr,
      );

      print('❌ getOrderData Error: $e');
    } finally {
      if (page == 1) {
        isLoadingOrders.value = false;
      } else {
        isLoadingMoreOrders.value = false;
      }
    }
  }

  Future<void> getTopOrderData() async {
    isLoadingTopOrders.value = true;

    try {
      final result = await orderRepository.getTopOrdersData();

      result.fold(
        onSuccess: (data) {
          final model = TopOrderModel.fromJson(data);

          final items = model.data?.topOrders ?? [];

          topOrderList.value =
              items.map((e) => e.toOrderData()).toList();
        },
        onFailure: (reason, message, validationErrors) {
          commonToast('failed_to_load_orders'.tr);
        },
      );
    } catch (e) {
      commonToast('unexpected_error_loading_orders'.tr);
      print('❌ getTopOrderData Error: $e');
    } finally {
      isLoadingTopOrders.value = false;
    }
  }


  // ==================== Search ====================

  Future<void> searchOrderData({
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      isSearching.value = false;

      resetPagination();

      await getOrderData(1);

      return;
    }

    isSearching.value = true;
    isSearchingOrders.value = true;

    try {
      final result =
      await searchRepository.getSearchData(
        type: "order",
        name: name,
      );

      result.fold(
        onSuccess: (data) {
          orderList.clear();

          final responseData = data['data'];

          if (responseData is List) {
            for (final item in responseData) {
              orderList.add(
                OrderData.fromJson(item),
              );
            }

            isDataAvailable.value = true;
          } else {
            isDataAvailable.value = false;
          }

          isScroll.value = false;
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value =
              'failed_to_search_orders'.tr;

          commonToast(
            'failed_to_search_orders'.tr,
          );
        },
      );
    } catch (e) {
      errorMessage.value =
          'failed_to_search_orders'.tr;

      commonToast(
        'failed_to_search_orders'.tr,
      );

      print('❌ searchOrderData Error: $e');
    } finally {
      isSearchingOrders.value = false;
    }
  }
// ==================== Order Details ====================

  Future<void> getOrderDetailData(
      String orderId,
      ) async {
    isLoadingOrderDetails.value = true;

    orderDetail = null;

    extTax.value = 0.0;

    errorMessage.value = '';

    try {
      final result =
      await orderDetailRepository
          .getOrderDetailData(orderId);

      result.fold(
        onSuccess: (data) {
          orderDetailModel =
              OrderDetailModel.fromJson(data);

          orderDetail =
              orderDetailModel?.data;

          if (orderDetail?.tax != null) {
            double totalTax = 0;

            for (final tax in orderDetail!.tax!) {
              totalTax +=
                  double.tryParse(
                    tax.amountstring ?? "0",
                  ) ??
                      0;
            }

            extTax.value = totalTax;
          }
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value =
              'failed_to_load_order_details'.tr;

          commonToast(
            'failed_to_load_order_details'.tr,
          );
        },
      );
    } catch (e) {
      errorMessage.value =
          'failed_to_process_order_details'.tr;

      commonToast(
        'failed_to_process_order_details'.tr,
      );

      print(
        '❌ getOrderDetailData Error: $e',
      );
    } finally {
      isLoadingOrderDetails.value = false;
    }
  }

  // ==================== Update Order Status ====================

  Future<bool> updateOrderStatus({
    required String productOrderId,
    required int deliveredStatus,
    required String paymentStatus,
    String? note,
  }) async {
    isUpdatingOrderStatus.value = true;

    final cleanId = productOrderId.startsWith('#')
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

      await result.fold(
        onSuccess: (data) async {
          success = true;

          if (orderDetail != null) {
            orderDetail!.orderStatus = deliveredStatus;

            orderDetail!.orderStatusText =
                _getStatusText(deliveredStatus);
          }

          resetPagination();

          await getOrderData(1);

          commonToast(
            'order_status_updated_successfully'.tr,
          );
        },

        onFailure: (reason, message, validationErrors) async {
          success = false;

          commonToast(
            'failed_to_update_order_status'.tr,
          );
        },
      );
    } catch (e) {
      success = false;

      commonToast(
        'failed_to_update_order_status'.tr,
      );

      print(
        '❌ updateOrderStatus Error: $e',
      );
    } finally {
      isUpdatingOrderStatus.value = false;
    }

    return success;
  }

  // ==================== Create Order Note ====================

  Future<bool> createOrderNote({
    required int orderId,
    required String noteType,
    required String note,
  }) async {
    isCreatingOrderNote.value = true;

    bool success = false;

    try {
      final result =
      await orderRepository.createNote(
        orderId: orderId,
        noteType: noteType,
        note: note,
      );

      result.fold(
        onSuccess: (data) {
          success = true;

          commonToast(
            'order_note_added_successfully'.tr,
          );
        },
        onFailure: (reason, message, validationErrors) {
          success = false;

          commonToast(
            'failed_to_add_order_note'.tr,
          );
        },
      );
    } catch (e) {
      success = false;

      commonToast(
        'failed_to_add_order_note'.tr,
      );

      print(
        '❌ createOrderNote Error: $e',
      );
    } finally {
      isCreatingOrderNote.value = false;
    }

    return success;
  }

  // ==================== Delete Order Note ====================

  Future<bool> deleteOrderNote({
    required int orderId,
    required int noteId,
  }) async {
    isDeletingOrderNote.value = true;

    bool success = false;

    try {
      final result =
      await orderRepository.deleteNote(
        orderId: orderId,
        noteId: noteId,
      );

      result.fold(
        onSuccess: (data) {
          success = true;

          commonToast(
            'order_note_deleted_successfully'.tr,
          );
        },
        onFailure: (reason, message, validationErrors) {
          success = false;

          commonToast(
            'failed_to_delete_order_note'.tr,
          );
        },
      );
    } catch (e) {
      success = false;

      commonToast(
        'failed_to_delete_order_note'.tr,
      );

      print(
        '❌ deleteOrderNote Error: $e',
      );
    } finally {
      isDeletingOrderNote.value = false;
    }

    return success;
  }
// ==================== Delete Order ====================

  Future<void> deleteOrderData({
    required String orderId,
  }) async {
    isDeletingOrder.value = true;

    try {
      final result =
      await orderRepository
          .deleteOrderData(orderId);

      result.fold(
        onSuccess: (data) {
          commonToast(
            'order_deleted_successfully'.tr,
          );

          orderList.removeWhere(
                (element) =>
            element.id.toString() == orderId,
          );

          isDataAvailable.value =
              orderList.isNotEmpty;

          resetPagination();

          getOrderData(1);
        },
        onFailure: (reason, message, validationErrors) {
          commonToast(
            'failed_to_delete_order'.tr,
          );
        },
      );
    } catch (e) {
      commonToast(
        'failed_to_delete_order'.tr,
      );

      print(
        '❌ deleteOrderData Error: $e',
      );
    } finally {
      isDeletingOrder.value = false;
    }
  }
}