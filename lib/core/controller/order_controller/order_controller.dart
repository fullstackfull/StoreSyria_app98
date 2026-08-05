// ignore_for_file: avoid_print, invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/config/repository/order_repository.dart';
import 'package:store_go_app/config/repository/search_repository.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/core/model/order_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class OrderController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final SearchRepository searchRepository = SearchRepository();
  final OrderRepository orderRepository = OrderRepository();
  final OrderDetailRepository orderDetailRepository = OrderDetailRepository();

  // Models
  OrderModel? orderModel;
  OrderDetailModel? orderDetailModel;
  OrderDetailData? orderDetail;


  // Reactive Variables
  RxList<OrderData> orderList = <OrderData>[].obs;
  Rxn<OrderModelData> orderData = Rxn<OrderModelData>();
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxDouble extTax = 0.0.obs;
  RxInt selectedStatus = 0.obs;
  RxBool isSearching = false.obs;
  RxBool isDataAvailable = false.obs;


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

  void resetPagination() {
    currantPage.value = 1;
    isScroll.value = true;
    errorMessage.value = '';
  }

  void _setLoading(bool value) {
    isLoading.value = value;
    if (value) errorMessage.value = '';
  }

  Future<void> getOrderData(
      int page, {
        int? deliveredStatus,
        DateTime? fromDate,
        DateTime? toDate,
      }) async {
    if (isSearching.value && page > 1) return;

    if (page == 1) {
      _setLoading(true);
      orderList.clear();
    }

    final result = await orderRepository.getOrderData(
      page,
      deliveredStatus: deliveredStatus,
      fromDate: fromDate,
      toDate: toDate,
    );

    result.fold(
      onSuccess: (data) {
        orderModel = OrderModel.fromJson(data);
        orderData.value = orderModel?.data;

        final newItems = orderData.value?.data ?? [];


        final existingIds = orderList.map((e) => e.id).toSet();
        for (var item in newItems) {
          if (!existingIds.contains(item.id)) {
            orderList.add(item);
          }
        }

        isScroll.value = page < (orderModel?.data?.lastPage ?? 1);
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);
      },
    );

    _setLoading(false);
  }

  Future<void> searchOrderData({required String name}) async {
    if (name.isEmpty) {
      isSearching.value = false;
      resetPagination();
      await getOrderData(1);
      return;
    }

    isSearching.value = true;
    _setLoading(true);

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

        isScroll.value = false;
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);
      },
    );

    _setLoading(false);
  }

  Future<void> getOrderDetailData(String orderId) async {
    _setLoading(true);
    orderDetail = null;
    extTax.value = 0.0;

    final result = await orderDetailRepository.getOrderDetailData(orderId);

    result.fold(
      onSuccess: (data) {
        orderDetailModel = OrderDetailModel.fromJson(data);
        orderDetail = orderDetailModel?.data;

        if (orderDetail?.tax != null) {
          double totalTax = 0;
          for (var tax in orderDetail!.tax!) {
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

    _setLoading(false);
  }

  Future<void> deleteOrderData({required String orderId}) async {
    _setLoading(true);

    final result = await orderRepository.deleteOrderData(orderId);

    result.fold(
      onSuccess: (data) {
        commonToast(data['data']['message']);
        orderList.removeWhere((element) => element.id.toString() == orderId);
        resetPagination();
        getOrderData(1, deliveredStatus: selectedStatus.value);
      },
      onFailure: (reason, message, validationErrors) {
        commonToast(message);
      },
    );

    _setLoading(false);
  }
}