import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/payment_setting_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

class PaymentSettingController extends GetxController {
  PaymentSettingRepository paymentSettingRepository =
      PaymentSettingRepository();

  TextEditingController currencyController = TextEditingController();
  TextEditingController currencySymbolController = TextEditingController();
  RxString codDescription = ''.obs;
  RxString codImage = ''.obs;
  RxString isCodEnabled = 'on'.obs;

  getCodPaymentData() async {
    Loader.showLoader();
    var response = await paymentSettingRepository.getCodPaymentData();
    if (response != null) {
      if (response['status'] == 1) {
        currencyController.text = response['data']['CURRENCY_NAME'];
        currencySymbolController.text = response['data']['CURRENCY'];
        codDescription.value = response['data']['cod_info'];
        isCodEnabled.value = response['data']['is_cod_enabled'];
        codImage.value = response['data']['cod_image'];
      } else {
        commonToast(response['data']['message']);
      }
    }
    Get.back();
  }
}
