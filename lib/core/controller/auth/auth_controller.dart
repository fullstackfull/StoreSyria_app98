import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/utils/app_log.dart';
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
      final url = Uri.parse(
        API.baseUrl + API.logoutUrl,
      );

      AppLog.d('=== LOGOUT URL === $url');

      // R7-N1: was a hand-rolled Bearer map. Identical bytes, one site.
      final response = await http.post(
        url,
        headers: NetworkHttps.authHeaders(),
      );

      AppLog.d('=== LOGOUT STATUS === ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == 1 ||
            decoded['success'] == true) {
          await _clearLocalSession();

          commonToast(
            type: AppSnackBarType.success,
            'logout_success'.tr,
          );

          Get.offAllNamed(AppRoutes.login);

        } else {
          commonToast(
            type: AppSnackBarType.error,
            'logout_failed'.tr,
          );
        }
      } else {
        commonToast(
          type: AppSnackBarType.error,
          'logout_failed'.tr,
        );
      }
    } catch (e) {
      AppLog.e('=== LOGOUT ERROR ===', error: e);
      commonToast(
        type: AppSnackBarType.error,
        'logout_error'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> loginAuth({required String email, required String password}) async {
    isLoading.value = true;

    try {
      var url = Uri.parse(API.baseUrl + API.loginUrl);
      Map<String, dynamic> data = {"email": email, "password": password};

      AppLog.d('=== LOGIN URL === $url');

      var response = await http.post(
        url,
        body: json.encode(data),
        headers: NetworkHttps.baseHeaders,
      );

      AppLog.d('=== LOGIN STATUS === ${response.statusCode}');

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);

        if (decoded['status'] == 1 || decoded['success'] == true) {

          var userData = decoded["data"] ?? {};

          String userId = userData['id']?.toString() ?? '';
          String token = userData['token'] ?? '';
          String storeId = userData['current_store']?.toString() ?? '';
          String userEmail = userData['email'] ?? '';
          String userName = userData['name'] ?? 'User';

          Prefs.setUserID(userId);
          Prefs.setToken(token);
          Prefs.setStoreID(storeId);
          Prefs.setString(AppConstant.name, userName);
          Prefs.setString(AppConstant.emailId, userEmail);

          emailController.clear();
          passwordController.clear();

          isLoading.value = false;

          commonToast(
            type: AppSnackBarType.success,
            'login_success'.tr,
          );

          _sendFcmTokenAfterLogin(storeId);

          Get.offAllNamed(AppRoutes.dashboard);

        } else {
          isLoading.value = false;
          commonToast(
            type: AppSnackBarType.error,
            'login_failed'.tr,
          );
        }
      } else {
        isLoading.value = false;

        commonToast(
          type: AppSnackBarType.error,
          'server_error'.tr,
        );
      }

    } catch (e) {
      isLoading.value = false;
      AppLog.e('=== LOGIN EXCEPTION ===', error: e);
      commonToast(
        type: AppSnackBarType.error,
        'unexpected_error'.tr,
      );
    }
  }

  /// إرسال FCM Token للسيرفر بعد تسجيل الدخول
  Future<void> _sendFcmTokenAfterLogin(String storeId) async {
    try {
      final fcmService = FcmTokenService();
      await fcmService.sendFcmTokenToServer(storeId: storeId);
    } catch (e) {
      AppLog.e('FCM token dispatch after login failed', error: e);
    }
  }

  Future<void> _clearLocalSession() async {
    // Clear FCM token
    try {
      await FcmTokenService().clearFcmToken();
    } catch (e) {
      AppLog.e('FCM clear error', error: e);
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
