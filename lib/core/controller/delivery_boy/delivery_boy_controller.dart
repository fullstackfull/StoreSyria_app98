import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/delivery_boy_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';
import '../../model/delivery_boy_model.dart';

class DeliveryBoyController extends GetxController implements StoreAware {

  static const String _cacheDeliveryBoyKey = 'delivery_boy_list_data';

  DeliveryBoyRepository deliveryBoyRepository = DeliveryBoyRepository();

  DeliveryBoyModel? deliveryBoyModel;
  RxList<DeliveryBoyData> deliveryBoyList = <DeliveryBoyData>[].obs;
  RxBool isLoading = false.obs;
  RxBool isDataAvailable = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedDeliveryBoys();
    StoreChangeService.instance.register(() => this);
  }

  // =========================
  // CACHE
  // =========================

  void _loadCachedDeliveryBoys() {
    final cached =
    CacheService.get<Map<String, dynamic>>(_cacheDeliveryBoyKey);

    if (cached == null) return;

    try {
      deliveryBoyModel = DeliveryBoyModel.fromJson(cached);
      deliveryBoyList.value = deliveryBoyModel?.data ?? [];
    } catch (_) {
      deliveryBoyModel = null;
    }
  }

  // =========================
  // STORE CHANGE
  // =========================

  @override
  void resetForStoreChange() {
    deliveryBoyModel = null;
    deliveryBoyList.clear();
    CacheService.clear(_cacheDeliveryBoyKey);
    getDeliveryBoysData();
  }

  // =========================
  // GET DELIVERY BOYS
  // =========================

  Future<void> getDeliveryBoysData() async {
    if (isLoading.value) return;

    isLoading.value = true;

    final response =
    await deliveryBoyRepository.getDeliveryBoysData();

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 'success' || data['status'] == 1) {
          deliveryBoyModel = DeliveryBoyModel.fromJson(data);
          deliveryBoyList.value = deliveryBoyModel?.data ?? [];

          CacheService.save(
            _cacheDeliveryBoyKey,
            data,
          );
        } else {
          commonToast(
            data['message']?.toString() ?? 'Error',
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
  // ADD DELIVERY BOY
  // =========================

  Future<bool> addDeliveryBoyData({
    required String name,
    required String email,
    required String password,
    required String contact,
    required String commissionPercentage,
    required String isCommissionEnabled,
  }) async {
    if (isDataAvailable.value) return false;

    isDataAvailable.value = true;

    try {
      final response = await deliveryBoyRepository.addDeliveryBoyData(
        fields: {
          'name': name,
          'email': email,
          'password': password,
          'contact': contact,
          'commission_percentage': commissionPercentage,
          'is_commission_enabled': isCommissionEnabled,
        },
      );

      bool success = false;

      await response.fold(
        onSuccess: (data) async {
          if (data['status'] == 'success' || data['status'] == 1) {
            success = true;

            deliveryBoyList.clear();
            errorMessage.value = '';

            CacheService.clear(_cacheDeliveryBoyKey);
            Get.back();
            await getDeliveryBoysData();
            commonToast(
              data['message']?.toString() ??
                  'delivery_man_added_successfully'.tr,
            );
          } else {
            commonToast(
              type: AppSnackBarType.error,
              data['message']?.toString() ??
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

          commonToast(type: AppSnackBarType.error, message);
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

  // =========================
  // UPDATE DELIVERY BOY
  // =========================

  Future<bool> updateDeliveryBoyData({
    required String deliveryBoyId,
    required String name,
    required String email,
    required String contact,
    required String commissionPercentage,
    required String isCommissionEnabled,
  }) async {
    if (isDataAvailable.value) return false;

    isDataAvailable.value = true;

    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'contact': contact,
        'commission_percentage': commissionPercentage,
        'is_commission_enabled': isCommissionEnabled,
      };

      final response = await deliveryBoyRepository.updateDeliveryBoyData(
        deliveryBoyId: deliveryBoyId,
        data: data,
      );

      bool success = false;

      await response.fold(
        onSuccess: (data) async {
          if (data['status'] == 'success' || data['status'] == 1) {
            success = true;

            CacheService.clear(_cacheDeliveryBoyKey);

            deliveryBoyList.clear();
            errorMessage.value = '';
            Get.back();
            commonToast(
              data['message']?.toString() ??
                  'Delivery Boy updated successfully',
            );

            await getDeliveryBoysData();

          } else {
            commonToast(
              type: AppSnackBarType.error,
              data['message']?.toString() ??
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

  // =========================
  // DELETE DELIVERY BOY
  // =========================

  Future<void> deleteDeliveryBoyData({
    required String deliveryBoyId,
  }) async {
    final response =
    await deliveryBoyRepository.deleteDeliveryBoyData(
      deliveryBoyId: deliveryBoyId,
    );

    response.fold(
      onSuccess: (data) async {
        commonToast(
          data['message']?.toString() ??
              'Deleted',
        );

        deliveryBoyList.clear();

        CacheService.clear(_cacheDeliveryBoyKey);

        await getDeliveryBoysData();
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
    super.onClose();
  }
}
