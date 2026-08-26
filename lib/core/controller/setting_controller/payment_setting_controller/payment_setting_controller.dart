// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/payment_setting_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

class PaymentSettingController extends GetxController {
  final PaymentSettingRepository paymentSettingRepository =
  PaymentSettingRepository();

  final TextEditingController currencyController =
  TextEditingController();

  final TextEditingController currencySymbolController =
  TextEditingController();

  RxString codDescription = ''.obs;
  RxString codImage = ''.obs;
  RxString isCodEnabled = 'on'.obs;

  Future<void> getCodPaymentData() async {
    Loader.showLoader();

    try {
      final response =
      await paymentSettingRepository.getCodPaymentData();

      if (response != null) {
        // Success<T> يحتوي على البيانات
        final data = response.data;

        if (data != null && data['status'] == 1) {
          final responseData =
          data['data'] as Map<String, dynamic>?;

          if (responseData != null) {
            currencyController.text =
                responseData['CURRENCY_NAME']?.toString() ?? '';

            currencySymbolController.text =
                responseData['CURRENCY']?.toString() ?? '';

            codDescription.value =
                responseData['cod_info']?.toString() ?? '';

            isCodEnabled.value =
                responseData['is_cod_enabled']?.toString() ?? 'on';

            codImage.value =
                responseData['cod_image']?.toString() ?? '';
          }
        } else {
          commonToast(
            data?['message']?.toString() ??
                'Something went wrong',
          );
        }
      }
    } catch (e) {
      debugPrint(
        'getCodPaymentData ERROR: $e',
      );

      commonToast(
        'Something went wrong',
      );
    } finally {
      // إغلاق Loader دائماً حتى لو صار Exception
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    currencyController.dispose();
    currencySymbolController.dispose();
    super.onClose();
  }
}