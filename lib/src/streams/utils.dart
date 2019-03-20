import 'dart:async';

typedef RetryWhenStreamFactory = Stream<void> Function(
    dynamic error, StackTrace stack);

class RetryError extends Error {
  final String message;
  final List<ErrorAndStacktrace> errors;

  RetryError._(this.message, this.errors);

  factory RetryError.withCount(int count, List<ErrorAndStacktrace> errors) =>
      RetryError._('Received an error after attempting $count retries', errors);

  factory RetryError.onReviveFailed(List<ErrorAndStacktrace> errors) =>
      RetryError._('Received an error after attempting to retry.', errors);

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
