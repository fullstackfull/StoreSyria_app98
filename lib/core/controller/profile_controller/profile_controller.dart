import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../network/network.dart';
import '../../../utils/pick_file.dart';
import 'package:store_go_app/utils/app_log.dart';
import 'package:store_go_app/network/result.dart';

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
              apiMessage(data, fallback: "Password Updated Successfully"),
            );

            oldPasswordController.clear();
            passwordController.clear();
            confirmPasswordController.clear();

            Get.back();
          } else {
            commonToast(
              type: AppSnackBarType.error,
              apiMessage(data, fallback: "Failed to update password"),
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
      AppLog.e('Error in updatePassword', error: e);

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

      // R7-N1: was a hand-rolled Bearer map. NetworkHttps.authHeaders() is the
      // single construction site and already sends Cache-Control: no-cache.
      request.headers.addAll(NetworkHttps.authHeaders());

      final response = await request.send();

      final responseData = await response.stream.bytesToString();

      // Status code FIRST, decode second. The body used to be decoded before
      // the status was looked at, so a 401, 429 or 500 whose body is HTML or
      // empty threw out of this block and the 401 branch below never ran --
      // leaving a dead session in local storage. Now that the server really
      // does return 401 and 429, that was the common case, not the edge one.
      final Map<String, dynamic> decodedData =
          _decodeOrEmpty(responseData);

      if (response.statusCode == 401) {
        // One shared forced-logout path, guarded against concurrent 401s.
        await NetworkHttps.handleUnauthorized();
      } else if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (decodedData['status'] == 1 ||
            decodedData['success'] == true) {
          commonToast(
            type: AppSnackBarType.success,
            apiMessage(decodedData, fallback: "Profile Updated Successfully"),
          );

          selectedImagePath.value = '';
        } else {
          commonToast(
            type: AppSnackBarType.error,
            apiMessage(decodedData, fallback: "Update Failed"),
          );
        }
      } else if (response.statusCode == 429) {
        commonToast(
          type: AppSnackBarType.error,
          'too_many_requests'.tr,
        );
      } else {
        commonToast(
          type: AppSnackBarType.error,
          apiMessage(decodedData, fallback: "Something went wrong"),
        );
      }
    } catch (e) {
      AppLog.e('Error in editProfile', error: e);

      commonToast(
        type: AppSnackBarType.error,
        "Failed to update profile. Check your connection.",
      );
    } finally {
      isLoading2.value = false;
    }
  }

  /// Decodes a response body that may not be JSON at all.
  ///
  /// Returns an empty map for an empty body, for HTML (a proxy or web-server
  /// error page), and for a JSON array where an object was expected, so a
  /// changed or unexpected server response degrades to "no message" instead of
  /// throwing past the status-code handling.
  Map<String, dynamic> _decodeOrEmpty(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // fall through
    }

    return <String, dynamic>{};
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
