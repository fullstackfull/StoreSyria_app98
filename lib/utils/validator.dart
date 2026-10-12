import 'package:get/get.dart';

class Validator {
  static String? validateRequired(String value) {
    if (value.trim().isEmpty) {
      return 'field_required'.tr;
    }

    return null;
  }

  static String? validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regex = RegExp(pattern);

    if (value.trim().isEmpty) {
      return 'email_required'.tr;
    } else if (!regex.hasMatch(value)) {
      return 'invalid_email'.tr;
    }

    return null;
  }

  static String? validatePassword(String value) {
    String pattern = r'(?=.*?[0-9])';

    RegExp regex = RegExp(pattern);

    if (value.isEmpty) {
      return 'password_required'.tr;
    } else if (!regex.hasMatch(value)) {
      return 'enter_valid_password'.tr;
    }

    return null;
  }

  static String? validateConfirmPassword(
      String value,
      String password,
      ) {
    String pattern = r'(?=.*?[0-9])';

    RegExp regex = RegExp(pattern);

    if (value.isEmpty) {
      return 'please_re_enter_new_password'.tr;
    } else if (!regex.hasMatch(value)) {
      return 'enter_valid_password'.tr;
    } else if (value != password) {
      return 'password_must_be_same'.tr;
    }

    return null;
  }

  static String? validateName(
      String value,
      String string,
      ) {
    String pattern = '[a-zA-Z]';

    RegExp regex = RegExp(pattern);

    if (value.trim().isEmpty) {
      return 'name_required'.trParams({
        'name': string,
      });
    } else if (!regex.hasMatch(value)) {
      return 'enter_valid_name'.tr;
    }

    return null;
  }

  static String? validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

    RegExp regExp = RegExp(pattern);

    if (value.trim().isEmpty) {
      return 'mobile_number_required'.tr;
    } else if (!regExp.hasMatch(value)) {
      return 'please_enter_valid_mobile'.tr;
    }

    return null;
  }

  /// Required URL
  static String? validateUrl(String value) {
    final url = value.trim();

    if (url.isEmpty) {
      return 'field_required'.tr;
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'invalid_url'.tr;
    }

    return null;
  }

  /// Optional URL
  /// Empty value is allowed.
  /// If a value exists, it must be a valid HTTP/HTTPS URL.
  static String? validateOptionalUrl(String value) {
    final url = value.trim();

    if (url.isEmpty) {
      return null;
    }

    return validateUrl(value);
  }
}
