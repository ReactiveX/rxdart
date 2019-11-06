import 'dart:async';

typedef RetryWhenStreamFactory = Stream<void> Function(
    dynamic error, StackTrace stack);

/// An [Error] which can be thrown by a retry [Stream].
class RetryError extends Error {
  /// Message describing the retry error.
  final String message;

  /// A [List] of errors that where thrown while attempting to retry.
  final List<ErrorAndStacktrace> errors;

  RetryError._(this.message, this.errors);

  /// Constructs a [RetryError], including the [errors] that were encountered
  /// during the [count] retry stages.
  factory RetryError.withCount(int count, List<ErrorAndStacktrace> errors) =>
      RetryError._('Received an error after attempting $count retries', errors);

  /// Constructs a [RetryError], including the [errors] that were encountered
  /// during the retry stage.
  factory RetryError.onReviveFailed(List<ErrorAndStacktrace> errors) =>
      RetryError._('Received an error after attempting to retry.', errors);

  @override
  String toString() => message;
}

/// An Object which acts as a tuple containing both an error and the
/// corresponding stack trace.
class ErrorAndStacktrace {
  /// A reference to the wrapped error object.
  final dynamic error;

  /// A reference to the wrapped [StackTrace]
  final StackTrace stackTrace;

  /// Constructs an object containing both an [error] and the
  /// corresponding [stackTrace].
  ErrorAndStacktrace(this.error, this.stackTrace);

  @override
  String toString() {
    return 'ErrorAndStacktrace{error: $error, stacktrace: $stackTrace}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorAndStacktrace &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          stackTrace == other.stackTrace;

  @override
  int get hashCode => error.hashCode ^ stackTrace.hashCode;
}
