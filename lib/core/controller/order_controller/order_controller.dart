import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/order_repository.dart';
import 'package:store_go_app/config/repository/search_repository.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/core/model/order_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/core/model/payment_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';
import '../../model/create_order_model.dart';
import '../../model/customer_model.dart';
import '../../model/top_order_model.dart';

import 'package:store_go_app/utils/app_log.dart';

enum OrderListMode {
  normal,
  search,
}

class OrderLineItem {
  final Rx<ProductData?> product = Rx<ProductData?>(null);
  final TextEditingController qtyController =
  TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    qtyController.dispose();
    priceController.dispose();
  }
}

class OrderController extends GetxController implements StoreAware {
  static const String _cacheOrderKey = 'home_order_list_data';
  final RxString currencySymbol = ''.obs;

  // ==================== Dependencies ====================
  final TextEditingController searchController = TextEditingController();
  final SearchRepository searchRepository = SearchRepository();
  final OrderRepository orderRepository = OrderRepository();
  final OrderDetailRepository orderDetailRepository =
  OrderDetailRepository();
  final RxList<OrderData> searchResults = <OrderData>[].obs;
  final Rx<OrderListMode> listMode = OrderListMode.normal.obs;

  // ==================== Models ====================
  OrderModel? orderModel;
  OrderDetailModel? orderDetailModel;
  OrderDetailData? orderDetail;

  // ==================== Reactive Variables ====================
  RxList<OrderData> orderList = <OrderData>[].obs;

  RxBool isDataAvailable = false.obs;
  RxBool isAssigningDelivery = false.obs;
  RxDouble extTax = 0.0.obs;
  RxInt selectedStatus = 0.obs;
  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isSearching = false.obs;
  RxBool isDetailLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool orderNotFound = false.obs;
  RxList<OrderData> topOrderList = <OrderData>[].obs;
  RxBool isLoadingTopOrders = false.obs;

  // ==================== Loading States ====================
  RxBool isLoadingOrders = false.obs;
  RxBool isLoadingMoreOrders = false.obs;
  RxBool isSearchingOrders = false.obs;
  RxBool isLoadingOrderDetails = false.obs;
  RxBool isUpdatingOrderStatus = false.obs;
  RxBool isCreatingOrderNote = false.obs;
  RxBool isDeletingOrderNote = false.obs;
  RxBool isDeletingOrder = false.obs;
  RxBool isCreatingOrder = false.obs;

  // ==================== Create Order (Tab 1) : الزبون + الدفع ====================
  Rx<CustomerData?> selectedCustomer = Rx<CustomerData?>(null);

  /// العنصر المختار من دروب داون طرق الدفع (يستخدم فقط لعرض/تحديد القيمة بالدروب داون)
  Rx<PaymentMethod?> selectedPaymentMethod = Rx<PaymentMethod?>(null);

  /// القيمة الحقيقية يلي بترسل للباك اند (مثلاً "cod")
  RxString paymentType = ''.obs;

  /// نص حالة الدفع يلي بيترسل كـ String: "Paid" أو "Unpaid"
  RxString paymentStatus = 'Unpaid'.obs;

  final TextEditingController noteController = TextEditingController();

  // ==================== Create Order (Tab 2) : المنتجات ====================
  RxList<OrderLineItem> orderLineItems = <OrderLineItem>[].obs;

