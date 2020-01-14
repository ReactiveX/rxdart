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
  final T value;

  /// The wrapped error, if applicable
  final dynamic error;

  /// The wrapped stackTrace, if applicable
  final StackTrace stackTrace;

  /// Constructs a [Notification] which, depending on the [kind], wraps either
  /// [value], or [error] and [stackTrace], or neither if it is just a
  /// [Kind.OnData] event.
  const Notification(this.kind, this.value, this.error, this.stackTrace);

  /// Constructs a [Notification] with [Kind.OnData] and wraps a [value]
  factory Notification.onData(T value) =>
      Notification<T>(Kind.OnData, value, null, null);

  /// Constructs a [Notification] with [Kind.OnDone]
  factory Notification.onDone() =>
      const Notification(Kind.OnDone, null, null, null);

  /// Constructs a [Notification] with [Kind.OnError] and wraps an [error] and [stackTrace]
  factory Notification.onError(dynamic error, StackTrace stackTrace) =>
      Notification<T>(Kind.OnError, null, error, stackTrace);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Notification &&
        kind == other.kind &&
        error == other.error &&
        stackTrace == other.stackTrace &&
        value == other.value;
  }

  @override
  int get hashCode {
    return kind.hashCode ^
        error.hashCode ^
        stackTrace.hashCode ^
        value.hashCode;
  }

  @override
  String toString() {
    return 'Notification{kind: $kind, value: $value, error: $error, stackTrace: $stackTrace}';
  }

  /// A test to determine if this [Notification] wraps an onData event
  bool get isOnData => kind == Kind.OnData;

  /// A test to determine if this [Notification] wraps an onDone event
  bool get isOnDone => kind == Kind.OnDone;

  /// A test to determine if this [Notification] wraps an error event
  bool get isOnError => kind == Kind.OnError;
}
