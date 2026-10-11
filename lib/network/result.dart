// network_result.dart

enum FailureReason {
  network,
  timeout,
  unauthorized,
  validation,
  notFound,
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