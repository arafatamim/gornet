abstract class Deferred<T> {
  const Deferred();
  factory Deferred.success(T results) = Success<T>;
  factory Deferred.error(Object error, StackTrace? stackTrace) = Error<T>;
  factory Deferred.inProgress() = InProgress<T>;
  factory Deferred.idle() = Idle<T>;

  R where<R>({
    R Function(T result)? onSuccess,
    R Function(Object error, StackTrace? stackTrace)? onError,
    R Function()? onInProgress,
    R Function()? onIdle,
    R Function()? orElse,
  }) {
    R callFallback() {
      if (orElse != null) {
        return orElse.call();
      } else {
        throw Exception("Fallback is not provided");
      }
    }

    if (this is InProgress) {
      if (onInProgress != null) {
        return onInProgress();
      } else {
        return callFallback();
      }
    } else if (this is Error) {
      final err = this as Error;
      if (onError != null) {
        return onError(err.error, err.stackTrace);
      } else {
        return callFallback();
      }
    } else if (this is Success) {
      if (onSuccess != null) {
        return onSuccess((this as Success<T>).results);
      } else {
        return callFallback();
      }
    } else {
      if (onIdle != null) {
        return onIdle();
      } else {
        return callFallback();
      }
    }
  }
}

class Success<T> extends Deferred<T> {
  final T _results;
  T get results => _results;
  const Success(this._results);
}

class Idle<T> extends Deferred<T> {
  const Idle();
}

class InProgress<T> extends Deferred<T> {
  const InProgress();
}

class Error<T> extends Deferred<T> {
  final Object _error;
  final StackTrace? _stackTrace;

  Object get error => _error;
  StackTrace? get stackTrace => _stackTrace;
  const Error(this._error, [this._stackTrace]);
}
