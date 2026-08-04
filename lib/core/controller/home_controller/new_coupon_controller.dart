import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:store_go_app/config/repository/coupon_repository.dart';
import 'package:store_go_app/core/model/coupon_model.dart';
import 'package:store_go_app/core/model/view_used_coupon_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class NewCouponController extends GetxController {
  CouponRepository couponRepository = CouponRepository();

  CouponModel? couponModel;
  ViewUsedCouponModel? viewUsedCouponModel;

  RxList<CouponData> couponsList = <CouponData>[].obs;
  RxList<ViewUsedCouponData> viewCouponsList = <ViewUsedCouponData>[].obs;

  TextEditingController couponNameController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController limitController = TextEditingController();
  TextEditingController expDateController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  RxBool isFlat = true.obs;
  RxBool isStatus = true.obs;

  RxBool isLoading = false.obs;
  RxBool isDeleteLoading = false.obs;

  RxBool isDataAvailable = false.obs;

  RxString errorMessage = ''.obs;

  RxString couponType = "flat".obs;
  RxString status = "1".obs;

  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;


  pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.themeGreenColor,
              onPrimary: AppColor.cLabel,
              onSurface: AppColor.cLabel,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      expDateController.text =
          DateFormat('yyyy-MM-dd').format(pickedDate);
      update();
    }
  }


  getCouponData(int page) async {

    if(page == 1){
      couponsList.clear();
      isScroll.value = true;
    }

    isLoading.value = true;
    isDataAvailable.value = true;
    errorMessage.value = '';

    final response = await couponRepository.getCouponData(page);

    isLoading.value = false;
    isDataAvailable.value = false;


    response.fold(
      onSuccess: (data){

        if(data['status'] == 1){

          couponModel = CouponModel.fromJson(data);

          final newData = couponModel?.data?.data ?? [];

          if(newData.isNotEmpty){
            couponsList.addAll(newData);
            couponsList.refresh();
          }


          if(currantPage.value >=
              (couponModel?.data?.lastPage ?? 1)){

            isScroll.value = false;

          }else{

            isScroll.value = true;

          }

        }else{

          commonToast(
            data['message'] ?? "Something went wrong",
          );

        }

      },

      onFailure: (reason,message,errors){

        errorMessage.value =
            message ?? "Connection error";

        commonToast(
            message ?? "Connection error"
        );

        isScroll.value = true;

      },
    );
  }



  getUsedCouponData(int couponId) async {

    isLoading.value = true;

    final response =
    await couponRepository.getUsedCouponData(couponId);

    isLoading.value = false;


    response.fold(
      onSuccess: (data){

        if(data['status'] == 1){

          viewUsedCouponModel =
              ViewUsedCouponModel.fromJson(data);

          viewCouponsList.value =
              viewUsedCouponModel?.data ?? [];

          viewCouponsList.refresh();

        }else{

          commonToast(
            data['data']['message'] ??
                "No data found",
          );

        }

      },

      onFailure: (reason,message,errors){

        commonToast(
          message ?? "Error loading data",
        );

      },
    );
  }



  generateCodeData() async {

    isLoading.value = true;

    final response =
    await couponRepository.generateCodeData();

    isLoading.value = false;


    response.fold(
      onSuccess: (data){

        log("response ---> $data");

        if(data['status']==1){
          couponController.text =
          data['data'];
        }

      },

      onFailure: (reason,message,errors){

        commonToast(
          message ?? "Error generating code",
        );

      },
    );
  }



  addCoupon({
    required bool isUpdate,
    required String couponId,
    required String couponName,
    required String couponType,
    required String disAmount,
    required String couponLimit,
    required String date,
    required String code,

  }) async {


    isLoading.value = true;


    final response =
    await couponRepository.addCouponData(
      isUpdate: isUpdate,
      couponId: couponId,
      couponName: couponName,
      couponType: couponType,
      disAmount: disAmount,
      couponLimit: couponLimit,
      date: date,
      code: code,
    );


    isLoading.value = false;



    response.fold(
      onSuccess: (data){

        if(data['status']==1){

          commonToast(
            data['data']['message'] ??
                "Success",
          );


          couponsList.clear();
          currantPage.value = 1;
          isScroll.value = true;

          getCouponData(currantPage.value);

          clearCouponFields();

          Get.back();

        }else{

          commonToast(
            data['data']['message'] ??
                "Failed",
          );

        }

      },

      onFailure: (reason,message,errors){

        errorMessage.value =
            message ?? "Error adding coupon";

        commonToast(
            message ?? "Error adding coupon"
        );

      },
    );
  }



  deleteCouponData({
    required String couponId,
  }) async {


    isDeleteLoading.value = true;


    final response =
    await couponRepository.deleteCouponData(couponId);



    isDeleteLoading.value = false;



    response.fold(
      onSuccess: (data){

        if(data['status']==1){

          commonToast(
              data['data']['message'] ??
                  "Deleted successfully"
          );


          couponsList.clear();

          currantPage.value = 1;

          isScroll.value = true;

          getCouponData(currantPage.value);



          if(Get.isBottomSheetOpen ?? false){
            Get.back();
          }


        }else{

          commonToast(
              data['data']['message'] ??
                  "Failed"
          );

        }

      },


      onFailure: (reason,message,errors){

        errorMessage.value =
            message ?? "Delete error";

        commonToast(
            message ?? "Delete error"
        );

      },
    );
  }



  void clearCouponFields(){

    couponNameController.clear();
    discountController.clear();
    limitController.clear();
    expDateController.clear();
    couponController.clear();

    isFlat.value = true;
    isStatus.value = true;

    couponType.value = "flat";
    status.value = "1";

  }



  @override
  void onClose() {

    couponNameController.dispose();
    discountController.dispose();
    limitController.dispose();
    expDateController.dispose();
    couponController.dispose();
    searchController.dispose();

    super.onClose();
  }
}