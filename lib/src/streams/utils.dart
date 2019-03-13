import 'dart:async';

typedef StreamFactory<T> = Stream<T> Function();
typedef RetryWhenStreamFactory = Stream<void> Function(
    dynamic error, StackTrace stack);

class RetryError extends Error {
  final String message;
  final List<ErrorAndStacktrace> errors;

  RetryError(this.message, this.errors);

  @override
  String toString() => message;
}

class ErrorAndStacktrace {
  final dynamic error;
  final StackTrace stacktrace;

  ErrorAndStacktrace(this.error, this.stacktrace);

  @override
  String toString() {
    return 'ErrorAndStacktrace{error: $error, stacktrace: $stacktrace}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorAndStacktrace &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          stacktrace == other.stacktrace;

  @override
  int get hashCode => error.hashCode ^ stacktrace.hashCode;
}
