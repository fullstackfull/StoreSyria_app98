// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/screen/auth/login_widget.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../network_dio/network_dio.dart';
import '../../../utils/pick_file.dart';

class ProfileController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  RxBool isOldPassword = true.obs;
  RxBool isPassword = true.obs;
  RxBool isConfirmPassword = true.obs;

  RxString selectedImagePath = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isLoading2 = false.obs;

  Future<void> pickImage() async {
    final String? path =
    await FileHelper.pickImage();

    if (path != null) {
      selectedImagePath.value = path;

    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading.value = true;

    try {
      final String endPoint = API.updatePasswordUrl;

      final result = await NetworkHttps.postRequest(
        endPoint,
        {
          'store_id': Prefs.getStoreID(),
          'user_id': Prefs.getUserID(),
          'old_password': oldPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      result.fold(
        onSuccess: (data) {
          if (data['status'] == 1 ||
              data['success'] == true) {
            commonToast(
              type: AppSnackBarType.success,
              data['data']?['message'] ??
                  data['message'] ??
                  "Password Updated Successfully",
            );

            oldPasswordController.clear();
            passwordController.clear();
            confirmPasswordController.clear();

            Get.back();
          } else {
            commonToast(
              type: AppSnackBarType.error,
              data['data']?['message'] ??
                  data['message'] ??
                  "Failed to update password",
            );
          }
        },
        onFailure: (
            reason,
            message,
            validationErrors,
            ) {
          commonToast(
            type: AppSnackBarType.error,
            message,
          );
        },
      );
    } catch (e) {
      print("Error in updatePassword: $e");

      commonToast(
        type: AppSnackBarType.error,
        "Failed to update password. Check your connection.",
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> editProfile({
    required String name,
    required String email,
    required String imagePath,
  }) async {
    isLoading2.value = true;

    try {
      final String url = API.baseUrl + API.editProfileUrl;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.fields.addAll({
        'store_id': Prefs.getStoreID(),
        'user_id': Prefs.getUserID(),
        'name': name,
        'email': email,
      });

      if (imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            imagePath,
          ),
        );
      }

      request.headers.addAll({
        "Authorization": 'Bearer ${Prefs.getToken()}',
        "Cache-Control": "no-cache",
      });

      final response = await request.send();

      final responseData = await response.stream.bytesToString();
      final decodedData = jsonDecode(responseData);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (decodedData['status'] == 1 ||
            decodedData['success'] == true) {
          commonToast(
            type: AppSnackBarType.success,
            decodedData['data']?['message'] ??
                decodedData['message'] ??
                "Profile Updated Successfully",
          );

          selectedImagePath.value = '';
        } else {
          commonToast(
            type: AppSnackBarType.error,
            decodedData['data']?['message'] ??
                decodedData['message'] ??
                "Update Failed",
          );
        }
      } else if (response.statusCode == 401) {
        await Prefs.clear();

        Get.offAll(() => NormalLoginWidget());
      } else {
        commonToast(
          type: AppSnackBarType.error,
          decodedData['data']?['message'] ??
              decodedData['message'] ??
              "Something went wrong",
        );
      }
    } catch (e) {
      print("Error in editProfile: $e");

      commonToast(
        type: AppSnackBarType.error,
        "Failed to update profile. Check your connection.",
      );
    } finally {
      isLoading2.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
}
