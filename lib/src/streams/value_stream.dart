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

  /// Returns last emitted value, or throws `"Null check operator used on a null value"` error
  /// if there has been no emission yet.
  T get requireValue => valueWrapper!.value;

  /// A flag that turns true as soon as at an error event has been emitted.
  bool get hasError => errorAndStackTrace != null;

  /// Last emitted error, or null if no error added or value exists.
  Object? get error => errorAndStackTrace?.error;

  /// Last emitted error, or throws `"Null check operator used on a null value"` error if no error added or value exists.
  Object get requireError => errorAndStackTrace!.error;
}
