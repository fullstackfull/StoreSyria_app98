import 'package:get/get.dart';
import 'package:store_go_app/config/repository/customer_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';
import '../../model/customer_model.dart';
import '../../model/customer_orders_model.dart';


class CustomerController extends GetxController implements StoreAware {

  static const String _cacheCustomerKey = 'home_customer_list_data';

  CustomerRepository customerRepository = CustomerRepository();

  CustomerModel? customerModel;

  RxList<CustomerData> customerList = <CustomerData>[].obs;

  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isDataAvailable = false.obs;
  RxBool isLoading = false.obs;
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

  @override
  void onInit() {
    super.onInit();

    _loadCachedCustomers();

    StoreChangeService.instance.register(() => this);
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

  // =========================
  // ADD CUSTOMER
  // =========================

  Future<void> addCustomerData({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    int status = 1,
  }) async {
    if (isDataAvailable.value) return;

    isDataAvailable.value = true;

    final response = await customerRepository.addCustomerData(
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'status': status,
        'mobile': mobile,
        'password': password,
      },
    );

    isDataAvailable.value = false;

    response.fold(
      onSuccess: (data) async {
        if (data['status'] == 1) {
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