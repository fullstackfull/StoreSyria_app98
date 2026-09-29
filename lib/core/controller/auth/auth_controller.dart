import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/services/fcm_token_service.dart';
import '../notification_controller/notification_controller.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController newEmailController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController forgotEmailController = TextEditingController();

  RxBool isObscure = true.obs;
  RxBool isLoading = false.obs;


  RxList loginList = [
    {
      'icon': DefaultImages.facebookIcn,
      'title': 'Login with Facebook',
      'isTap': true
    }.obs,
    {
      'icon': DefaultImages.googleIcn,
      'title': 'Login with Google',
      'isTap': false
    }.obs,
    {
      'icon': DefaultImages.appleIcn,
      'title': 'Login with Apple',
      'isTap': false
    }.obs,
  ].obs;
  RxList signUpList = [
    {
      'icon': DefaultImages.facebookIcn,
      'title': 'Login with Facebook',
      'isTap': true
    }.obs,
    {
      'icon': DefaultImages.googleIcn,
      'title': 'Login with Google',
      'isTap': false
    }.obs,
    {
      'icon': DefaultImages.appleIcn,
      'title': 'Login with Apple',
      'isTap': false
    }.obs,
  ].obs;

  clear() {
    emailController.clear();
    passwordController.clear();
    fNameController.clear();
    lNameController.clear();
    newEmailController.clear();
    newPasswordController.clear();
    forgotEmailController.clear();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (Prefs.getToken().isNotEmpty) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> logout() async {
    isLoading.value = true;

    try {
      final token = Prefs.getToken();

      final url = Uri.parse(
        API.baseUrl + API.logoutUrl,
      );

      log('=== LOGOUT URL === $url');

      final response = await http.post(
        url,
        headers: {
          ...NetworkHttps.baseHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      log('=== LOGOUT STATUS === ${response.statusCode}');
      log('=== LOGOUT BODY === ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == 1 ||
            decoded['success'] == true) {
          await _clearLocalSession();

          commonToast(type: AppSnackBarType.success, 
            decoded['message'] ??
                decoded['data']?['message'] ??
                'Logout Successfully',
          );

          Get.offAllNamed(AppRoutes.login);
        } else {
          commonToast(type: AppSnackBarType.error, 
            decoded['message'] ??
                decoded['data']?['message'] ??
                'Logout failed',
          );
        }
      } else {
        commonToast(type: AppSnackBarType.error, 'Logout failed');
      }
    } catch (e) {
      log('=== LOGOUT ERROR === $e');
      commonToast(type: AppSnackBarType.error, 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> loginAuth({required String email, required String password}) async {
    isLoading.value = true;

    try {
      var url = Uri.parse(API.baseUrl + API.loginUrl);
      Map<String, dynamic> data = {"email": email, "password": password};

      log("===url============$url\n data===> ${json.encode(data)}");

      var response = await http.post(
        url,
        body: json.encode(data),
        headers: NetworkHttps.baseHeaders,
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        print('Response body: $decoded');

        if (decoded['status'] == 1 || decoded['success'] == true) {

          var userData = decoded["data"] ?? {};

          String userId = userData['id']?.toString() ?? '';
          String token = userData['token'] ?? '';
          String storeId = userData['current_store']?.toString() ?? '';
          String userEmail = userData['email'] ?? '';
          String userName = userData['name'] ?? 'User';

          print("===user_id============ $userId");

          Prefs.setUserID(userId);
          Prefs.setToken(token);
          Prefs.setStoreID(storeId);
          Prefs.setString(AppConstant.name, userName);
          Prefs.setString(AppConstant.emailId, userEmail);

          emailController.clear();
          passwordController.clear();

          isLoading.value = false;

          commonToast(type: AppSnackBarType.success, "$userName Login Successfully");

          _sendFcmTokenAfterLogin(storeId);

          Get.offAllNamed(AppRoutes.dashboard);

        } else {
          isLoading.value = false;
          String msg = decoded['message'] ?? decoded['data']?['message'] ?? "Login failed";
          commonToast(type: AppSnackBarType.error, msg);
        }
      } else {
        isLoading.value = false;

        String errorMsg = "Server error occurred";
        try {
          var errorBody = jsonDecode(response.body);
          errorMsg = errorBody['message'] ?? errorMsg;
        } catch (e) {}

        commonToast(type: AppSnackBarType.error, errorMsg);
      }

    } catch (e) {
      isLoading.value = false;
      print("===Exception============ $e");
      commonToast(type: AppSnackBarType.error, "An unexpected error occurred. Please check logs.");
    }
  }

  /// إرسال FCM Token للسيرفر بعد تسجيل الدخول
  Future<void> _sendFcmTokenAfterLogin(String storeId) async {
    try {
      final fcmService = FcmTokenService();
      await fcmService.sendFcmTokenToServer(storeId: storeId);
    } catch (e) {
      print('❌ خطأ في إرسال FCM Token بعد تسجيل الدخول: $e');
    }
  }

  Future<void> _clearLocalSession() async {
    // Clear FCM token
    try {
      await FcmTokenService().clearFcmToken();
    } catch (e) {
      log('FCM clear error: $e');
    }

    // Clear notifications
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().clearNotificationData();
    }

    // Clear ALL local storage
    await Prefs.clear();

    // Clear controllers
    clear();
  }

  @override
  void onInit() {
    super.onInit();
    emailController.clear();
    passwordController.clear();
    fNameController.clear();
    lNameController.clear();
    newEmailController.clear();
    newPasswordController.clear();
    forgotEmailController.clear();
  }
}
