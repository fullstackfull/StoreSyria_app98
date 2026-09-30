import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:store_go_app/network/result.dart';
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

  // ===========================================================================
  // TIMEOUTS
  // ===========================================================================

  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _uploadTimeout = Duration(seconds: 60);

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
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json',
  };

  // ===========================================================================
  // AUTH HEADERS
  // ===========================================================================

  static Map<String, String> _getAuthHeaders() {
    final token = Prefs.getToken();

    final headers = Map<String, String>.from(baseHeaders);

    if (token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
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

    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );
    buffer.writeln('🚀 $method REQUEST');
    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );

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

    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );
    buffer.writeln('📥 $method RESPONSE');
    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );

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
  // NETWORK FAILURE
  // ===========================================================================

  static Failure<T> _networkFailure<T>({
    required String method,
    required String url,
    required dynamic error,
    required StackTrace stackTrace,
    String message = 'Connection failed. Please try again.',
    FailureReason reason = FailureReason.network,
  }) {
    _logError(
      method: method,
      url: url,
      error: error,
      stackTrace: stackTrace,
    );

    return Failure<T>(
      reason,
      message,
    );
  }

  // ===========================================================================
  // ERROR RESPONSE
  // ===========================================================================

  static Failure<T> _handleErrorResponse<T>(
      http.Response response,
      ) {
    String message = 'An error occurred';

    Map<String, dynamic>? validationErrors;

    FailureReason reason = FailureReason.unknown;

    // -------------------------------------------------------------------------
    // READ RESPONSE BODY
    // -------------------------------------------------------------------------

    try {
      if (response.body.isNotEmpty) {
        final body = jsonDecode(response.body);

        if (body is Map) {
          final data = body['data'];

          // Prefer:
          // data.message
          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          }

          // Then:
          // message
          else if (body['message'] != null) {
            message = body['message'].toString();
          }

          // Then:
          // error
          else if (body['error'] != null) {
            message = body['error'].toString();
          }

          // Validation errors
          if (body['errors'] is Map) {
            validationErrors = Map<String, dynamic>.from(
              body['errors'],
            );

            reason = FailureReason.validation;
          }
        }
      }
    } catch (_) {
      message = 'Server error: ${response.statusCode}';
    }

    // -------------------------------------------------------------------------
    // STATUS CODE
    // -------------------------------------------------------------------------

    switch (response.statusCode) {
    // -----------------------------------------------------------------------
    // 400
    // -----------------------------------------------------------------------

      case 400:
        reason = FailureReason.validation;
        break;

    // -----------------------------------------------------------------------
    // 401
    // -----------------------------------------------------------------------

      case 401:
        reason = FailureReason.unauthorized;
        _handleUnauthorized();
        break;

    // -----------------------------------------------------------------------
    // 404
    // -----------------------------------------------------------------------

      case 404:
        reason = FailureReason.notFound;

        if (message == 'An error occurred' ||
            message == 'Unknown error') {
          message = 'Resource not found';
        }

        break;

    // -----------------------------------------------------------------------
    // 500
    // -----------------------------------------------------------------------

      case 500:
        reason = FailureReason.unknown;
        message = 'Server internal error';
        break;

    // -----------------------------------------------------------------------
    // OTHER
    // -----------------------------------------------------------------------

      default:
        reason = FailureReason.unknown;
        break;
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

  static Future<void> _handleUnauthorized() async {
    await Prefs.clear();

    if (Get.currentRoute != '/login') {
      Get.offAll(
            () => NormalLoginWidget(),
      );
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
      ).timeout(_timeout);

      _logResponse(
        method: 'GET',
        url: getUrl,
        response: response,
      );

      // -----------------------------------------------------------------------
      // SUCCESS
      // -----------------------------------------------------------------------

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return Success(
          Map<String, dynamic>.from(data),
        );
      }

      // -----------------------------------------------------------------------
      // ERROR RESPONSE
      // -----------------------------------------------------------------------

      return _handleErrorResponse(response);
    }

    // -------------------------------------------------------------------------
    // SOCKET EXCEPTION
    // -------------------------------------------------------------------------

    on TimeoutException catch (e, stackTrace) {
      return _networkFailure(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'request_timeout'.tr,
        reason: FailureReason.timeout,
      );
    }

    on SocketException catch (e, stackTrace) {
      return _networkFailure(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'No Internet connection.',
      );
    }

    // -------------------------------------------------------------------------
    // HTTP CLIENT EXCEPTION
    // -------------------------------------------------------------------------

    on http.ClientException catch (e, stackTrace) {
      return _networkFailure(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // HTTP EXCEPTION
    // -------------------------------------------------------------------------

    on HttpException catch (e, stackTrace) {
      return _networkFailure(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // UNKNOWN
    // -------------------------------------------------------------------------

    catch (e, stackTrace) {
      _logError(
        method: 'GET',
        url: getUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        'Unexpected error: ${e.toString()}',
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
      ).timeout(_timeout);

      _logResponse(
        method: 'POST',
        url: postUrl,
        response: response,
      );

      // -----------------------------------------------------------------------
      // SUCCESS
      // -----------------------------------------------------------------------

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        return Success(
          Map<String, dynamic>.from(decoded),
        );
      }

      // -----------------------------------------------------------------------
      // ERROR RESPONSE
      // -----------------------------------------------------------------------

      return _handleErrorResponse(response);
    }

    // -------------------------------------------------------------------------
    // SOCKET EXCEPTION
    // -------------------------------------------------------------------------

    on TimeoutException catch (e, stackTrace) {
      return _networkFailure(
        method: 'POST',
        url: postUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'request_timeout'.tr,
        reason: FailureReason.timeout,
      );
    }

    on SocketException catch (e, stackTrace) {
      return _networkFailure(
        method: 'POST',
        url: postUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'No Internet connection.',
      );
    }

    // -------------------------------------------------------------------------
    // HTTP CLIENT EXCEPTION
    // -------------------------------------------------------------------------

    on http.ClientException catch (e, stackTrace) {
      return _networkFailure(
        method: 'POST',
        url: postUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // HTTP EXCEPTION
    // -------------------------------------------------------------------------

    on HttpException catch (e, stackTrace) {
      return _networkFailure(
        method: 'POST',
        url: postUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // UNKNOWN
    // -------------------------------------------------------------------------

    catch (e, stackTrace) {
      _logError(
        method: 'POST',
        url: postUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // PUT
  // ===========================================================================

  static Future<Result<Map<String, dynamic>>> putRequest(
      String endPoint,
      Map data,
      ) async {
    final putUrl = API.baseUrl + endPoint;

    try {
      final headers = _getAuthHeaders();

      _logRequest(
        method: 'PUT',
        url: putUrl,
        headers: headers,
        body: Map<String, dynamic>.from(data),
      );

      final response = await http.put(
        Uri.parse(putUrl),
        body: jsonEncode(data),
        headers: headers,
      ).timeout(_timeout);

      _logResponse(
        method: 'PUT',
        url: putUrl,
        response: response,
      );

      // -----------------------------------------------------------------------
      // SUCCESS
      // -----------------------------------------------------------------------

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        return Success(
          Map<String, dynamic>.from(decoded),
        );
      }

      // -----------------------------------------------------------------------
      // ERROR RESPONSE
      // -----------------------------------------------------------------------

      return _handleErrorResponse(response);
    }

    // -------------------------------------------------------------------------
    // SOCKET EXCEPTION
    // -------------------------------------------------------------------------

    on TimeoutException catch (e, stackTrace) {
      return _networkFailure(
        method: 'PUT',
        url: putUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'request_timeout'.tr,
        reason: FailureReason.timeout,
      );
    }

    on SocketException catch (e, stackTrace) {
      return _networkFailure(
        method: 'PUT',
        url: putUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'No Internet connection.',
      );
    }

    // -------------------------------------------------------------------------
    // HTTP CLIENT EXCEPTION
    // -------------------------------------------------------------------------

    on http.ClientException catch (e, stackTrace) {
      return _networkFailure(
        method: 'PUT',
        url: putUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // HTTP EXCEPTION
    // -------------------------------------------------------------------------

    on HttpException catch (e, stackTrace) {
      return _networkFailure(
        method: 'PUT',
        url: putUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // UNKNOWN
    // -------------------------------------------------------------------------

    catch (e, stackTrace) {
      _logError(
        method: 'PUT',
        url: putUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        'Unexpected error: ${e.toString()}',
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
      // LOG REQUEST
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

      final streamedResponse = await request.send().timeout(_uploadTimeout);

      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_uploadTimeout);

      // -----------------------------------------------------------------------
      // LOG RESPONSE
      // -----------------------------------------------------------------------

      _logResponse(
        method: 'MULTIPART POST',
        url: url,
        response: response,
      );

      // -----------------------------------------------------------------------
      // SUCCESS
      // -----------------------------------------------------------------------

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        return Success(
          Map<String, dynamic>.from(decoded),
        );
      }

      // -----------------------------------------------------------------------
      // ERROR RESPONSE
      // -----------------------------------------------------------------------

      return _handleErrorResponse(response);
    }

    // -------------------------------------------------------------------------
    // SOCKET EXCEPTION
    // -------------------------------------------------------------------------

    on TimeoutException catch (e, stackTrace) {
      return _networkFailure(
        method: 'MULTIPART POST',
        url: url,
        error: e,
        stackTrace: stackTrace,
        message: 'request_timeout'.tr,
        reason: FailureReason.timeout,
      );
    }

    on SocketException catch (e, stackTrace) {
      return _networkFailure(
        method: 'MULTIPART POST',
        url: url,
        error: e,
        stackTrace: stackTrace,
        message: 'No Internet connection.',
      );
    }

    // -------------------------------------------------------------------------
    // HTTP CLIENT EXCEPTION
    // -------------------------------------------------------------------------

    on http.ClientException catch (e, stackTrace) {
      return _networkFailure(
        method: 'MULTIPART POST',
        url: url,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // HTTP EXCEPTION
    // -------------------------------------------------------------------------

    on HttpException catch (e, stackTrace) {
      return _networkFailure(
        method: 'MULTIPART POST',
        url: url,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // UNKNOWN
    // -------------------------------------------------------------------------

    catch (e, stackTrace) {
      _logError(
        method: 'MULTIPART POST',
        url: url,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        'Unexpected error: ${e.toString()}',
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
      ).timeout(_timeout);

      _logResponse(
        method: 'DELETE',
        url: deleteUrl,
        response: response,
      );

      // -----------------------------------------------------------------------
      // SUCCESS
      // -----------------------------------------------------------------------

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        final body = response.body.isEmpty
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(
          jsonDecode(response.body),
        );

        return Success(body);
      }

      // -----------------------------------------------------------------------
      // ERROR RESPONSE
      // -----------------------------------------------------------------------

      return _handleErrorResponse(response);
    }

    // -------------------------------------------------------------------------
    // SOCKET EXCEPTION
    // -------------------------------------------------------------------------

    on TimeoutException catch (e, stackTrace) {
      return _networkFailure(
        method: 'DELETE',
        url: deleteUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'request_timeout'.tr,
        reason: FailureReason.timeout,
      );
    }

    on SocketException catch (e, stackTrace) {
      return _networkFailure(
        method: 'DELETE',
        url: deleteUrl,
        error: e,
        stackTrace: stackTrace,
        message: 'No Internet connection.',
      );
    }

    // -------------------------------------------------------------------------
    // HTTP CLIENT EXCEPTION
    // -------------------------------------------------------------------------

    on http.ClientException catch (e, stackTrace) {
      return _networkFailure(
        method: 'DELETE',
        url: deleteUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // HTTP EXCEPTION
    // -------------------------------------------------------------------------

    on HttpException catch (e, stackTrace) {
      return _networkFailure(
        method: 'DELETE',
        url: deleteUrl,
        error: e,
        stackTrace: stackTrace,
      );
    }

    // -------------------------------------------------------------------------
    // UNKNOWN
    // -------------------------------------------------------------------------

    catch (e, stackTrace) {
      _logError(
        method: 'DELETE',
        url: deleteUrl,
        error: e,
        stackTrace: stackTrace,
      );

      return Failure(
        FailureReason.unknown,
        'Unexpected error: ${e.toString()}',
      );
    }
  }
}