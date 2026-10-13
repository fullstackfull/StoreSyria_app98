import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show visibleForTesting;
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
    }

    // Defensive on purpose. The body may be HTML (a proxy or web-server error
    // page), empty, a JSON array instead of an object, or valid JSON whose
    // `message`/`errors` fields the server has since renamed. None of those may
    // turn an error response into an exception: the status-code switch below
    // still has to run, because that is what logs the merchant out on 401 and
    // tells them to slow down on 429.
    catch (_) {
      message = 'server_error'.tr;
    }

    // -------------------------------------------------------------------------
    // BLANK MESSAGE
    // -------------------------------------------------------------------------
    //
    // R7-N4. The parser above accepts any non-null `message`, and an empty
    // string is not null -- so a server answering `{"message": ""}` (or a
    // whitespace-only one, or `{"data": {"message": ""}}`) overwrote the
    // generic wording with nothing and the merchant got a completely BLANK
    // error toast with no indication of what failed.
    //
    // The 40 call sites that look defensive about this -- `message ?? 'Error
    // updating store information'` and friends -- cannot catch it: Failure
    // .message is a non-nullable String (result.dart:41), so every one of
    // those `??` fallbacks is dead code, which is what the analyzer was
    // reporting as `dead_null_aware_expression`.
    //
    // Resetting to the sentinel rather than to a literal is deliberate: the
    // status-code switch below tests for exactly this value, so a blank body
    // now inherits the per-status wording (session_expired on 401,
    // action_not_permitted on 403, resource_not_found on 404, ...) instead of
    // a generic string that would mask which code arrived.

    if (message.trim().isEmpty) {
      message = 'error_occurred'.tr;
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

        // The server-side authentication repair means 401 is now a REAL
        // response rather than a theoretical one: requests that used to be
        // waved through as anonymous are rejected. So this path must be safe
        // to hit several times at once -- see handleUnauthorized().
        if (message == 'error_occurred'.tr) {
          message = 'session_expired'.tr;
        }

        onUnauthorized();
        break;

    // -----------------------------------------------------------------------
    // 403 — authorized but not permitted
    // -----------------------------------------------------------------------
    //
    // Was unhandled, so it fell to `default` and reached the merchant as "an
    // error occurred". It matters now because the server-side authorization
    // work replaces "every token holder can do everything" with Laravel
    // Policies and Gates, and a policy denial answers 403 -- including when a
    // request carries a store_id the authenticated merchant does not own.
    //
    // Deliberately NOT a forced logout: 403 means the session is valid and the
    // action is not allowed, which is the opposite of 401. Clearing the
    // session here would turn one denied action into a logout loop.

      case 403:
        reason = FailureReason.unauthorized;

        if (message == 'error_occurred'.tr) {
          message = 'action_not_permitted'.tr;
        }

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
    // 422 — Laravel FormRequest validation
    // -----------------------------------------------------------------------
    //
    // Only 400 was handled before. Laravel answers a failed FormRequest with
    // 422, so server-side request validation would otherwise have surfaced to
    // the merchant as a generic "an error occurred" with the per-field errors
    // parsed but the reason thrown away.

      case 422:
        reason = FailureReason.validation;
        break;

    // -----------------------------------------------------------------------
    // 429 — rate limited
    // -----------------------------------------------------------------------

      case 429:
        {
          reason = FailureReason.rateLimited;

          // Honour Retry-After when the server sends it, so the message
          // tells the merchant how long to wait instead of inviting an
          // immediate retry that deepens the throttle. A non-numeric or
          // absent value falls back to the generic wording; Laravel's
          // ThrottleRequests sends delay-seconds.
          // Case-insensitive on purpose. dart:io lowercases header names
          // coming off the wire, but a mock client, a web (BrowserClient)
          // response or an intermediary need not, and a missed header here
          // silently downgrades the message rather than failing visibly.
          // Note RFC 7231 also allows an HTTP-date here; Laravel's
          // ThrottleRequests sends delay-seconds, and a date simply fails
          // int.tryParse and falls through to the generic wording.
          final retryAfterRaw = response.headers.entries
              .firstWhere(
                (e) => e.key.toLowerCase() == 'retry-after',
                orElse: () => const MapEntry<String, String>('', ''),
              )
              .value;

          final retryAfter = int.tryParse(retryAfterRaw.trim());

          // Shut the local gate for the window the server just named, so the
          // next scroll notification cannot spend another request learning the
          // same thing. See _rateLimitPreflight.
          _armRateLimitBackoff(retryAfter);

          if (retryAfter != null && retryAfter > 0) {
            message = 'too_many_requests_retry_after'.trParams({
              'seconds': retryAfter.toString(),
            });
          } else {
            message = 'too_many_requests'.tr;
          }
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

  /// True while a forced logout is in flight.
  ///
  /// The old guard compared `Get.currentRoute` against the literal `'/login'`,
  /// but this method navigates with `Get.offAll(() => NormalLoginWidget())`,
  /// which produces an unnamed route -- so the guard never matched. With the
  /// server now genuinely returning 401, several in-flight requests can fail
  /// at once (the dashboard alone fans out into a handful), and each one would
  /// have called Prefs.clear() and pushed another login screen. This latch
  /// makes the forced logout happen exactly once.
  static bool _unauthorizedInFlight = false;

  /// The forced-logout action, as a replaceable reference rather than a direct
  /// call.
  ///
  /// In production this IS [handleUnauthorized] -- same function, same
  /// behaviour. It exists as a field so a test can observe which status codes
  /// reach the forced-logout path and which must not (a 429 reaching it would
  /// clear the merchant's session and bounce them to the login screen for
  /// nothing more than being throttled) without having to stand up GetStorage
  /// and a navigator, neither of which exists in a unit test.
  @visibleForTesting
  static Future<void> Function() onUnauthorized = handleUnauthorized;

  /// Classifies an error response exactly as the request verbs do.
  ///
  /// A seam for tests only: the status-code mapping is otherwise private and
  /// reachable only through a live HTTP call, so it had no executable
  /// coverage at all. Production code must keep calling the verbs.
  @visibleForTesting
  static Failure<T> classifyErrorResponse<T>(http.Response response) =>
      _handleErrorResponse<T>(response);

  /// Clears the local session and returns to the login screen. Public so the
  /// two remaining hand-rolled multipart call sites can share it instead of
  /// duplicating the clear-and-navigate pair.
  static Future<void> handleUnauthorized() async {
    if (_unauthorizedInFlight) return;
    _unauthorizedInFlight = true;

    try {
      await Prefs.clear();

      // Kept exactly as it was, including the ineffective route comparison:
      // Get.offAll with a widget builder yields an unnamed route, so this
      // never matches. The latch above is what actually makes the forced
      // logout idempotent. Left in place rather than changed to
      // Get.offAllNamed so this commit introduces no navigation change.
      if (Get.currentRoute != '/login') {
        Get.offAll(
              () => NormalLoginWidget(),
        );
      }
    } finally {
      // Released after a short window so the burst of concurrent 401s that
      // triggered this collapses into one logout, while a genuine later 401
      // (a new session that also expires) is still handled.
      Timer(
        const Duration(seconds: 2),
        () => _unauthorizedInFlight = false,
      );
    }
  }

  // ===========================================================================
  // RATE-LIMIT BACKOFF
  // ===========================================================================

  /// NEW-429-RETRY-STORM. Until the `api` middleware group was given
  /// `throttleApi('120,1')` (repo A bootstrap/app.php), all 211 API route
  /// declarations were UNTHROTTLED, so a client that fired the same request
  /// repeatedly was merely wasteful. It is now self-harming: the 121st request
  /// in a minute is refused, and this app has a shape that reaches that number
  /// without anybody doing anything unusual.
  ///
  /// The shape is infinite scroll. Six screens attach a `ScrollController`
  /// listener that fires a page request whenever the viewport is within 200px
  /// of the bottom -- products_screen.dart:64-80, category_screen.dart:49,
  /// customer_screen.dart:60, customers_details.dart, and the two picker bottom
  /// sheets. The listener is called on EVERY scroll notification, and its only
  /// brake is `isLoading`, which the controller clears in a `finally` as soon
  /// as the request completes (product_controller.dart:168-170). So a merchant
  /// who keeps dragging at the end of a list while requests are FAILING gets
  /// one request per scroll notification: the failure path is faster than the
  /// success path, because it does not append rows and does not move the
  /// scroll extent away from the trigger band. That turns a single 429 into a
  /// stream of them, each one a toast, and keeps the throttle window full so
  /// the list cannot recover while the merchant is still looking at it.
  ///
  /// So the client needs a brake of its own. After a 429 this gate refuses to
  /// put another request on the wire until the server's own `Retry-After`
  /// window has passed, and answers with the same `Failure(rateLimited, ...)`
  /// the server would have produced -- same reason, same wording, now with a
  /// live countdown. Nothing above this layer has to change, and no caller can
  /// mistake it for a different outcome.
  ///
  /// It is deliberately NOT a retry: retrying is what caused the problem.
  /// And it is deliberately NOT on the forced-logout path -- 429 means "slow
  /// down", and clearing the session over a throttle is precisely the
  /// behaviour repo B's 401 handling must never be extended to cover.
  static DateTime? _rateLimitedUntil;

  /// Clamp. Laravel's ThrottleRequests sends the seconds remaining in the
  /// window, but the value arrives from the network and a long one (a proxy's
  /// `Retry-After: 3600`) would make the app look broken for an hour. Capping
  /// it means the gate never holds a request back LONGER than the server
  /// would: when the cap expires one request goes through, and if the window is
  /// genuinely still open the fresh 429 re-arms the gate with a fresh value.
  /// Self-correcting beats precise here.
  static const Duration _maxRateLimitBackoff = Duration(seconds: 60);

  /// Used when the response carries no usable `Retry-After`. Short on purpose:
  /// its job is to collapse the scroll storm described above, which arrives at
  /// several requests per second, not to impose a long penalty on a merchant
  /// who tapped twice.
  static const Duration _defaultRateLimitBackoff = Duration(seconds: 2);

  /// Clock seam. Only so a test can prove the gate EXPIRES without sleeping
  /// for it; production reads the real clock.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  /// Time left on the gate, or null when it is open.
  @visibleForTesting
  static Duration? rateLimitBackoffRemaining() {
    final until = _rateLimitedUntil;
    if (until == null) return null;

    final remaining = until.difference(clock());
    if (remaining <= Duration.zero) {
      _rateLimitedUntil = null;
      return null;
    }

    return remaining;
  }

  /// Opens the gate. Tests share process state, so this is how a test that
  /// classified a 429 avoids arming the gate for whatever runs next.
  @visibleForTesting
  static void resetRateLimitBackoff() {
    _rateLimitedUntil = null;
  }

  static void _armRateLimitBackoff(int? retryAfterSeconds) {
    var window = _defaultRateLimitBackoff;

    if (retryAfterSeconds != null && retryAfterSeconds > 0) {
      window = Duration(seconds: retryAfterSeconds);

      if (window > _maxRateLimitBackoff) {
        window = _maxRateLimitBackoff;
      }
    }

    final until = clock().add(window);

    // Never shorten a gate that is already further out. Several requests can
    // be in flight when the throttle trips, and the last 429 to land is not
    // necessarily the one carrying the largest remaining window.
    final current = _rateLimitedUntil;
    if (current == null || until.isAfter(current)) {
      _rateLimitedUntil = until;
    }
  }

  /// Consulted by every request verb BEFORE it touches the network. Returns
  /// null when the gate is open, and the failure the server would have
  /// produced when it is shut.
  static Failure<T>? _rateLimitPreflight<T>({
    required String method,
    required String url,
  }) {
    final remaining = rateLimitBackoffRemaining();
    if (remaining == null) return null;

    // Round UP, so the countdown never tells the merchant to retry at a moment
    // the gate is still shut.
    final seconds = (remaining.inMilliseconds / 1000).ceil();

    AppLog.d(
      'Request suppressed by the local rate-limit backoff '
      '($method $url): ${seconds}s remaining.',
    );

    return Failure<T>(
      FailureReason.rateLimited,
      'too_many_requests_retry_after'.trParams({
        'seconds': seconds.toString(),
      }),
    );
  }

  // ===========================================================================
  // GET
  // ===========================================================================

  static Future<Result<Map<String, dynamic>>> getRequest(
      String endPoint,
      ) async {
    final getUrl = API.baseUrl + endPoint;

    final throttled = _rateLimitPreflight<Map<String, dynamic>>(
      method: 'GET',
      url: getUrl,
    );
    if (throttled != null) return throttled;

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

    final throttled = _rateLimitPreflight<Map<String, dynamic>>(
      method: 'POST',
      url: postUrl,
    );
    if (throttled != null) return throttled;

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

    final throttled = _rateLimitPreflight<Map<String, dynamic>>(
      method: 'PUT',
      url: putUrl,
    );
    if (throttled != null) return throttled;

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

    final throttled = _rateLimitPreflight<Map<String, dynamic>>(
      method: 'MULTIPART',
      url: url,
    );
    if (throttled != null) return throttled;

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

    final throttled = _rateLimitPreflight<Map<String, dynamic>>(
      method: 'DELETE',
      url: deleteUrl,
    );
    if (throttled != null) return throttled;

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