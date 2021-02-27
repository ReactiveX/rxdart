import 'package:rxdart/src/utils/error_and_stacktrace.dart';
import 'package:rxdart/src/utils/value_wrapper.dart';

/// An [Stream] that provides synchronous access to the last emitted item
abstract class ValueStream<T> implements Stream<T> {
  /// Last emitted value wrapped in [ValueWrapper], or null if there has been no emission yet.
  /// To indicate that the latest value is null, return `ValueWrapper(null)`.
  /// See [hasValue]
  ValueWrapper<T>? get valueWrapper;

  /// Last emitted error and the corresponding stack trace,
  /// or null if no error added or value exists.
  /// See [hasError]
  ErrorAndStackTrace? get errorAndStackTrace;
}

/// Extensions to easily access value and error.
extension ValueStreamExtensions<T> on ValueStream<T> {
  /// A flag that turns true as soon as at least one event has been emitted.
  bool get hasValue => valueWrapper != null;

  /// Returns last emitted value, or null if there has been no emission yet.
  T? get value => valueWrapper?.value;

  /// Returns last emitted value, failing if there is no value.
  /// Throws [error] if [hasError].
  /// Throws [StateError], if neither [hasData] nor [hasError].
  T get requireValue {
    final wrapper = valueWrapper;
    if (wrapper != null) {
      return wrapper.value;
    }

    final errorAndSt = errorAndStackTrace;
    if (errorAndSt != null) {
      throw errorAndSt.error;
    }

    throw StateError('Neither data event nor error event has been emitted.');
  }

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
