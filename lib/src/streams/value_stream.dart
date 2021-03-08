import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// An [Stream] that provides synchronous access to the last emitted item
abstract class ValueStream<T> implements Stream<T> {
  /// Returns the last emitted value
  /// See [hasValue] to determine whether [value] has already been set.
  T get value;

  /// Returns either [value], or 'null', should [value] not yet have been set.
  T? get valueOrNull;

  /// Returns 'true' when [value] is available
  bool get hasValue;

  /// Last emitted error and the corresponding stack trace,
  /// or null if no error added or value exists.
  /// See [hasError]
  ErrorAndStackTrace? get errorAndStackTrace;
}

/// Extensions to easily access value and error.
extension ValueStreamExtensions<T> on ValueStream<T> {
  /// A flag that turns true as soon as at an error event has been emitted.
  bool get hasError => errorAndStackTrace != null;

  /// Last emitted error, or null if no error added or value exists.
  Object? get error => errorAndStackTrace?.error;

  /// Returns last emitted error, failing if there is no error.
  /// Throws [StateError] if no error added or value exists.
  Object get requireError {
    final errorAndSt = errorAndStackTrace;
    if (errorAndSt != null) {
      return errorAndSt.error;
    }

    if (hasValue) {
      throw StateError('Last emitted event is not an error event.');
    }

    throw StateError('Neither data event nor error event has been emitted.');
  }
}
