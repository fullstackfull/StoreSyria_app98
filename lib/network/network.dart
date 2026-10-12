import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/utils/app_log.dart';
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

  // SEC-20c / R7-04. This class used to own a `Logger` with no filter and no
  // level, so every request and every full response body was written to the
  // device log in release builds too — and the login response body carries the
  // bearer token. All logging now goes through AppLog, which is inert when
  // kReleaseMode is true and redacts tokens at every level.

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

  /// THE ONLY PLACE THE `Authorization` HEADER IS BUILT — finding R7-N1 /
  /// NEW-auth-header-six-sites.
  ///
  /// It used to be built in six live or near-live places: here plus four
  /// hand-rolled bypasses (logout, profile update, category create/update and
  /// the FCM example) and three more commented out in the payment-settings
  /// controllers, so the bypass pattern was habitual rather than accidental.
  /// Three of the four live bypasses were WRITE operations, which means any
  /// future change to how the app presents its token — a scheme change, a
  /// refresh, an added header — applied only to the network layer would have
  /// left those endpoints silently broken.
  ///
  /// Public so the remaining `http.MultipartRequest` call sites can use it
  /// directly. `MultipartRequest.finalize()` overwrites `content-type` with the
  /// multipart boundary, so handing these headers to a multipart request is
  /// safe — and is already what this class does internally.
  ///
  /// Emits exactly the same bytes as before for every pre-existing call site.
  static Map<String, String> authHeaders() {
    final token = Prefs.getToken();

    final headers = Map<String, String>.from(baseHeaders);

    if (token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    return headers;
  }

  // ===========================================================================
  // REQUEST LOGGER
  // ===========================================================================

  // NOTE: deliberately takes NO `headers` argument. Request headers carry the
  // Authorization bearer token and must never reach a log sink.
  static void _logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
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
      buffer.writeln(AppLog.prettyJson(body));
    }

    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );

    AppLog.d(buffer.toString());
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
      // AppLog.prettyJson masks `token`, `access_token`, `password` and any
      // `Bearer <...>` substring, so the login response no longer discloses the
      // bearer token even in a debug build.
      buffer.writeln(AppLog.prettyJson(response.body));
    }

    buffer.writeln(
      '══════════════════════════════════════════════════════',
    );

    AppLog.d(buffer.toString());
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
    AppLog.e(
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
    String? message,
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
      message ?? 'connection_failed'.tr,
    );
  }

  // ===========================================================================
  // ERROR RESPONSE
  // ===========================================================================

  static Failure<T> _handleErrorResponse<T>(
      http.Response response,
      ) {
    String message = 'error_occurred'.tr;
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
      message = 'server_error'.tr;
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

        if (message == 'error_occurred'.tr ||
            message == 'Unknown error') {
          message = 'resource_not_found'.tr;
        }

        break;

    // -----------------------------------------------------------------------
    // 500
    // -----------------------------------------------------------------------

      case 500:
        reason = FailureReason.unknown;
        message = 'server_internal_error'.tr;
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
      final headers = authHeaders();

      _logRequest(
        method: 'GET',
        url: getUrl,
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
        message: 'no_internet_connection'.tr,
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
        'unexpected_error'.tr,
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
      final headers = authHeaders();

      _logRequest(
        method: 'POST',
        url: postUrl,
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
        message: 'no_internet_connection'.tr,
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
        'unexpected_error'.tr,
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
      final headers = authHeaders();

      _logRequest(
        method: 'PUT',
        url: putUrl,
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
        message: 'no_internet_connection'.tr,
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
        'unexpected_error'.tr,
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

      final headers = authHeaders();

      request.headers.addAll(headers);
      request.fields.addAll(fields);

      // -----------------------------------------------------------------------
      // LOG REQUEST
      // -----------------------------------------------------------------------

      _logRequest(
        method: 'MULTIPART POST',
        url: url,
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
        message: 'no_internet_connection'.tr,
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
        'unexpected_error'.tr,
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
      final headers = authHeaders();

      _logRequest(
        method: 'DELETE',
        url: deleteUrl,
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
        message: 'no_internet_connection'.tr,
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
        'unexpected_error'.tr,
      );
    }
  }
}