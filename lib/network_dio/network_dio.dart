import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:store_go_app/network_dio/result.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/screen/auth/login_widget.dart';

class NetworkHttps {
  NetworkHttps._privateConstructor();

  static final NetworkHttps getInstance =
  NetworkHttps._privateConstructor();

  // ===========================================================================
  // LOGGER
  // ===========================================================================

  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  // ===========================================================================
  // HEADERS
  // ===========================================================================

  static final Map<String, String> baseHeaders = {
    HttpHeaders.contentTypeHeader:
    'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader:
    'no-cache',
    'Accept':
    'application/json',
  };

  // ===========================================================================
  // AUTH HEADERS
  // ===========================================================================

  static Map<String, String> _getAuthHeaders() {
    final token = Prefs.getToken();

    final headers = Map<String, String>.from(baseHeaders);

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ===========================================================================
  // PRETTY JSON
  // ===========================================================================

  static String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          return data;
        }
      }

      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  // ===========================================================================
  // REQUEST LOGGER
  // ===========================================================================

  static void _logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('══════════════════════════════════════════════════════');
    buffer.writeln('🚀 $method REQUEST');
    buffer.writeln('══════════════════════════════════════════════════════');

    buffer.writeln('URL:');
    buffer.writeln(url);

    if (body != null && body.isNotEmpty) {
      buffer.writeln('\nBODY:');
      buffer.writeln(_prettyJson(body));
    }

    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );

    logger.d(buffer.toString());
  }

  // ===========================================================================
  // RESPONSE LOGGER
  // ===========================================================================

  static void _logResponse({
    required String method,
    required String url,
    required http.Response response,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('══════════════════════════════════════════════════════');
    buffer.writeln('📥 $method RESPONSE');
    buffer.writeln('══════════════════════════════════════════════════════');

    buffer.writeln('URL:');
    buffer.writeln(url);

    buffer.writeln('\nSTATUS CODE:');
    buffer.writeln(response.statusCode);

    buffer.writeln('\nRESPONSE:');

    if (response.body.isEmpty) {
      buffer.writeln('(empty response)');
    } else {
      buffer.writeln(_prettyJson(response.body));
    }

    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );

    logger.d(buffer.toString());
  }

  // ===========================================================================
  // ERROR LOGGER
  // ===========================================================================

  static void _logError({
    required String method,
    required String url,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    logger.e(
      '''
══════════════════════════════════════════════════════
❌ $method ERROR
══════════════════════════════════════════════════════
URL:
$url

ERROR:
$error
══════════════════════════════════════════════════════
''',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ===========================================================================
  // ERROR RESPONSE
  // ===========================================================================

  static Failure<T> _handleErrorResponse<T>(
      http.Response response,
      ) {
    String message = "An error occurred";

    Map<String, dynamic>? validationErrors;

    FailureReason reason = FailureReason.unknown;

    try {
      final body = json.decode(response.body);

      if (body is Map) {
        message =
            body['message'] ??
                body['data']?['message'] ??
                body['error'] ??
                "Unknown error";

        if (body['errors'] != null) {
          validationErrors =
          Map<String, dynamic>.from(body['errors']);

          reason = FailureReason.validation;
        }
      }
    } catch (_) {
      message =
      "Server error: ${response.statusCode}";
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

    return Failure<T>(
      reason,
      message,
      validationErrors: validationErrors,
    );
  }

  // ===========================================================================
  // UNAUTHORIZED
  // ===========================================================================

  static void _handleUnauthorized() async {
    await Prefs.clear();

    if (Get.currentRoute != '/login') {
      Get.offAll(() => NormalLoginWidget());
    }
  }

  // ===========================================================================
  // GET
  // ===========================================================================

  static Future<Result<Map<String, dynamic>>> getRequest(
      String endPoint,
      ) async {
    final getUrl = API.baseUrl + endPoint;

    try {
      final headers = _getAuthHeaders();

      _logRequest(
        method: 'GET',
        url: getUrl,
        headers: headers,
      );

      final response = await http.get(
        Uri.parse(getUrl),
        headers: headers,
      );

      _logResponse(
        method: 'GET',
        url: getUrl,
        response: response,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return Success(
          Map<String, dynamic>.from(data),
        );
      }

      return _handleErrorResponse(response);
    } on SocketException catch (e, stackTrace) {
      _logError(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.network,
        "No Internet connection.",
      );
    } on HttpException catch (e, stackTrace) {
      _logError(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.network,
        "Connection failed.",
      );
    } catch (e, stackTrace) {
      _logError(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        "Unexpected error: ${e.toString()}",
      );
    }
  }

  // ===========================================================================
  // POST
  // ===========================================================================

  static Future<Result<Map<String, dynamic>>> postRequest(
      String endPoint,
      Map data,
      ) async {
    final postUrl = API.baseUrl + endPoint;

    try {
      final headers = _getAuthHeaders();

      _logRequest(
        method: 'POST',
        url: postUrl,
        headers: headers,
        body: Map<String, dynamic>.from(data),
      );

      final response = await http.post(
        Uri.parse(postUrl),
        body: jsonEncode(data),
        headers: headers,
      );

      _logResponse(
        method: 'POST',
        url: postUrl,
        response: response,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        return Success(
          Map<String, dynamic>.from(decoded),
        );
      }

      return _handleErrorResponse(response);
    } on SocketException catch (e, stackTrace) {
      _logError(
        method: 'POST',
        url: postUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.network,
        "No Internet connection.",
      );
    } catch (e, stackTrace) {
      _logError(
        method: 'POST',
        url: postUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        "Unexpected error: ${e.toString()}",
      );
    }
  }

  // ===========================================================================
  // MULTIPART
  // ===========================================================================

  static Future<Result<Map<String, dynamic>>> multipartRequest({
    required String endPoint,
    required Map<String, String> fields,
    Map<String, String>? files,
    List<String>? multiFiles,
    String multiFileKey = 'product_image[]',
  }) async {
    final url = API.baseUrl + endPoint;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      final headers = _getAuthHeaders();

      request.headers.addAll(headers);
      request.fields.addAll(fields);

      // -----------------------------------------------------------------------
      // LOG MULTIPART REQUEST
      // -----------------------------------------------------------------------

      _logRequest(
        method: 'MULTIPART POST',
        url: url,
        headers: headers,
        body: Map<String, dynamic>.from(fields),
      );

      // -----------------------------------------------------------------------
      // SINGLE FILES
      // -----------------------------------------------------------------------

      if (files != null) {
        for (final file in files.entries) {
          if (file.value.isNotEmpty &&
              File(file.value).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                file.key,
                file.value,
              ),
            );
          }
        }
      }

      // -----------------------------------------------------------------------
      // MULTIPLE FILES
      // -----------------------------------------------------------------------

      if (multiFiles != null) {
        for (final path in multiFiles) {
          if (path.isNotEmpty &&
              File(path).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                multiFileKey,
                path,
              ),
            );
          }
        }
      }

      // -----------------------------------------------------------------------
      // SEND
      // -----------------------------------------------------------------------

      final streamedResponse = await request.send();

      final response =
      await http.Response.fromStream(streamedResponse);

      // -----------------------------------------------------------------------
      // LOG RESPONSE
      // -----------------------------------------------------------------------

      _logResponse(
        method: 'MULTIPART POST',
        url: url,
        response: response,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        return Success(
          Map<String, dynamic>.from(decoded),
        );
      }

      return _handleErrorResponse(response);
    } on SocketException catch (e, stackTrace) {
      _logError(
        method: 'MULTIPART POST',
        url: url,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.network,
        "No Internet connection.",
      );
    } catch (e, stackTrace) {
      _logError(
        method: 'MULTIPART POST',
        url: url,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        e.toString(),
      );
    }
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  static Future<Result<Map<String, dynamic>>> deleteRequest(
      String endPoint,
      ) async {
    final deleteUrl = API.baseUrl + endPoint;

    try {
      final headers = _getAuthHeaders();

      _logRequest(
        method: 'DELETE',
        url: deleteUrl,
        headers: headers,
      );

      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: headers,
      );

      _logResponse(
        method: 'DELETE',
        url: deleteUrl,
        response: response,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        final body = response.body.isEmpty
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(
          jsonDecode(response.body),
        );

        return Success(body);
      }

      return _handleErrorResponse(response);
    } on SocketException catch (e, stackTrace) {
      _logError(
        method: 'DELETE',
        url: deleteUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.network,
        "No Internet connection.",
      );
    } catch (e, stackTrace) {
      _logError(
        method: 'DELETE',
        url: deleteUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        "Unexpected error: ${e.toString()}",
      );
    }
  }
}