// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/network_dio/result.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/screen/auth/login_widget.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class NetworkHttps {
  NetworkHttps._privateConstructor();

  static final NetworkHttps getInstance = NetworkHttps._privateConstructor();

  static final Map<String, String> baseHeaders = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: "no-cache",
    'Accept': 'application/json',
  };

  /// دالة مساعدة لبناء الهيدرز مع التوكن
  static Map<String, String> _getAuthHeaders() {
    final token = Prefs.getToken();
    final headers = Map<String, String>.from(baseHeaders);
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// دالة معالجة الأخطاء الموحدة
  static Failure<T> _handleErrorResponse<T>(http.Response response) {
    String message = "An error occurred";
    Map<String, dynamic>? validationErrors;
    FailureReason reason = FailureReason.unknown;

    try {
      final body = json.decode(response.body);
      if (body is Map) {
        message = body['message'] ??
            body['data']?['message'] ??
            body['error'] ??
            "Unknown error";

        if (body['errors'] != null) {
          validationErrors = body['errors'];
          reason = FailureReason.validation;
        }
      }
    } catch (e) {
      message = "Server error: ${response.statusCode}";
    }

    switch (response.statusCode) {
      case 401:
        reason = FailureReason.unauthorized;
        _handleUnauthorized();
        break;
      case 400:
        reason = FailureReason.validation;
        break;
      case 404:
        message = "Resource not found";
        break;
      case 500:
        message = "Server internal error";
        break;
      default:
        reason = FailureReason.unknown;
    }

    return Failure<T>(reason, message, validationErrors: validationErrors);
  }

  static void _handleUnauthorized() async {
    await Prefs.clear();
    // التحقق مما إذا لم نكن بالفعل في شاشة تسجيل الدخول لتجنب التكرار
    if (Get.currentRoute != '/login') {
      Get.offAll(() => NormalLoginWidget());
    }
  }

  // --------------------------------------------------------------------------
  // GET Request
  // --------------------------------------------------------------------------
  static Future<Result<Map<String, dynamic>>> getRequest(String endPoint) async {
    var getUrl = API.baseUrl + endPoint;
    print("GET API URL===> $getUrl");

    try {
      final headers = _getAuthHeaders();
      var response = await http.get(Uri.parse(getUrl), headers: headers);

      print("statusCode===> ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("========== API RESPONSE ==========");
        print(data);
        print("==================================");
        return Success(data);
      } else {
        return _handleErrorResponse(response);
      }
    } on SocketException {
      return Failure(FailureReason.network, "No Internet connection.");
    } on HttpException {
      return Failure(FailureReason.network, "Connection failed.");
    } catch (e) {
      print("err->${e.toString()}");
      return Failure(FailureReason.unknown, "Unexpected error: ${e.toString()}");
    }
  }

  // --------------------------------------------------------------------------
  // POST Request
  // --------------------------------------------------------------------------
  static Future<Result<Map<String, dynamic>>> postRequest(String endPoint, Map data) async {
    String postUrl = API.baseUrl + endPoint;
    print("POST API URL===> $postUrl");
    print("data===> ${jsonEncode(data)}");

    try {
      final headers = _getAuthHeaders();
      var response = await http.post(
        Uri.parse(postUrl),
        body: jsonEncode(data),
        headers: headers,
      );

      print("statusCode===> ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print("========== API RESPONSE ==========");
        print(data);
        print("==================================");
        return Success(data);
      } else {
        return _handleErrorResponse(response);
      }
    } on SocketException {
      return Failure(FailureReason.network, "No Internet connection.");
    } catch (e) {
      print("err->${e.toString()}");
      return Failure(FailureReason.unknown, "Unexpected error: ${e.toString()}");
    }
  }
  // -------------------------------------------------------------------------
  // Multiple Request
  // -------------------------------------------------------------------------
  static Future<Result<Map<String, dynamic>>> multipartRequest({
    required String endPoint,
    required Map<String, String> fields,
    Map<String, String>? files,
    List<String>? multiFiles,
    String multiFileKey = 'product_image[]',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API.baseUrl + endPoint),
      );

      request.headers.addAll(_getAuthHeaders());
      request.fields.addAll(fields);

      if (files != null) {
        for (final file in files.entries) {
          if (file.value.isNotEmpty && File(file.value).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(file.key, file.value),
            );
          }
        }
      }

      if (multiFiles != null) {
        for (final path in multiFiles) {
          if (path.isNotEmpty && File(path).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(multiFileKey, path),
            );
          }
        }
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(jsonDecode(response.body));
      } else {
        return _handleErrorResponse(response);
      }

    } on SocketException {
      return Failure(FailureReason.network, "No Internet connection.");
    } catch (e) {
      return Failure(FailureReason.unknown, e.toString());
    }
  }

  // --------------------------------------------------------------------------
  // DELETE Request
  // --------------------------------------------------------------------------
  static Future<Result<Map<String, dynamic>>> deleteRequest(String endPoint) async {
    String deleteUrl = API.baseUrl + endPoint;
    print("DELETE API URL===> $deleteUrl");

    try {
      final headers = _getAuthHeaders();
      var response = await http.delete(Uri.parse(deleteUrl), headers: headers);

      print("statusCode===> ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content is common for delete
        final body = response.body.isEmpty ? {} : json.decode(response.body);
        return Success(body);
      } else {
        return _handleErrorResponse(response);
      }
    } on SocketException {
      return Failure(FailureReason.network, "No Internet connection.");
    } catch (e) {
      print("err->${e.toString()}");
      return Failure(FailureReason.unknown, "Unexpected error: ${e.toString()}");
    }
  }
}