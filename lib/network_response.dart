abstract class NetworkResponse<T> {
  const NetworkResponse();
  factory NetworkResponse.success(T results) = Success<T>;
  factory NetworkResponse.error(Object error) = Error<T>;
  factory NetworkResponse.loading() = Loading<T>;
  factory NetworkResponse.hasNotStartedYet() = HasNotStartedYet<T>;

  R fold<R>({
    required R Function(T result) onSuccess,
    required R Function(Object error) onError,
    required R Function() onLoading,
    required R Function() onNotStartedYet,
  }) {
    if (this is Loading) {
      return onLoading();
    } else if (this is Error) {
      this as Error;
      return onError((this as Error).error);
    } else if (this is Success) {
      return onSuccess((this as Success<T>).results);
    } else {
      return onNotStartedYet();
    }
  }
}

class Success<T> extends NetworkResponse<T> {
  final T _results;
  T get results => _results;
  const Success(this._results);
}

class HasNotStartedYet<T> extends NetworkResponse<T> {
  const HasNotStartedYet();
}

class Loading<T> extends NetworkResponse<T> {
  const Loading();
}

class Error<T> extends NetworkResponse<T> {
  final Object _error;
  Object get error => _error;
  const Error(this._error);
}
