// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/screen/auth/login_widget.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../network_dio/network_dio.dart';

class ProfileController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  RxBool isOldPassword = true.obs;
  RxBool isPassword = true.obs;
  RxBool isConfirmPassword = true.obs;

  final ImagePicker picker = ImagePicker();
  File? postImage;
  RxString selectedImagePath = ''.obs;

  pickImage(ImageSource imageSource) async {
    XFile? pickedImage = await picker.pickImage(source: imageSource);
    if (pickedImage != null) {
      postImage = File(pickedImage.path);
      selectedImagePath.value = pickedImage.path;
      Get.back();
      print("==== Image Picked: $postImage");
    } else {
      commonToast('Image Not Picked');
    }
  }

  editProfile({
    required String name,
    required String email,
    required String imagePath,
  }) async {
    Loader.showLoader();
    try {
      String url = API.baseUrl + API.editProfileUrl;
      print(" URL===> $url");

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
        'store_id': Prefs.getStoreID(),
        'user_id': Prefs.getUserID(),
        'name': name,
        'email': email
      });

      if (postImage != null && postImage!.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('profile_image', imagePath));
      }

      request.headers.addAll({
        "Authorization": 'Bearer ${Prefs.getToken()}',
        HttpHeaders.cacheControlHeader: "no-cache",
      });

      http.StreamedResponse response = await request.send();
      var responseData = await response.stream.bytesToString();
      var decodedData = jsonDecode(responseData);

      print("Response Status: ${response.statusCode}");
      print("Response Body: $decodedData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodedData['status'] == 1 || decodedData['success'] == true) {
          commonToast(decodedData['data']?['message'] ?? decodedData['message'] ?? "Profile Updated Successfully");
        } else {
          commonToast(decodedData['data']?['message'] ?? decodedData['message'] ?? "Update Failed");
        }
      } else if (response.statusCode == 401) {
        await Prefs.clear();
        Get.offAll(() => NormalLoginWidget());
      } else {
        commonToast(decodedData['data']?['message'] ?? decodedData['message'] ?? "Something went wrong");
      }
    } catch (e) {
      print("Error in editProfile: $e");
      commonToast("Failed to update profile. Check your connection.");
    } finally {
      Loader.hideLoader();
    }
  }

  updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    Loader.showLoader();

    String endPoint = API.updatePasswordUrl;

    final result = await NetworkHttps.postRequest(endPoint, {
      'store_id': Prefs.getStoreID(),
      'user_id': Prefs.getUserID(),
      'old_password': oldPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword
    });

    result.fold(
      onSuccess: (data) {
        Loader.hideLoader();
        if (data['status'] == 1 || data['success'] == true) {
          commonToast(data['data']?['message'] ?? data['message'] ?? "Password Updated Successfully");
          oldPasswordController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          Get.back();
        } else {
          commonToast(data['data']?['message'] ?? data['message'] ?? "Failed to update password");
        }
      },
      onFailure: (reason, message, validationErrors) {
        Loader.hideLoader();
        commonToast(message);

      },
    );
  }
}