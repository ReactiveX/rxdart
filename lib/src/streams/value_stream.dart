/// An [Stream] that provides synchronous access to the last emitted item
abstract class ValueStream<T> implements Stream<T> {
  /// Returns the last emitted value, failing if there is no value.
  /// See [hasValue] to determine whether [value] has already been set.
  ///
  /// Throws [ValueIsMissingError] if has no value or has error.
  T get value;

  /// Returns either [value], or `null`, should [value] not yet have been set.
  T? get valueOrNull;

  /// Returns `true` when [value] is available.
  bool get hasValue;

  /// Returns last emitted error, failing if there is no error.
  /// Throws [StateError] if no error added or value exists.
  Object get error;

  /// Last emitted error, or `null` if no error added or value exists.
  Object? get errorOrNull;

  /// A flag that turns true as soon as at an error event has been emitted.
  bool get hasError;

  /// Returns [StackTrace] of the last emitted error,
  /// or `null` if no error added or value exists or error has without [StackTrace].
  StackTrace? get stackTraceOrNull;
}

class ValueIsMissingError extends Error {
  final bool _hasError;

  ValueIsMissingError(this._hasError);

  @override
  String toString() {
    final message = _hasError
        ? 'Last emitted event is an error event'
        : 'Neither data event nor error event has been emitted';
    return 'MissingValueError: $message. You should check ValueStream.hasValue before accessing ValueStream.value, or use ValueStream.valueOrNull instead.';
  }
}

class MissingErrorError extends Error {
  final bool _hasValue;

  MissingErrorError(this._hasValue);

  @override
  String toString() {
    final message = _hasValue
        ? 'Last emitted event is a data event'
        : 'Neither data event nor error event has been emitted';
    return 'MissingErrorError: $message. You should check ValueStream.hasError before accessing ValueStream.error, or use ValueStream.errorOrNull instead.';
  }
}
