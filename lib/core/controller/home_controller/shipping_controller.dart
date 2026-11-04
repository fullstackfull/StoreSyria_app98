import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/shipping_repository.dart';
import 'package:store_go_app/core/model/shipping_model.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/utils/app_log.dart';

class ShippingController extends GetxController {
  ShippingRepository shippingRepository = ShippingRepository();
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  ShippingModel? categoriesModel;
  RxList<ShippingData> shippingList = <ShippingData>[].obs;
  RxString imageBaseUrl = ''.obs;
  RxString chargesType = 'Flat'.obs;
  List chargesTypeList = ['Flat', "Percentage"];
  RxString filePath = ''.obs;
  RxString imagePath = ''.obs;
  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;

  /* P2.5. THE SCREEN HAD NOTHING TO BRANCH ON, which is why in-flight, empty and failed all
     painted the same blank area under the "Shipping" heading. These two are the same pair
     `TaxController` already declares (tax_controller.dart:19 and :30) and `tax_screen` already
     branches on; nothing here is invented. */
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      AppLog.d("-=-=-=-=---------->  ${file.path}");
      return file.path;
    } else {
      // User canceled the picker
      commonToast(type: AppSnackBarType.info, 'File not pick');
    }
  }

  getShippingData(page) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await shippingRepository.getShippingData(page);

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        shippingList.clear();

        if (data['status'] == 1) {
          categoriesModel = ShippingModel.fromJson(data);
          shippingList.value = categoriesModel?.data?.data ?? [];
          shippingList.refresh();

          if (currantPage.value == categoriesModel?.data?.lastPage) {
            isScroll.value = false;
          }
        } else {
          /* THE REFUSAL MUST SET AN ERROR, and this is the line that stops the new empty state
             lying. `shippingList.clear()` above runs BEFORE this status check, so a refusal always
             arrives with an empty list — indistinguishable from a merchant who has no shipping
             methods. Until now that painted a blank area; with an `EmptyState` wired it would
             assert "no shipping methods found", announced to a screen reader, to a merchant who
             has several. */
          errorMessage.value = data['message'] ?? 'connection_failed'.tr;
          commonToast(type: AppSnackBarType.error, data['message'] ?? '');
        }
      },
      onFailure: (reason, message, errors) {
        // `Failure.message` is a non-nullable String (result.dart:73) and is already translated at
        // construction, so no `??` and no second `.tr`.
        errorMessage.value = message;
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }

  addShippingData({
    required bool isUpdate,
    required String shippingId,
    required String name,
    required String description,
  }) async {
    final response = await shippingRepository.addShippingData(
      isUpdate: isUpdate,
      shippingId: shippingId,
      name: name,
      description: description,
    );

    response.fold(
      onSuccess: (data) {
        /* WS K. THE BACKEND REFUSES AT HTTP 200, so a refusal lands HERE, not in
         `onFailure`. Without this the merchant got a green "saved" for an
         operation the server declined. */
        if (apiRefused(data)) {
          commonToast(
            type: AppSnackBarType.error,
            apiMessage(data, fallback: 'error_occurred'.tr),
          );
          return;
        }

        commonToast(
          type: AppSnackBarType.success,
          apiMessage(data, fallback: ''),
        );
        getShippingData(currantPage.value);
      },
      onFailure: (reason, message, errors) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }

  deleteShippingData({required String shippingId}) async {
    final response = await shippingRepository.deleteShippingData(shippingId);

    response.fold(
      onSuccess: (data) {
        /* WS K. THE BACKEND REFUSES AT HTTP 200, so a refusal lands HERE, not in
         `onFailure`. Without this the merchant got a green "Deleted" for an
         operation the server declined. */
        if (apiRefused(data)) {
          commonToast(
            type: AppSnackBarType.error,
            apiMessage(data, fallback: 'error_occurred'.tr),
          );
          return;
        }

        commonToast(type: AppSnackBarType.success, data['message'] ?? '');
        getShippingData(currantPage.value);
      },
      onFailure: (reason, message, errors) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }
}
