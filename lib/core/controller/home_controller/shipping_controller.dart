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

    final response = await shippingRepository.getShippingData(page);

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
          commonToast(type: AppSnackBarType.error, data['message'] ?? '');
        }
        },
      onFailure: (reason, message, errors) {
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
        commonToast(type: AppSnackBarType.success, apiMessage(data, fallback: ''));
        getShippingData(currantPage.value);
      },
      onFailure: (reason, message, errors) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }

  deleteShippingData({required String shippingId}) async {

    final response =
    await shippingRepository.deleteShippingData(shippingId);

    response.fold(
      onSuccess: (data) {
        commonToast(type: AppSnackBarType.success, data['message'] ?? '');
        getShippingData(currantPage.value);
      },
      onFailure: (reason, message, errors) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }
}
