import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// The type of event used in [Notification]
enum Kind {
  /// Specifies an onData event
  OnData,

  /// Specifies an onDone event
  OnDone,

  /// Specifies an error event
  OnError
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
  /// Returns if [kind] is [Kind.OnData], otherwise throws `"Null check operator used on a null value"` error.
  late T value;

  /// Same as [value], but allows null when [value] is not available.
  T? get valueOrNull => kind == Kind.OnData ? value : null;

  /// The wrapped error and stack trace, if applicable
  final ErrorAndStackTrace? errorAndStackTrace;

  /// Constructs a [Notification] which, depending on the [kind], wraps either
  /// [value], or [errorAndStackTrace], or neither if it is just a
  /// [Kind.OnData] event.
  Notification(this.kind, this.errorAndStackTrace);

  /// Constructs a [Notification] with [Kind.OnData] and wraps a [value]
  factory Notification.onData(T value) =>
      Notification<T>(Kind.OnData, null)..value = value;

  /// Constructs a [Notification] with [Kind.OnDone]
  factory Notification.onDone() => Notification(Kind.OnDone, null);

  /// Constructs a [Notification] with [Kind.OnError] and wraps an [error] and [stackTrace]
  factory Notification.onError(Object error, StackTrace? stackTrace) =>
      Notification<T>(Kind.OnError, ErrorAndStackTrace(error, stackTrace));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          valueOrNull == other.valueOrNull &&
          errorAndStackTrace == other.errorAndStackTrace;

  @override
  int get hashCode =>
      kind.hashCode ^ valueOrNull.hashCode ^ errorAndStackTrace.hashCode;

  @override
  String toString() =>
      'Notification{kind: $kind, value: $valueOrNull, errorAndStackTrace: $errorAndStackTrace}';

  /// A test to determine if this [Notification] wraps an onData event
  bool get isOnData => kind == Kind.OnData;

  /// A test to determine if this [Notification] wraps an onDone event
  bool get isOnDone => kind == Kind.OnDone;

  /// A test to determine if this [Notification] wraps an error event
  bool get isOnError => kind == Kind.OnError;
}
