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