  void addLineItem() {
    orderLineItems.add(OrderLineItem());
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= orderLineItems.length) return;
    if (orderLineItems.length == 1) return;
    orderLineItems[index].dispose();
    orderLineItems.removeAt(index);
  }

  void onProductSelected(int index, ProductData product) {
    if (index < 0 || index >= orderLineItems.length) return;
    final line = orderLineItems[index];
    line.product.value = product;
    line.priceController.text = product.price?.toString() ?? '0';
    if (line.qtyController.text.trim().isEmpty) {
      line.qtyController.text = '1';
    }
  }

  Timer? _orderSearchDebounce;

  void clearOrderSearch() {
    _orderSearchDebounce?.cancel();

    searchController.clear();
    searchResults.clear();

    isSearching.value = false;
    isSearchingOrders.value = false;

    errorMessage.value = '';

    listMode.value = OrderListMode.normal;
    isScroll.value = true;
  }


  double get productsTotal {
    double total = 0;
    for (final line in orderLineItems) {
      final qty = int.tryParse(line.qtyController.text.trim()) ?? 0;
      final price = double.tryParse(line.priceController.text.trim()) ?? 0;
      total += qty * price;
    }
    return total;
  }

  // ==================== Create Order (Tab 3) : الشحن ====================
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  /// المدينة المختارة من الدروب داون (API)
  RxString selectedCityId = ''.obs;
  RxString selectedCityName = ''.obs;
  final RxList<OrderData> filteredOrderList = <OrderData>[].obs;
  final TextEditingController deliveryPriceController = TextEditingController();
  final TextEditingController taxPriceController = TextEditingController();

  // حقول موجودة بالباك اند لكن ما ظاهرة بالتصميم الجديد -> بترسل فاضية
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();


  void fillShippingFromCustomer(CustomerData customer) {
    final fullName = customer.customerInfo?.name?.trim() ?? '';

    if (fullName.isNotEmpty) {
      final parts = fullName.split(RegExp(r'\s+'));

      firstNameController.text = parts.first;
      lastNameController.text =
      parts.length > 1 ? parts.sublist(1).join(' ') : '';
    } else {
      firstNameController.clear();
      lastNameController.clear();
    }
    emailController.text = customer.email?.trim() ?? '';
    phoneController.text = customer.customerInfo?.mobile?.trim() ?? '';
    addressController.text = customer.address?.trim() ?? '';
    selectedCityName.value = customer.city?.trim() ?? '';
  }

  void resetCreateOrderForm() {
    selectedCustomer.value = null;
    selectedPaymentMethod.value = null;
    paymentType.value = '';
    paymentStatus.value = 'Unpaid';
    noteController.clear();

    for (final line in orderLineItems) {
      line.dispose();
    }
    orderLineItems.clear();
    orderLineItems.add(OrderLineItem());

    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    selectedCityId.value = '';
    selectedCityName.value = '';
    deliveryPriceController.clear();
    taxPriceController.clear();

    cityController.clear();
    stateController.clear();
    countryController.clear();
    postcodeController.clear();
  }

  Future<bool> createOrderData({
    required List<dynamic> productList,
  }) async {
    isCreatingOrder.value = true;

    bool success = false;

    try {
      final products = orderLineItems.map((line) {
        return OrderProductRequest(
          productId: line.product.value?.id ?? 0,
          quantity: int.tryParse(line.qtyController.text.trim()) ?? 1,
          price: double.tryParse(line.priceController.text.trim()) ?? 0,
        );
      }).toList();

      final request = CreateOrderRequest(
        customerId: selectedCustomer.value!.id ?? 0,
        products: products,
        paymentType: paymentType.value,
        paymentStatus: paymentStatus.value,
        deliveryPrice: double.tryParse(deliveryPriceController.text.trim()) ?? 0,
        taxPrice: double.tryParse(taxPriceController.text.trim()) ?? 0,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        telephone: phoneController.text.trim(),
        address: addressController.text.trim(),
        stateId: selectedCityId.value,
        countryId: 215,
        postcode: postcodeController.text.trim(),
        additionalNote: noteController.text.trim(),
      );

      final result = await orderRepository.createOrder(request: request);

      result.fold(
        onSuccess: (data) {
          success = true;
          commonToast(type: AppSnackBarType.success, 'order_created_successfully'.tr);
          resetCreateOrderForm();
          resetPagination();
        },
        onFailure: (reason, message, validationErrors) {
          success = false;
          commonToast(type: AppSnackBarType.error,
            message.isNotEmpty ? message : 'failed_to_create_order'.tr,
          );
        },
      );
    } catch (e) {
      success = false;
      commonToast(type: AppSnackBarType.error, 'failed_to_create_order'.tr);
      AppLog.d('❌ createOrderData Error: $e');
    } finally {
      isCreatingOrder.value = false;
    }

    return success;
  }

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    resetPagination();
    _loadCachedOrders();
    getTopOrderData();

    if (orderLineItems.isEmpty) {
      orderLineItems.add(OrderLineItem());
    }

    StoreChangeService.instance.register(() => this);
  }

  void _loadCachedOrders() {
    final cached = CacheService.get<Map<String, dynamic>>(_cacheOrderKey);
    if (cached == null) return;
    try {
      orderModel = OrderModel.fromJson(cached);
      orderList.value = orderModel?.data?.data ?? [];
      currantPage.value = orderModel?.data?.currentPage ?? 1;
      isScroll.value = currantPage.value < (orderModel?.data?.lastPage ?? 1);
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
    _orderSearchDebounce?.cancel();
    searchController.dispose();
    noteController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    deliveryPriceController.dispose();
    taxPriceController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postcodeController.dispose();
    _orderSearchDebounce?.cancel();
    searchController.dispose();
    for (final line in orderLineItems) {
      line.dispose();
    }
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

  Future<bool> assignOrderToDelivery({
    required String deliveryBoyId,
    required String orderId,
  }) async {
    if (isAssigningDelivery.value) return false;
    isAssigningDelivery.value = true;

    try {
      final response = await orderRepository.assignOrderToDelivery(
        data: {
          'delivery_boy': deliveryBoyId,
          'order_id': orderId,
        },
      );

      bool success = false;

      response.fold(
        onSuccess: (data) {
          if (data['status'] == 'success' || data['status'] == 1) {
            success = true;
            commonToast(
              type: AppSnackBarType.success,
              data['message']?.toString() ?? 'order_assigned_successfully'.tr,
            );
          } else {
            commonToast(
              type: AppSnackBarType.error,
              data['message']?.toString() ?? 'something_went_wrong'.tr,
            );
          }
        },
        onFailure: (reason, message, validationErrors) {
          commonToast(type: AppSnackBarType.error, message);
        },
      );

      return success;
    } catch (e) {
      commonToast(type: AppSnackBarType.error, 'something_went_wrong'.tr);
      return false;
    } finally {
      isAssigningDelivery.value = false;
    }
  }

  // ==================== Orders List & Pagination ====================

  Future<void> getOrderData(
      int page, {
        int? deliveredStatus,
        DateTime? fromDate,
        DateTime? toDate,
      }) async {
    if (listMode.value != OrderListMode.normal) return;

    if (page > 1 && isLoadingMoreOrders.value) return;
    if (page > 1 && !isScroll.value) return;

    final isDateFilterActive = fromDate != null || toDate != null;

    if (page == 1) {
      isLoadingOrders.value = true;

      // إذا طلب عادي بدون date filter
      if (!isDateFilterActive) {
        orderList.clear();
      }

      // إذا date filter
      // لا نمسح orderList لأنها القائمة الأصلية
      if (isDateFilterActive) {
        filteredOrderList.clear();
      }

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
          final model = OrderModel.fromJson(data);
          final newItems = model.data?.data ?? [];
          final targetList = isDateFilterActive ? filteredOrderList : orderList;

          final existingIds = targetList.map((e) => e.id).toSet();

          for (final item in newItems) {
            if (!existingIds.contains(item.id)) {
              targetList.add(item);
            }
          }

          if (!isDateFilterActive) {
            orderModel = model;
          }

          currantPage.value = page;

          final lastPage = model.data?.lastPage ?? page;

          isScroll.value = page < lastPage;

          isDataAvailable.value = targetList.isNotEmpty;

          // Cache فقط للقائمة العادية بدون date filter
          if (page == 1 &&
              deliveredStatus == null &&
              fromDate == null &&
              toDate == null) {
            orderModel = model;
            CacheService.save(_cacheOrderKey, data);
          }
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value = 'failed_to_load_orders'.tr;
          commonToast(type: AppSnackBarType.error, 'failed_to_load_orders'.tr);
        },
      );
    } catch (e) {
      errorMessage.value =
          'unexpected_error_loading_orders'.tr;

      commonToast(type: AppSnackBarType.error, 'unexpected_error_loading_orders'.tr);

      AppLog.d('❌ getOrderData Error: $e');
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
          topOrderList.value = items.map((e) => e.toOrderData()).toList();
        },
        onFailure: (reason, message, validationErrors) {
          commonToast(type: AppSnackBarType.error, 'failed_to_load_orders'.tr);
        },
      );
    } catch (e) {
      commonToast(type: AppSnackBarType.error, 'unexpected_error_loading_orders'.tr);
      AppLog.d('❌ getTopOrderData Error: $e');
    } finally {
      isLoadingTopOrders.value = false;
    }
  }

  // ==================== Search ====================

  Future<void> searchOrderData({
    required String name,
  }) async {
    final query = name.trim();

    if (query.isEmpty) {
      clearOrderSearch();
      return;
    }

    listMode.value = OrderListMode.search;

    isSearching.value = true;
    isSearchingOrders.value = true;

    searchResults.clear();
    errorMessage.value = '';
    isScroll.value = false;

    try {
      final result = await searchRepository.getSearchData(
        type: "order",
        name: query,
      );

      result.fold(
        onSuccess: (data) {
          searchResults.clear();

          final responseData = data['data'];

          if (responseData is List) {
            for (final item in responseData) {
              if (item is! Map<String, dynamic>) continue;
              searchResults.add(
                OrderData.fromJson(item),
              );
            }
          }
        },
        onFailure: (reason, message, validationErrors) {
          searchResults.clear();
          errorMessage.value = 'failed_to_search_orders'.tr;
          commonToast(type: AppSnackBarType.error, 'failed_to_search_orders'.tr);
        },
      );
    } catch (e) {
      searchResults.clear();
      errorMessage.value = 'failed_to_search_orders'.tr;
      commonToast(type: AppSnackBarType.error, 'failed_to_search_orders'.tr);

      AppLog.d('❌ searchOrderData Error: $e');
    } finally {
      isSearching.value = false;
      isSearchingOrders.value = false;
    }
  }

  void onOrderSearchChanged(String value) {
    _orderSearchDebounce?.cancel();

    final query = value.trim();

    if (query.length < 3) {
      if (query.isEmpty &&
          listMode.value == OrderListMode.search) {
        clearOrderSearch();
      }

      return;
    }

    _orderSearchDebounce = Timer(
      const Duration(milliseconds: 600),
          () {
        searchOrderData(name: query);
      },
    );
  }
  // ==================== Order Details ====================

  Future<void> getOrderDetailData(String orderId) async {
    isLoadingOrderDetails.value = true;
    orderDetail = null;
    extTax.value = 0.0;
    errorMessage.value = '';
    orderNotFound.value = false;

    try {
      final result = await orderDetailRepository.getOrderDetailData(orderId);

      result.fold(
        onSuccess: (data) {
          if (data['status'] != 1 || data['data'] is! Map || data['data']['id'] == null) {
            orderNotFound.value = true;
            return;
          }
          orderDetailModel = OrderDetailModel.fromJson(data);
          orderDetail = orderDetailModel?.data;
          currencySymbol.value = orderDetail?.currencySymbol ?? currencySymbol.value;

          // if (orderDetail?.tax != null) {
          //   double totalTax = 0;
          //   for (final tax in orderDetail!.tax!) {
          //     totalTax += double.tryParse(tax.amountstring ?? "0") ?? 0;
          //   }
          //   extTax.value = totalTax;
          // }
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage.value = 'failed_to_load_order_details'.tr;
          commonToast(type: AppSnackBarType.error, 'failed_to_load_order_details'.tr);
        },
      );
    } catch (e) {
      errorMessage.value = 'failed_to_process_order_details'.tr;
      commonToast(type: AppSnackBarType.error, 'failed_to_process_order_details'.tr);
      AppLog.d('❌ getOrderDetailData Error: $e');
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
            orderDetail!.orderStatusText = _getStatusText(deliveredStatus);
          }

          resetPagination();
          await getOrderData(1);
          commonToast(type: AppSnackBarType.success, 'order_status_updated_successfully'.tr);
        },
        onFailure: (reason, message, validationErrors) async {
          success = false;
          commonToast(type: AppSnackBarType.error, 'failed_to_update_order_status'.tr);
        },
      );
    } catch (e) {
      success = false;
      commonToast(type: AppSnackBarType.error, 'failed_to_update_order_status'.tr);
      AppLog.d('❌ updateOrderStatus Error: $e');
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
      final result = await orderRepository.createNote(
        orderId: orderId,
        noteType: noteType,
        note: note,
      );

      result.fold(
        onSuccess: (data) {
          success = true;
          commonToast(type: AppSnackBarType.success, 'order_note_added_successfully'.tr);
        },
        onFailure: (reason, message, validationErrors) {
          success = false;
          commonToast(type: AppSnackBarType.error, 'failed_to_add_order_note'.tr);
        },
      );
    } catch (e) {
      success = false;
      commonToast(type: AppSnackBarType.error, 'failed_to_add_order_note'.tr);
      AppLog.d('❌ createOrderNote Error: $e');
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
      final result = await orderRepository.deleteNote(
        orderId: orderId,
        noteId: noteId,
      );

      result.fold(
        onSuccess: (data) {
          success = true;
          commonToast(type: AppSnackBarType.success, 'order_note_deleted_successfully'.tr);
        },
        onFailure: (reason, message, validationErrors) {
          success = false;
          commonToast(type: AppSnackBarType.error, 'failed_to_delete_order_note'.tr);
        },
      );
    } catch (e) {
      success = false;
      commonToast(type: AppSnackBarType.error, 'failed_to_delete_order_note'.tr);
      AppLog.d('❌ deleteOrderNote Error: $e');
    } finally {
      isDeletingOrderNote.value = false;
    }

    return success;
  }

  // ==================== Delete Order ====================

  Future<void> deleteOrderData({required String orderId}) async {
    isDeletingOrder.value = true;

    try {
      final result = await orderRepository.deleteOrderData(orderId);

      result.fold(
        onSuccess: (data) {
          commonToast(type: AppSnackBarType.success, 'order_deleted_successfully'.tr);
          orderList.removeWhere((element) => element.id.toString() == orderId);
          isDataAvailable.value = orderList.isNotEmpty;
          resetPagination();
          getOrderData(1);
        },
        onFailure: (reason, message, validationErrors) {
          commonToast(type: AppSnackBarType.error, 'failed_to_delete_order'.tr);
        },
      );
    } catch (e) {
      commonToast(type: AppSnackBarType.error, 'failed_to_delete_order'.tr);
      AppLog.d('❌ deleteOrderData Error: $e');
    } finally {
      isDeletingOrder.value = false;
    }
  }

  void fillCustomerShippingData(
      CustomerData customer,
      List<CityModel> cities,
      ) {
    fillShippingFromCustomer(customer);

    final customerStateName =
    (customer.city ?? '').trim().toLowerCase();

    final matchedCity = cities.firstWhereOrNull(
          (city) =>
      city.name.trim().toLowerCase() == customerStateName,
    );

    if (matchedCity != null) {
      selectedCityId.value = matchedCity.id.toString();
      selectedCityName.value = matchedCity.name;
    } else {
      selectedCityId.value = '';
      selectedCityName.value = customer.city ?? '';
    }
  }
}