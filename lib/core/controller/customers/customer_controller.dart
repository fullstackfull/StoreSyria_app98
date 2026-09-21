import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/customer_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';
import '../../../config/repository/search_repository.dart';
import '../../model/customer_model.dart';
import '../../model/customer_orders_model.dart';

class CustomerController extends GetxController implements StoreAware {

static const String _cacheCustomerKey = 'home_customer_list_data';

 SearchRepository searchRepository = SearchRepository();
  CustomerRepository customerRepository = CustomerRepository();

final TextEditingController searchController = TextEditingController();
  CustomerModel? customerModel;
  CustomerCityModel? customerCityModel;
  RxList<CustomerData> customerList = <CustomerData>[].obs;
  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isDataAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxBool isLoading2 = false.obs;
  RxBool isPageLoading = false.obs;
  RxString errorMessage = ''.obs;
  CustomerOrdersModel? customerOrdersModel;
  Rx<CustomerProfile?> customerProfile = Rx<CustomerProfile?>(null);
  RxList<CustomerOrder> customerOrdersList = <CustomerOrder>[].obs;
  RxInt customerOrdersCurrentPage = 1.obs;
  RxBool isCustomerOrdersScroll = true.obs;
  RxBool isCustomerOrdersLoading = false.obs;
  RxBool isCustomerOrdersPageLoading = false.obs;
  RxString customerOrdersErrorMessage = ''.obs;
  RxList<CustomerData> searchResults = <CustomerData>[].obs;
  RxBool isSearchingCustomers = false.obs;
  RxBool isCustomerSearchActive = false.obs;
  Timer? _searchDebounce;


@override
  void onInit() {
    super.onInit();
    _loadCachedCustomers();
    StoreChangeService.instance.register(() => this);
  }


  void onCustomerSearchChanged(String value) {
  _searchDebounce?.cancel();

  final query = value.trim();

  if (query.length < 3) {
    clearCustomerSearch();
    return;
  }

  _searchDebounce = Timer(
    const Duration(milliseconds: 600),
        () {
      searchCustomerData(name: query);
    },
  );
}

  Future<void> searchCustomerData({
    required String name,
  }) async {
    final searchText = name.trim();

    if (searchText.length < 3) {
      clearCustomerSearch();
      return;
    }

    isCustomerSearchActive.value = true;
    isSearchingCustomers.value = true;

    try {
      final response =
      await customerRepository.searchCustomerData(searchText);

      response.fold(
        onSuccess: (data) {
          searchResults.clear();

          if (data['status'] == 1) {
            final responseData = data['data'];

            if (responseData is Map) {
              final customers = responseData['customers'];

              if (customers is List) {
                searchResults.assignAll(
                  customers.map((item) {
                    final json = Map<String, dynamic>.from(item);

                    final firstName =
                        json['first_name']?.toString() ?? '';

                    final lastName =
                        json['last_name']?.toString() ?? '';

                    final phone =
                        json['phone']?.toString() ?? '';

                    return CustomerData(
                      id: json['id'] is int
                          ? json['id']
                          : int.tryParse(
                        json['id']?.toString() ?? '',
                      ),

                      email: json['email']?.toString(),

                      customerInfo: CustomerInfo(
                        name: '$firstName $lastName'.trim(),
                        mobile: phone,
                      ),

                      status: json['status'] is int
                          ? json['status']
                          : int.tryParse(
                        json['status']?.toString() ?? '',
                      ),
                    );
                  }).toList(),
                );
              }
            }
          } else {
            commonToast(
              data['data']?['message'] ??
                  data['message'] ??
                  'Error',
            );
          }
        },

        onFailure: (
            reason,
            message,
            validationErrors,
            ) {
          searchResults.clear();

          commonToast(
            message.isNotEmpty
                ? message
                : 'search_failed'.tr,
          );
        },
      );
    } catch (e) {
      searchResults.clear();

      commonToast(e.toString());
    } finally {
      isSearchingCustomers.value = false;
    }
  }


void clearCustomerSearch() {
  _searchDebounce?.cancel();
  isCustomerSearchActive.value = false;
  isSearchingCustomers.value = false;
  searchResults.clear();
}

  // =========================
  // CACHE
  // =========================

