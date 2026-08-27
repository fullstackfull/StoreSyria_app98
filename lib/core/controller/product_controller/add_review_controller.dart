import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/review_repository.dart';
import 'package:store_go_app/core/model/get_user_review_model.dart';
import 'package:store_go_app/core/model/review_model.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

class AddReviewController extends GetxController {
  ReviewRepository reviewRepository = ReviewRepository();
  TextEditingController nameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxList<Users> userList = <Users>[].obs;
  RxString userValue = ''.obs;
  RxString userId = ''.obs;
  RxDouble rate = 4.0.obs;
  RxBool isStatus = true.obs;
  RxString status = '1'.obs;
  RxString imageBaseUrl = ''.obs;
  GetReviewUser? getReviewUser;
  ReviewModel? reviewModel;
  RxList<ReviewData> reviewList = <ReviewData>[].obs;

  @override
  void onInit() {
    super.onInit();
    userId.value = Prefs.getUserID() ?? '';

    userValue.value = Prefs.getString("name") ?? '';
  }

  Future<void> getReviewUserData() async {
   // Loader.showLoader();

    final response = await reviewRepository.getReviewUserData();

    //Loader.hideLoader();

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          reviewModel = ReviewModel.fromJson(data);

          reviewList.assignAll(reviewModel?.data ?? []);

          imageBaseUrl.value = Prefs.getString(AppConstant.imageUrl);
        } else {
          reviewList.clear();
          imageBaseUrl.value = Prefs.getString(AppConstant.imageUrl);
        }
      },
      onFailure: (reason, message, validationErrors) {
        //commonToast(message);
      },
    );
  }

  Future<void> getReviewData(String id) async {
    //Loader.showLoader();

    final response = await reviewRepository.getReviewData(id);

    //Loader.hideLoader();

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          reviewModel = ReviewModel.fromJson(data);

          reviewList.assignAll(reviewModel?.data ?? []);

          imageBaseUrl.value = Prefs.getString(AppConstant.imageUrl);
        } else {
          // commonToast(data['data']?['message'] ?? "Error");
        }
      },
      onFailure: (reason, message, validationErrors) {
        //commonToast(message);
      },
    );
  }

  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 30) {
      return '${(diff.inDays / 30).toStringAsFixed(0)} months ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} seconds ago';
    } else {
      return 'just now';
    }
  }

  Future<void> changeReviewData(
      int reviewId, {
        required String productId,
      }) async {
    Loader.showLoader();

    final response =
    await reviewRepository.changeReviewStatus(reviewId);

    Loader.hideLoader();

    response.fold(
      onSuccess: (data) {
        commonToast(
          data['data']?['message'] ??
              data['message'] ??
              "Success",
        );

        getReviewData(productId);
      },
      onFailure: (reason, message, validationErrors) {
        commonToast(message);
      },
    );
  }


  Future<void> deleteReviewData({
    required String reviewId,
    required String productId,
  }) async {
    Loader.showLoader();

    final response = await reviewRepository.deleteReviewData(reviewId);

    Loader.hideLoader();

    response.fold(
      onSuccess: (data) async {
        commonToast(
          data['data']?['message'] ??
              data['message'] ??
              "Deleted",
        );

        await getReviewData(productId);
      },
      onFailure: (reason, message, validationErrors) {
        commonToast(message);
      },
    );
  }
  Future<void> addReview({
    required bool isUpdate,
    required String userId,
    required String id,
    required String reviewId,
    required String title,
    required String description,
    required String categoryId,
    required String productId,
    required String rating,
    required String status,
  }) async {
    Loader.showLoader();

    final response = await reviewRepository.addReviewData(
      isUpdate: isUpdate,
      userId: userId,
      id: id,
      title: title,
      reviewId: reviewId,
      description: description,
      categoryId: categoryId,
      productId: productId,
      rating: rating,
      status: status,
    );

    Loader.hideLoader();

    response.fold(
      onSuccess: (data) {
        commonToast(
          data['data']?['message'] ??
              data['message'] ??
              "Success",
        );

        clear();

        Get.back();

        getReviewData(productId);
      },
      onFailure: (reason, message, validationErrors) {
        commonToast(message);
      },
    );
  }

  clear() {
    nameController.clear();
    titleController.clear();
    descriptionController.clear();
  }
}
