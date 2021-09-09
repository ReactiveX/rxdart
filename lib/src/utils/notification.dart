import 'package:rxdart/src/utils/error_and_stacktrace.dart';
import 'package:rxdart/src/utils/value_wrapper.dart';

/// The type of event used in [Notification]
enum Kind {
  /// Specifies an onData event
  onData,

  /// Specifies an onDone event
  onDone,

  /// Specifies an error event
  onError
}

/// A class that encapsulates the [Kind] of event, value of the event in case of
/// onData, or the Error in the case of onError.

/// A container object that wraps the [Kind] of event (OnData, OnDone, OnError),
/// and the item or error that was emitted. In the case of onDone, no data is
/// emitted as part of the [Notification].
class Notification<T> {
  /// References the [Kind] of this [Notification] event.
  final Kind kind;

  /// The wrapped value, if applicable
  final ValueWrapper<T>? _value;

  /// The wrapped error and stack trace, if applicable
  final ErrorAndStackTrace? errorAndStackTrace;

  /// Constructs a [Notification] which, depending on the [kind], wraps either
  /// [value], or [errorAndStackTrace], or neither if it is just a
  /// [Kind.onData] event.
  const Notification(this.kind, this._value, this.errorAndStackTrace);

  /// Constructs a [Notification] with [Kind.onData] and wraps a [value]
  factory Notification.onData(T value) =>
      Notification<T>(Kind.onData, ValueWrapper(value), null);

  /// Constructs a [Notification] with [Kind.onDone]
  factory Notification.onDone() => const Notification(Kind.onDone, null, null);

  /// Constructs a [Notification] with [Kind.onError] and wraps an [error] and [stackTrace]
  factory Notification.onError(Object error, StackTrace? stackTrace) =>
      Notification<T>(
          Kind.onError, null, ErrorAndStackTrace(error, stackTrace));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          _value == other._value &&
          errorAndStackTrace == other.errorAndStackTrace;

  @override
  int get hashCode =>
      kind.hashCode ^ _value.hashCode ^ errorAndStackTrace.hashCode;

  @override
  String toString() =>
      'Notification{kind: $kind, value: ${_value?.value}, errorAndStackTrace: $errorAndStackTrace}';

  /// A test to determine if this [Notification] wraps an onData event
  bool get isOnData => kind == Kind.onData;

  /// A test to determine if this [Notification] wraps an onDone event
  bool get isOnDone => kind == Kind.onDone;

  /// A test to determine if this [Notification] wraps an error event
  bool get isOnError => kind == Kind.onError;

  /// Returns data if [kind] is [Kind.onData], otherwise throws `"Null check operator used on a null value"` error.
  T get requireData => _value!.value;
}
