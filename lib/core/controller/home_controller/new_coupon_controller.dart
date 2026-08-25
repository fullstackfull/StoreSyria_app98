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
  final CouponRepository couponRepository = CouponRepository();

  CouponModel? couponModel;
  ViewUsedCouponModel? viewUsedCouponModel;

  // ============================================================
  // LISTS
  // ============================================================

  final RxList<CouponData> couponsList =
      <CouponData>[].obs;

  final RxList<ViewUsedCouponData> viewCouponsList =
      <ViewUsedCouponData>[].obs;

  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  final TextEditingController couponNameController =
  TextEditingController();

  final TextEditingController discountController =
  TextEditingController();

  final TextEditingController limitController =
  TextEditingController();

  final TextEditingController expDateController =
  TextEditingController();

  final TextEditingController couponController =
  TextEditingController();

  final TextEditingController searchController =
  TextEditingController();

  // ============================================================
  // FORM STATE
  // ============================================================

  RxBool isFlat = true.obs;
  RxBool isStatus = true.obs;

  RxString couponType = "flat".obs;
  RxString status = "1".obs;

  // ============================================================
  // LOADING
  // ============================================================

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isDeleteLoading = false.obs;

  RxBool isDataAvailable = false.obs;

  // ============================================================
  // ERROR
  // ============================================================

  RxString errorMessage = ''.obs;

  // ============================================================
  // PAGINATION
  // ============================================================

  /// الصفحة الحالية
  RxInt currentPage = 1.obs;

  /// آخر صفحة
  RxInt lastPage = 1.obs;

  /// هل يوجد صفحات إضافية؟
  RxBool hasMore = true.obs;

  // ============================================================
  // DATE
  // ============================================================

  Future<void> pickDate(BuildContext context) async {
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

  // ============================================================
  // GET COUPON DATA
  // ============================================================

  Future<void> getCouponData(int page) async {
    // ----------------------------------------------------------
    // منع تكرار الطلب
    // ----------------------------------------------------------

    if (isLoading.value || isLoadingMore.value) {
      return;
    }

    // ----------------------------------------------------------
    // التأكد من وجود صفحة
    // ----------------------------------------------------------

    if (page > lastPage.value && couponsList.isNotEmpty) {
      hasMore.value = false;
      return;
    }

    // ----------------------------------------------------------
    // الصفحة الأولى
    // ----------------------------------------------------------

    if (page == 1) {
      isLoading.value = true;
      isDataAvailable.value = true;

      errorMessage.value = '';

      currentPage.value = 1;
      lastPage.value = 1;
      hasMore.value = true;

      couponsList.clear();
    }

    // ----------------------------------------------------------
    // Pagination
    // ----------------------------------------------------------

    else {
      if (!hasMore.value) {
        return;
      }

      isLoadingMore.value = true;
    }

    try {
      final response =
      await couponRepository.getCouponData(page);

      response.fold(
        onSuccess: (data) {
          if (data['status'] == 1) {
            couponModel =
                CouponModel.fromJson(data);

            final pagination =
                couponModel?.data;

            final newItems =
                pagination?.data ?? [];

            // ----------------------------------------------------
            // ADD DATA
            // ----------------------------------------------------

            if (page == 1) {
              couponsList.assignAll(newItems);
            } else {
              couponsList.addAll(newItems);
            }

            // ----------------------------------------------------
            // PAGINATION DATA
            // ----------------------------------------------------

            currentPage.value =
                pagination?.currentPage ?? page;

            lastPage.value =
                pagination?.lastPage ?? page;

            hasMore.value =
                currentPage.value < lastPage.value;

            couponsList.refresh();

            log(
              'Coupons => page: ${currentPage.value} '
                  '/ lastPage: ${lastPage.value} '
                  '/ hasMore: ${hasMore.value}',
            );
          } else {
            commonToast(
              data['message'] ??
                  "Something went wrong",
            );
          }
        },

        onFailure: (
            reason,
            message,
            errors,
            ) {
          errorMessage.value =
              message ?? "Connection error";

          commonToast(
            message ?? "Connection error",
          );
        },
      );
    } catch (e) {
      log(
        "getCouponData error => $e",
      );

      errorMessage.value =
      "Connection error";

      commonToast(
        "Connection error",
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isDataAvailable.value = false;
    }
  }

  // ============================================================
  // LOAD NEXT PAGE
  // ============================================================

  Future<void> loadNextPage() async {
    if (!hasMore.value) return;

    if (isLoadingMore.value) return;

    if (isLoading.value) return;

    final nextPage =
        currentPage.value + 1;

    await getCouponData(nextPage);
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCoupons() async {
    currentPage.value = 1;
    lastPage.value = 1;
    hasMore.value = true;

    couponsList.clear();

    await getCouponData(1);
  }

  // ============================================================
  // USED COUPONS
  // ============================================================

  Future<void> getUsedCouponData(
      int couponId,
      ) async {
    isLoading.value = true;

    final response =
    await couponRepository.getUsedCouponData(
      couponId,
    );

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          viewUsedCouponModel =
              ViewUsedCouponModel.fromJson(data);

          viewCouponsList.value =
              viewUsedCouponModel?.data ?? [];

          viewCouponsList.refresh();
        } else {
          // commonToast(
          //   data['data']?['message'] ??
          //       "No data found",
          // );
        }
      },

      onFailure: (
          reason,
          message,
          errors,
          ) {
        commonToast(
          message ?? "Error loading data",
        );
      },
    );
  }

  // ============================================================
  // GENERATE COUPON CODE
  // ============================================================

  Future<void> generateCodeData() async {
    isLoading.value = true;

    final response =
    await couponRepository.generateCodeData();

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        log(
          "generate code response => $data",
        );

        if (data['status'] == 1) {
          couponController.text =
          data['data'];
        }
      },

      onFailure: (
          reason,
          message,
          errors,
          ) {
        commonToast(
          message ?? "Error generating code",
        );
      },
    );
  }

  // ============================================================
  // ADD / UPDATE COUPON
  // ============================================================

  Future<void> addCoupon({
    required bool isUpdate,
    required String couponId,
    required String couponName,
    required String couponType,
    required String disAmount,
    required String couponLimit,
    required int status,
    required String date,
    required String code,
  }) async {
    isLoading.value = true;

    final response =
    await couponRepository.addCouponData(
      isUpdate: isUpdate,
      couponId: couponId,
      status: status,
      couponName: couponName,
      couponType: couponType,
      disAmount: disAmount,
      couponLimit: couponLimit,
      date: date,
      code: code,
    );

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          commonToast(
            data['data']?['message'] ??
                "Success",
          );

          clearCouponFields();

          // رجع القائمة من أول صفحة
          awaitRefresh();

          Get.back();
        } else {
          commonToast(
            data['data']?['message'] ??
                "Failed",
          );
        }
      },

      onFailure: (
          reason,
          message,
          errors,
          ) {
        errorMessage.value =
            message ?? "Error adding coupon";

        commonToast(
          message ?? "Error adding coupon",
        );
      },
    );
  }


  Future<void> awaitRefresh() async {
    currentPage.value = 1;
    lastPage.value = 1;
    hasMore.value = true;

    couponsList.clear();

    await getCouponData(1);
  }


  Future<void> deleteCouponData({
    required String couponId,
  }) async {
    isDeleteLoading.value = true;

    final response =
    await couponRepository.deleteCouponData(
      couponId,
    );

    isDeleteLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          commonToast(
            data['data']?['message'] ??
                "Deleted successfully",
          );

          awaitRefresh();

          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          }
        } else {
          commonToast(
            data['data']?['message'] ??
                "Failed",
          );
        }
      },

      onFailure: (
          reason,
          message,
          errors,
          ) {
        errorMessage.value =
            message ?? "Delete error";

        commonToast(
          message ?? "Delete error",
        );
      },
    );
  }

  void clearCouponFields() {
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

  // ============================================================
  // DISPOSE
  // ============================================================

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