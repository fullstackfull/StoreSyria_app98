import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/utils/app_log.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/services/fcm_token_service.dart';
import '../../permissions/merchant_permissions.dart';

/// The exact string `Api\DashboardController::login` sends when an administrator
/// has disabled the account (DashboardController.php:918).
///
/// MATCHED EXACTLY, NOT SNIFFED. A `contains('disable')` test would also catch
/// unrelated refusals, and — worse — it would silently stop matching the day
/// anyone makes the API locale-aware, reverting this fix with no test going red.
/// `resources/lang/ar.json:689` already holds an Arabic translation this
/// endpoint can never emit, because `adminlogin` carries no locale middleware
/// (routes/api.php:134), so `__()` resolves against the backend default.
///
/// `login_refusal_message_test` drives this literal. If the backend ever changes
/// the wording, that test fails and somebody updates both ends deliberately.
const String serverDisabledAccountMessage =
    'Your Account is disable,please contact your Administrator.';

/// The server's other refusal, for wrong credentials
/// (DashboardController.php:921). The app's own `login_failed` copy is better —
/// it says what to check — and it is translated, so this one is mapped back to
/// the generic rather than echoed.
const String serverInvalidCredentialsMessage = 'Invalid login details';

/// `ApiResponser::error()`'s DEFAULT top-level message (ApiResponser.php:54) —
/// the bare word `fail`.
///
/// It has to be named here because `apiMessage` falls back from `data.message`
/// to the top-level `message`, so a refusal carrying no nested message yields
/// this sentinel. The first version of `loginRefusalMessage` duly returned it,
/// which would have shown a merchant a toast reading "fail". The test caught it;
/// nothing else would have.
const String serverEnvelopeFailSentinel = 'fail';

/// What to show a merchant whose login the server refused.
///
/// WS K. The refusal arrives as HTTP 200 with `status: 0` — the backend says at
/// DashboardController.php:891-894 that it keeps that shape deliberately,
/// because the shipped app force-clears its session on any 401 and this is a
/// login. So the body is the only signal, and the app used to discard it: a
/// merchant whose account had been disabled was told to check their password,
/// which is the one thing that could not help them.
///
/// The precedence, and each limb is there for a reason:
///   1. the known disabled-account literal -> the translated app-side key
///   2. the known wrong-credentials literal -> the app's own better, translated copy
///   3. anything else the server said -> SHOWN, because a refusal the app does
///      not recognise is more useful to a merchant than a generic one
///   4. nothing, or the bare `fail` envelope sentinel -> the generic
String loginRefusalMessage(dynamic decoded) {
  final String serverMessage = apiMessage(decoded, fallback: '');

  if (serverMessage == serverDisabledAccountMessage) {
    return 'account_disabled_contact_admin'.tr;
  }

  if (serverMessage.isEmpty ||
      serverMessage == serverEnvelopeFailSentinel ||
      serverMessage == serverInvalidCredentialsMessage) {
    return 'login_failed'.tr;
  }

  return serverMessage;
}

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
      'isTap': true,
    }.obs,
    {
      'icon': DefaultImages.googleIcn,
      'title': 'Login with Google',
      'isTap': false,
    }.obs,
    {
      'icon': DefaultImages.appleIcn,
      'title': 'Login with Apple',
      'isTap': false,
    }.obs,
  ].obs;
  RxList signUpList = [
    {
      'icon': DefaultImages.facebookIcn,
      'title': 'Login with Facebook',
      'isTap': true,
    }.obs,
    {
      'icon': DefaultImages.googleIcn,
      'title': 'Login with Google',
      'isTap': false,
    }.obs,
    {
      'icon': DefaultImages.appleIcn,
      'title': 'Login with Apple',
      'isTap': false,
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
      final url = Uri.parse(API.baseUrl + API.logoutUrl);

      AppLog.d('=== LOGOUT URL === $url');

      // R7-N1: was a hand-rolled Bearer map. Identical bytes, one site.
      final response = await http.post(
        url,
        headers: NetworkHttps.authHeaders(),
      );

      AppLog.d('=== LOGOUT STATUS === ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == 1 || decoded['success'] == true) {
          await _clearLocalSession();

          commonToast(type: AppSnackBarType.success, 'logout_success'.tr);

          Get.offAllNamed(AppRoutes.login);
        } else {
          commonToast(type: AppSnackBarType.error, 'logout_failed'.tr);
        }
      } else {
        commonToast(type: AppSnackBarType.error, 'logout_failed'.tr);
      }
    } catch (e) {
      AppLog.e('=== LOGOUT ERROR ===', error: e);
      commonToast(type: AppSnackBarType.error, 'logout_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAuth({
    required String email,
    required String password,
  }) async {
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

          // P2-07-13 / WS K13. What this principal may do, as the SERVER reported it. Persisted
          // here so a screen opening before the first dashboard call still knows what to offer;
          // refreshed from the dashboard response afterwards, because permissions belong to the
          // CURRENT STORE and a store switch changes them.
          //
          // A server that does not send the key yields "nothing held", which hides merchant
          // surfaces rather than revealing them -- the safe direction for a missing field.
          MerchantPermissions.fromJson(userData).persist();

          emailController.clear();
          passwordController.clear();

          isLoading.value = false;

          commonToast(type: AppSnackBarType.success, 'login_success'.tr);

          _sendFcmTokenAfterLogin(storeId);

          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          isLoading.value = false;
          commonToast(
            type: AppSnackBarType.error,
            loginRefusalMessage(decoded),
          );
        }
      } else {
        isLoading.value = false;

        commonToast(type: AppSnackBarType.error, 'server_error'.tr);
      }
    } catch (e) {
      isLoading.value = false;
      AppLog.e('=== LOGIN EXCEPTION ===', error: e);
      commonToast(type: AppSnackBarType.error, 'unexpected_error'.tr);
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
    /// ONE TEARDOWN, SHARED WITH THE FORCED LOGOUT.
    ///
    /// This method used to own the full teardown while `handleUnauthorized()`
    /// -- the path a 401 takes -- did only `Prefs.clear()`. The two drifted
    /// because nothing compared them, and what the forced path skipped was the
    /// FCM token: `Prefs.clear()` forgets it locally while the registration on
    /// Firebase survives, so the device kept receiving the previous merchant's
    /// order notifications.
    ///
    /// The steps are unchanged and in the same order; they just live in one
    /// place now.
    await NetworkHttps.clearSession();

    // Controller state is this class's own and is not part of the shared
    // teardown -- `handleUnauthorized()` has no AuthController to clear.
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