  void _loadCachedCustomers() {
    final cached =
    CacheService.get<Map<String, dynamic>>(_cacheCustomerKey);

    if (cached == null) return;

    try {
      customerModel = CustomerModel.fromJson(cached);

      customerList.value =
          customerModel?.data?.customers ?? [];

      isScroll.value =
          customerModel?.data?.pagination?.currentPage !=
              customerModel?.data?.pagination?.lastPage;

    } catch (_) {
      customerModel = null;
    }
  }

  // =========================
  // STORE CHANGE
  // =========================
void resetCustomerSearch() {
  searchController.clear();
  clearCustomerSearch();
}

  @override
  void resetForStoreChange() {
    customerModel = null;

    customerList.clear();

    currantPage.value = 1;
    isScroll.value = true;

    CacheService.clear(_cacheCustomerKey);

    getCustomersData(1);
  }

  // =========================
  // GET CUSTOMERS
  // =========================

  Future<void> getCustomersData(int page) async {

    if (isLoading.value) return;

    isLoading.value = true;

    final response =
    await customerRepository.getCustomersData(page);

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {

        if (data['status'] == 1) {

          customerModel =
              CustomerModel.fromJson(data);

          if (page == 1) {

            customerList.clear();

            CacheService.save(
              _cacheCustomerKey,
              data,
            );
          }

          customerList.addAll(
            customerModel?.data?.customers?? [],
          );

          currantPage.value = page;

          isScroll.value =
              page != customerModel?.data?.pagination?.lastPage;

        } else {

          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );

          if (currantPage.value == page) {
            currantPage.value -= 1;
          }
        }
      },

      onFailure: (
          reason,
          message,
          validationErrors,
          ) {

        errorMessage.value = message;

        commonToast(message);

        if (currantPage.value == page) {
          currantPage.value -= 1;
        }
      },
    );
  }


  Future<void> getStatesData() async {

    if (isLoading2.value) return;

    isLoading2.value = true;

    final response =
    await customerRepository.getStatesData();

    isLoading2.value = false;

    response.fold(
      onSuccess: (data) {

        if (data['status'] == 1) {
          customerCityModel = CustomerCityModel.fromJson(data);

        } else {
          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
        }
      },
      onFailure: (
          reason,
          message,
          validationErrors,
          ) {
        errorMessage.value = message;
        commonToast(message);
      },
    );
  }

  // =========================
  // ADD CUSTOMER
  // =========================

  Future<bool> addCustomerData({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    int status = 1,

    // Address
    required String address,
    required String stateId,
    required String postcode,
    required String addressTitle,
    int isDefault = 1,
    String deliveryInstructions = '',
    required String addressType,
  }) async {
    if (isDataAvailable.value) return false;

    isDataAvailable.value = true;

    try {
      final response = await customerRepository.addCustomerData(
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'status': status,
          'mobile': mobile,
          'password': password,
          'address': address,
          'country_id': 215,
          'state_id': stateId,
          'postcode': postcode,
          'address_title': addressTitle,
          'is_default': isDefault,
          'delivery_instructions': deliveryInstructions,
          'address_type': addressType,
        },
      );

      bool success = false;

      await response.fold(
        onSuccess: (data) async {
          if (data['status'] == 1) {
            success = true;

            commonToast(
              data['data']?['message'] ??
                  data['message'] ??
                  'Customer added successfully',
            );

            customerList.clear();
            currantPage.value = 1;
            isScroll.value = true;
            errorMessage.value = '';

            CacheService.clear(_cacheCustomerKey);

            await getCustomersData(1);
          } else {
            commonToast(
              type: AppSnackBarType.error,
              data['data']?['message'] ??
                  data['message'] ??
                  'Error',
            );
          }
        },

        onFailure: (
            reason,
            message,
            validationErrors,
            ) {
          errorMessage.value = message;

          commonToast(type: AppSnackBarType.error,message);
        },
      );

      return success;
    } catch (e) {
      errorMessage.value = e.toString();

      commonToast(
        type: AppSnackBarType.error,
        "error"
      );

      return false;
    } finally {
      isDataAvailable.value = false;
    }
  }

