// network_result.dart

enum FailureReason {
  network,
  timeout,
  unauthorized,
  validation,
  notFound,

  /// HTTP 429. Added because server-side rate limiting is arriving: without a
  /// reason of its own a throttled merchant saw the generic "an error
  /// occurred" and retried immediately, making the throttling worse.
  rateLimited,

  unknown,
}

sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(FailureReason reason, String message, Map<String, dynamic>? validationErrors) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      final failure = this as Failure<T>;
      return onFailure(failure.reason, failure.message, failure.validationErrors);
    }
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final FailureReason reason;
  final String message;
  final Map<String, dynamic>? validationErrors;

  const Failure(
      this.reason,
      this.message, {
        this.validationErrors,
      });
}
/// Reads a human-readable message out of a decoded API response body.
///
/// R7-N6. Twenty-six call sites across twelve controllers read the message as
/// `data['data']['message']`, and `?? 'fallback'` DOES NOT make that safe: the
/// `[]` runs on `data['data']` first, so when the server answers
/// `{"status": 1}` with no `data` object at all, the index throws
/// NoSuchMethodError on null before the `??` is ever reached. Two of those
/// sites (home_controller setStoreIdData) had no fallback either, so a
/// present-but-null message reached commonToast -- whose parameter is a
/// non-nullable String (common_snak_bar_widget.dart:33-34) -- and threw a
/// TypeError.
///
/// Both failures land INSIDE `onSuccess`, which is what makes them worse than
/// a visible crash: everything after the toast in that closure is skipped. In
/// setStoreIdData that meant Prefs.setStoreID, the FCM re-registration and
/// StoreChangeService.notifyStoreChanged all silently did not run, leaving the
/// app pointed at the OLD store while the server had already switched.
///
/// The precedence mirrors the one hand-written correctly at
/// product_controller.dart:143, which is the pattern this generalises:
/// nested `data.message` first, then a top-level `message`, then `error`,
/// then [fallback].
String apiMessage(dynamic body, {String fallback = 'Error'}) {
  if (body is! Map) return fallback;

  final nested = body['data'];
  if (nested is Map) {
    final message = nested['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
  }

  for (final key in const ['message', 'error']) {
    final value = body[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }

  return fallback;
}

/// Reads a value out of a decoded API response body by PATH, returning null
/// instead of throwing when any level of the path is missing, null, or not a
/// Map.
///
/// R7-N6 (second half). `apiMessage` above fixed the twenty-odd `message`
/// reads, but the same crash shape exists for every OTHER nested read of a
/// decoded body, and those are worse: a message read that throws costs a
/// toast, whereas `data['data']['user_info']['current_store']` throwing in
/// store_setting_controller.deleteStoreData skips the `Prefs.setStoreID` that
/// follows it, so the app stays pointed at a store the server has just
/// deleted.
///
/// Why `[]` cannot be made safe at the call site:
///
///   * `data['data']['x'] ?? fallback` evaluates `data['data']['x']` FIRST.
///     When `data['data']` is absent the index runs on null and throws
///     NoSuchMethodError before `??` is ever consulted. The `??` makes the
///     expression LOOK guarded, which is why 24 of these survived review.
///   * `data['data']?['x']` guards null but NOT a wrong type: the server
///     answering `{"data": "ok"}` or `{"data": []}` still throws, because
///     String and List both reject a String subscript.
///
/// This walks the path and type-checks every level, so a missing key, an
/// explicit null, a scalar where an object was expected, and a list where an
/// object was expected all yield null.
dynamic apiValueAt(dynamic body, List<String> path) {
  dynamic node = body;

  for (final key in path) {
    if (node is! Map) return null;
    node = node[key];
  }

  return node;
}

/// [apiValueAt] coerced to a String, with [fallback] for absent, null and
/// blank values.
///
/// The `.toString()` is deliberate and is the second half of the fix. These
/// values are assigned straight into `TextEditingController.text`, into an
/// `RxString`, and passed to `commonToast(String msg, ...)` -- all three
/// NON-NULLABLE String positions (common_snak_bar_widget.dart:33). A JSON
/// number or bool reaching one of those is a TypeError, and `reward_point`
/// and `current_store` are exactly the fields a Laravel controller is most
/// likely to hand back unquoted: `loyality_controller.dart:45` assigned
/// `data['data']['reward_point']` directly to `.text`, so a server answering
/// `"reward_point": 150` instead of `"150"` crashed the settings screen.
String apiText(
  dynamic body,
  List<String> path, {
  String fallback = '',
}) {
  final value = apiValueAt(body, path);

  if (value == null) return fallback;

  final text = value.toString();

  return text.trim().isEmpty ? fallback : text;
}
