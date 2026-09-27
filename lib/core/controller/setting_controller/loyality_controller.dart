import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/loyalty_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class LoyaltyController extends GetxController {
  LoyaltyRepository loyaltyRepository = LoyaltyRepository();
  TextEditingController rewardPointController = TextEditingController();
  RxBool isStatus = true.obs;
  RxBool isLoading = false.obs;
  RxString status = 'on'.obs;
  RxString errorMessage = ''.obs;

  setLoyaltyData({
    required String status,
    required String point,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    final response = await loyaltyRepository.setLoyaltyData(status: status, point: point);
    isLoading.value = false;
    response.fold(
      onSuccess: (data) {
        if(data['status'] == 1) {
          commonToast(type: AppSnackBarType.success, data['data']['message'] ?? 'Success');
        } else {
          commonToast(type: AppSnackBarType.error, data['data']['message'] ?? 'Failed');
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value = message ?? 'Error saving loyalty';
        commonToast(type: AppSnackBarType.error, message ?? 'Error saving loyalty');
      },
    );
  }

  getLoyaltyData() async {
    isLoading.value = true;
    errorMessage.value = '';
    final response = await loyaltyRepository.getLoyaltySettingData();
    isLoading.value = false;
    response.fold(
      onSuccess: (data) {
        if(data['status'] == 1) {
          rewardPointController.text = data['data']['reward_point'] ?? '';
          if(data['data']['loyality_program_enabled'] == "on") {
            isStatus.value = true;
          } else {
            isStatus.value = false;
          }
          status.value = data['data']['loyality_program_enabled'] ?? 'off';
        } else {
          commonToast(type: AppSnackBarType.error, data['data']['message'] ?? 'Failed');
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value = message ?? 'Error loading loyalty';
        commonToast(type: AppSnackBarType.error, message ?? 'Error loading loyalty');
      },
    );
  }

  clearLoyaltyFields() {
    rewardPointController.clear();
    isStatus.value = true;
    status.value = 'on';
  }

  @override
  void onClose() {
    rewardPointController.dispose();
    super.onClose();
  }
}