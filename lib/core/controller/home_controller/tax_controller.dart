import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/tax_repository.dart';
import 'package:store_go_app/core/model/tax_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class TaxController extends GetxController {
  TaxRepository taxRepository = TaxRepository();

  TaxModel? taxModel;

  RxList<Tax> taxList = <Tax>[].obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  RxBool isStatus = true.obs;
  RxBool isLoading = false.obs;
  RxBool isDeleteLoading = false.obs;
  RxString chargesType = 'Flat'.obs;
  RxString status = '1'.obs;

  List chargesTypeList = ['Flat', 'Percentage'];

  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;

  RxBool isDataAvailable = false.obs;
  RxString errorMessage = ''.obs;

  getTaxData(int page) async {
    if (page == 1) {
      taxList.clear();
      isScroll.value = true;
    }

    isLoading.value = true;
    isDataAvailable.value = true;
    errorMessage.value = '';

    final response = await taxRepository.getTaxData(page);

    isLoading.value = false;
    isDataAvailable.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          taxModel = TaxModel.fromJson(data);

          final newData = taxModel?.data?.data ?? [];

          if (newData.isNotEmpty) {
            taxList.addAll(newData);
            taxList.refresh();
          }

          if (currantPage.value >= (taxModel?.data?.lastPage ?? 1)) {
            isScroll.value = false;
          } else {
            isScroll.value = true;
          }
        } else {
          commonToast(data['message'] ?? 'Something went wrong');
          if (page < (taxModel?.data?.lastPage ?? 1)) {
            isScroll.value = true;
          }
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value = message ?? 'Connection error';
        commonToast(message ?? 'Connection error');
        isScroll.value = true;
      },
    );
  }

  addTaxData({
    required bool isUpdate,
    required String taxId,
    required String taxName,
    required String type,
    required String taxAmount,
    required String status,
  }) async {
    isLoading.value = true;

    final response = await taxRepository.addTaxData(
      isUpdate: isUpdate,
      taxId: taxId,
      taxName: taxName,
      type: type,
      taxAmount: taxAmount,
      status: status,
    );

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          commonToast(data['data']['message'] ?? 'Success');
          taxList.clear();
          currantPage.value = 1;
          isScroll.value = true;
          getTaxData(currantPage.value);
          clearTaxFields();
          Get.back();
        } else {
          commonToast(data['data']['message'] ?? 'Failed');
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value = message ?? 'Error adding tax';
        commonToast(message ?? 'Error adding tax');
      },
    );
  }

  deleteTaxData({
    required String taxId,
  }) async {
    isDeleteLoading.value = true;

    final response = await taxRepository.deleteTaxData(taxId);

    isDeleteLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          commonToast(data['data']['message'] ?? 'Deleted successfully');
          taxList.clear();
          currantPage.value = 1;
          isScroll.value = true;
          getTaxData(currantPage.value);

          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          }
        } else {
          commonToast(data['data']['message'] ?? 'Failed to delete');
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value = message ?? 'Error deleting tax';
        commonToast(message ?? 'Error deleting tax');
      },
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void clearTaxFields() {
    nameController.clear();
    amountController.clear();

    chargesType.value = 'Flat';
    status.value = '1';
    isStatus.value = true;
  }
}