Future<bool> updateCustomerData({
  required String customerId,
  required String firstName,
  required String lastName,
  required String email,
  required String mobile,
  String password = '',
  int status = 1,

  required String address,
  required String cityId,
  String deliveryInstructions = '',
  int type = 1,
}) async {
  if (isDataAvailable.value) return false;

  isDataAvailable.value = true;

  try {
    final Map<String, dynamic> data = {
      'customer_id': customerId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'status': status,
      'address': address,
      'city_id': cityId,
      'delivery_instructions': deliveryInstructions,
      'type': type,
    };

    if (password.trim().isNotEmpty) {
      data['password'] = password.trim();
    }

    final response = await customerRepository.updateCustomerData(
      customerId: customerId,
      data: data,
    );

    bool success = false;

    await response.fold(
      onSuccess: (data) async {
        if (data['status'] == 1) {
          success = true;

          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Customer updated successfully',
          );

          CacheService.clear(_cacheCustomerKey);

          customerList.clear();
          currantPage.value = 1;
          isScroll.value = true;
          errorMessage.value = '';

          await getCustomersData(1);
        } else {
          commonToast(
            type: AppSnackBarType.error,
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
        }
      },
      onFailure: (
          reason,
          message,
          validationErrors,
          ) {
        errorMessage.value = message;

        commonToast(
          type: AppSnackBarType.error,
          message,
        );
      },
    );

    return success;
  } catch (e) {
    errorMessage.value = e.toString();

    commonToast(
      type: AppSnackBarType.error,
      'error',
    );

    return false;
  } finally {
    isDataAvailable.value = false;
  }
}

  Future<void> deleteCustomerData({
    required String customerId,
  }) async {
    final response =
    await customerRepository.deleteCustomerData(
      customerId: customerId,
    );

    response.fold(
      onSuccess: (data) async {
        commonToast(
          data['data']?['message'] ??
              data['message'] ??
              'Deleted',
        );

        customerList.clear();
        currantPage.value = 1;
        isScroll.value = true;

        CacheService.clear(_cacheCustomerKey);

        await getCustomersData(1);
      },

      onFailure: (
          reason,
          message,
          validationErrors,
          ) {
        errorMessage.value = message;
        commonToast(message);
      },
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }


  void clearCustomerOrders() {
    customerOrdersModel = null;
    customerProfile.value = null;
    customerOrdersList.clear();
    customerOrdersCurrentPage.value = 1;
    isCustomerOrdersScroll.value = true;
    isCustomerOrdersLoading.value = false;
    isCustomerOrdersPageLoading.value = false;
    customerOrdersErrorMessage.value = '';
  }

  Future<void> getCustomerOrdersData({
    required String customerId,
    required int page,
  }) async {
    if (page == 1) {
      if (isCustomerOrdersLoading.value) return;

      isCustomerOrdersLoading.value = true;
      customerOrdersErrorMessage.value = '';
    } else {
      if (isCustomerOrdersPageLoading.value) return;
      if (!isCustomerOrdersScroll.value) return;

      isCustomerOrdersPageLoading.value = true;
    }

    try {
      final response = await customerRepository.getCustomerOrdersData(
        customerId: customerId,
        page: page,
      );

      response.fold(
        onSuccess: (data) {
          if (data['status'] == 1) {
            final model = CustomerOrdersModel.fromJson(data);

            customerOrdersModel = model;

            if (page == 1) {
              customerOrdersList.clear();
            }

            if (model.data?.customer != null) {
              customerProfile.value = model.data!.customer;
            }

            final orders = model.data?.orders ?? [];

            if (orders.isNotEmpty) {
              customerOrdersList.addAll(orders);
            }

            final pagination = model.data?.pagination;

            customerOrdersCurrentPage.value =
                pagination?.currentPage ?? page;

            if (pagination != null) {
              if (pagination.hasMore != null) {
                isCustomerOrdersScroll.value = pagination.hasMore!;
              } else if (
              pagination.currentPage != null &&
                  pagination.lastPage != null
              ) {
                isCustomerOrdersScroll.value =
                    pagination.currentPage! < pagination.lastPage!;
              } else {
                isCustomerOrdersScroll.value = false;
              }
            } else {
              isCustomerOrdersScroll.value = false;
            }

            customerOrdersErrorMessage.value = '';
          } else {
            final msg = data['data']?['message'] ??
                data['message'] ??
                'Error';

            customerOrdersErrorMessage.value = msg.toString();
            commonToast(msg.toString());
          }
        },
        onFailure: (
            reason,
            message,
            validationErrors,
            ) {
          if (page == 1) {
            customerOrdersErrorMessage.value = message;
          }

          commonToast(message);
        },
      );
    } catch (e) {
      customerOrdersErrorMessage.value = e.toString();
      commonToast(e.toString());
    } finally {
      if (page == 1) {
        isCustomerOrdersLoading.value = false;
      } else {
        isCustomerOrdersPageLoading.value = false;
      }
    }
  }
}