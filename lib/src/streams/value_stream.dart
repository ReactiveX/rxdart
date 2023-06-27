import 'package:rxdart/src/utils/error_and_stacktrace.dart';
import 'package:rxdart/src/utils/notification.dart';

/// A [Stream] that provides synchronous access to the last emitted value (aka. data event).
abstract class ValueStream<T> implements Stream<T> {
  /// Returns the last emitted value, failing if there is no value.
  /// See [hasValue] to determine whether [value] has already been set.
  ///
  /// Throws [ValueStreamError] if this Stream has no value.
  ///
  /// See also [valueOrNull].
  T get value;

  /// Returns the last emitted value, or `null` if value events haven't yet been emitted.
  T? get valueOrNull;

  /// Returns `true` when [value] is available,
  /// meaning this Stream has emitted at least one value.
  bool get hasValue;

  /// Returns last emitted error, failing if there is no error.
  /// See [hasError] to determine whether [error] has already been set.
  ///
  /// Throws [ValueStreamError] if this Stream has no error.
  ///
  /// See also [errorOrNull].
  Object get error;

  /// Returns the last emitted error, or `null` if error events haven't yet been emitted.
  Object? get errorOrNull;

  /// Returns `true` when [error] is available,
  /// meaning this Stream has emitted at least one error.
  bool get hasError;

  /// Returns [StackTrace] of the last emitted error.
  ///
  /// If error events haven't yet been emitted,
  /// or the last emitted error didn't have a stack trace,
  /// the returned value is `null`.
  StackTrace? get stackTrace;

  /// Returns the last emitted event (either data/value or error event).
  /// `null` if no value or error events have been emitted yet.
  StreamNotification<T>? get lastEventOrNull;
}

/// Extension methods on [ValueStream] related to [lastEventOrNull].
extension LastEventValueStreamExtensions<T> on ValueStream<T> {
  /// Returns `true` if the last emitted event is a data event (aka. a value event).
  bool get isLastEventValue => lastEventOrNull?.isData ?? false;

  /// Returns `true` if the last emitted event is an error event.
  bool get isLastEventError => lastEventOrNull?.isError ?? false;
}

/// Extension method on [ValueStream] to access the last emitted [ErrorAndStackTrace].
extension ErrorAndStackTraceValueStreamExtension<T> on ValueStream<T> {
  /// Returns the last emitted [ErrorAndStackTrace],
  /// or `null` if no error events have been emitted yet.
  ErrorAndStackTrace? get errorAndStackTraceOrNull {
    final error = errorOrNull;
    return error == null ? null : ErrorAndStackTrace(error, stackTrace);
  }
}

enum _MissingCase {
  value,
  error,
}

/// The error throw by [ValueStream.value] or [ValueStream.error].
class ValueStreamError extends Error {
  final _MissingCase _missingCase;

  ValueStreamError._(this._missingCase);

  /// Construct an [ValueStreamError] thrown by [ValueStream.value] when there is no value.
  factory ValueStreamError.hasNoValue() =>
      ValueStreamError._(_MissingCase.value);

  /// Construct an [ValueStreamError] thrown by [ValueStream.error] when there is no error.
  factory ValueStreamError.hasNoError() =>
      ValueStreamError._(_MissingCase.error);

  @override
  String toString() {
    switch (_missingCase) {
      case _MissingCase.value:
        return 'ValueStream has no value. You should check ValueStream.hasValue '
            'before accessing ValueStream.value, or use ValueStream.valueOrNull instead.';
      case _MissingCase.error:
        return 'ValueStream has no error. You should check ValueStream.hasError '
            'before accessing ValueStream.error, or use ValueStream.errorOrNull instead.';
    }
  }
}
