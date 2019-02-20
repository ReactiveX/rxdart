/// The type of event
enum Kind { OnData, OnDone, OnError }

/// A class that encapsulates the [Kind] of event, value of the event in case of
/// onData, or the Error in the case of onError.

/// A container object that wraps the [Kind] of event (OnData, OnDone, OnError),
/// and the item or error that was emitted. In the case of onDone, no data is
/// emitted as part of the [Notification].
class Notification<T> {
  final Kind kind;
  final T value;
  final dynamic error;
  final StackTrace stackTrace;

  Notification(this.kind, this.value, this.error, this.stackTrace);

  factory Notification.onData(T value) =>
      Notification<T>(Kind.OnData, value, null, null);

  factory Notification.onDone() =>
      Notification<T>(Kind.OnDone, null, null, null);

  factory Notification.onError(dynamic e, StackTrace s) =>
      Notification<T>(Kind.OnError, null, e, s);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Notification &&
        this.kind == other.kind &&
        this.error == other.error &&
        this.stackTrace == other.stackTrace &&
        this.value == other.value;
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

  bool get isOnData => kind == Kind.OnData;

  bool get isOnDone => kind == Kind.OnDone;

  bool get isOnError => kind == Kind.OnError;
}
