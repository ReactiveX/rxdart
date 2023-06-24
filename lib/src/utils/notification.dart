// ignore_for_file: deprecated_member_use_from_same_package

import 'package:rxdart/src/utils/empty.dart';
import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// The type of event used in [Notification]
enum Kind {
  /// Specifies an onData event
  onData,

  /// Specifies an onDone event
  onDone,

  /// Specifies an error event
  onError
}

/// This is an alias for [RxNotification].
@Deprecated('Use RxNotification<T> instead. Will be removed in v0.29.0')
typedef Notification<T> = RxNotification<T>;

/// A class that encapsulates the [Kind] of event, value of the event in case of
/// onData, or the Error in the case of onError.

/// A container object that wraps the [Kind] of event (OnData, OnDone, OnError),
/// and the item or error that was emitted. In the case of onDone, no data is
/// emitted as part of the [Notification].
class RxNotification<T> {
  /// References the [Kind] of this [Notification] event.
  final Kind kind;

  /// The data value, if applicable
  final Object? _value;

  /// The wrapped error and stack trace, if applicable
  final ErrorAndStackTrace? errorAndStackTrace;

  const RxNotification._(this.kind, this._value, this.errorAndStackTrace);

  /// Constructs a [Notification] which, depending on the [kind].
  /// This is an internal constructor, and should not be used directly.
  /// Use factory constructors instead. Will be removed in v0.29.0.
  @Deprecated('Use factory constructors instead. Will be removed in v0.29.0')
  const RxNotification(this.kind, this._value, this.errorAndStackTrace);

  /// Constructs a [Notification] with [Kind.onData] and wraps a [value]
  factory RxNotification.onData(T value) =>
      RxNotification<T>._(Kind.onData, value, null);

  /// Constructs a [Notification] with [Kind.onDone].
  factory RxNotification.onDone() =>
      RxNotification<Never>._(Kind.onDone, EMPTY, null);

  /// Constructs a [Notification] with [Kind.onError] and wraps an [error] and [stackTrace]
  factory RxNotification.onError(Object error, StackTrace? stackTrace) =>
      RxNotification<Never>._(
          Kind.onError, EMPTY, ErrorAndStackTrace(error, stackTrace));

  /// @internal
  /// Constructs a [Notification] with [Kind.onError] and wraps an [errorAndStackTrace].
  factory RxNotification.onErrorFrom(
          {required ErrorAndStackTrace errorAndStackTrace}) =>
      RxNotification<Never>._(Kind.onError, EMPTY, errorAndStackTrace);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RxNotification &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          _value == other._value &&
          errorAndStackTrace == other.errorAndStackTrace;

  @override
  int get hashCode =>
      kind.hashCode ^ _value.hashCode ^ errorAndStackTrace.hashCode;

  @override
  String toString() {
    switch (kind) {
      case Kind.onData:
        return 'Notification.onData{value: $_value}';
      case Kind.onDone:
        return 'Notification.onDone';
      case Kind.onError:
        final errorAndSt = errorAndStackTrace!;
        return 'Notification.onError{error: ${errorAndSt.error}, stackTrace: ${errorAndSt.stackTrace}}';
    }
  }

  /// A test to determine if this [Notification] wraps an onData event
  bool get isOnData => kind == Kind.onData;

  /// A test to determine if this [Notification] wraps an onDone event
  bool get isOnDone => kind == Kind.onDone;

  /// A test to determine if this [Notification] wraps an error event
  bool get isOnError => kind == Kind.onError;

  /// Returns data if [kind] is [Kind.onData], otherwise throws a [StateError] error.
  T get requireData => isNotEmpty(_value)
      ? _value as T
      : (throw StateError(
          'This notification has no data value, because its kind is $kind'));
}
