import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// The type of event used in [StreamNotification]
enum NotificationKind {
  /// Specifies a data event
  data,

  /// Specifies a done event
  done,

  /// Specifies an error event
  error
}

/// A class that encapsulates the [NotificationKind] of event, value of the event in case of
/// onData, or the Error in the case of onError.

/// A container object that wraps the [NotificationKind] of event (OnData, OnDone, OnError),
/// and the item or error that was emitted. In the case of onDone, no data is
/// emitted as part of the [StreamNotification].
abstract class StreamNotification<T> {
  /// References the [NotificationKind] of this [StreamNotification] event.
  final NotificationKind kind;

  const StreamNotification._(this.kind);

  /// Constructs a [StreamNotification] with [NotificationKind.data] and wraps a [value]
  factory StreamNotification.data(T value) => DataNotification<T>(value);

  /// Constructs a [StreamNotification] with [NotificationKind.done].
  const factory StreamNotification.done() = DoneNotification;

  /// Constructs a [StreamNotification] with [NotificationKind.error] and wraps an [error] and [stackTrace]
  factory StreamNotification.error(Object error, [StackTrace? stackTrace]) =>
      ErrorNotification._internal(error, stackTrace);
}

/// Provides extension methods on [StreamNotification].
extension StreamNotificationExtensions<T> on StreamNotification<T> {
  /// A test to determine if this [StreamNotification] wraps a data event.
  bool get isData => kind == NotificationKind.data;

  /// A test to determine if this [StreamNotification] wraps a done event.
  bool get isDone => kind == NotificationKind.done;

  /// A test to determine if this [StreamNotification] wraps an error event.
  bool get isError => kind == NotificationKind.error;

  /// Returns data if [kind] is [NotificationKind.data],
  /// otherwise throws a [TypeError] error.
  /// See also [dataValueOrNull].
  T get requireDataValue => (this as DataNotification<T>).value;

  /// Returns data if [kind] is [NotificationKind.data],
  /// otherwise returns null.
  T? get dataValueOrNull {
    final self = this;
    return self is DataNotification<T> ? self.value : null;
  }

  /// Returns error and stack trace if [kind] is [NotificationKind.error],
  /// otherwise throws a [TypeError] error.
  ErrorAndStackTrace get requireErrorAndStackTrace =>
      (this as ErrorNotification).errorAndStackTrace;

  /// Returns error and stack trace if [kind] is [NotificationKind.error],
  /// otherwise returns null.
  ErrorAndStackTrace? get errorAndStackTraceOrNull {
    final self = this;
    return self is ErrorNotification ? self.errorAndStackTrace : null;
  }

  /// Invokes the appropriate function on the [StreamNotification] based on the [kind].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:prefer-inline')
  R when<R>({
    required R Function(T value) data,
    required R Function() done,
    required R Function(ErrorAndStackTrace) error,
  }) {
    final self = this;
    if (self is DataNotification<T>) {
      return data(self.value);
    }

    if (self is DoneNotification) {
      return done();
    }

    if (self is ErrorNotification) {
      return error(self.errorAndStackTrace);
    }

    throw StateError('Unknown notification $self');
  }
}

/// A notification representing a data event from a [Stream].
class DataNotification<T> extends StreamNotification<T> {
  /// The value of the data event.
  final T value;

  /// Constructs a [DataNotification] with the provided [value].
  const DataNotification(this.value) : super._(NotificationKind.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataNotification &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DataNotification{value: $value}';
}

/// A notification representing a done event from a [Stream].
class DoneNotification extends StreamNotification<Never> {
  /// Constructs a [DoneNotification].
  const DoneNotification() : super._(NotificationKind.done);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoneNotification && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'DoneNotification{}';
}

/// A notification representing an error event from a [Stream].
class ErrorNotification extends StreamNotification<Never> {
  /// The wrapped error and stack trace, if applicable
  final ErrorAndStackTrace errorAndStackTrace;

  /// The error of the error event.
  Object get error => errorAndStackTrace.error;

  /// The stack trace of the error event, if available.
  StackTrace? get stackTrace => errorAndStackTrace.stackTrace;

  /// Constructs an [ErrorNotification] with the provided [errorAndStackTrace].
  const ErrorNotification(this.errorAndStackTrace)
      : super._(NotificationKind.error);

  /// Constructs an [ErrorNotification] with the provided [error] and [stackTrace].
  factory ErrorNotification._internal(Object error, StackTrace? stackTrace) =>
      ErrorNotification(ErrorAndStackTrace(error, stackTrace));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorNotification &&
          runtimeType == other.runtimeType &&
          errorAndStackTrace == other.errorAndStackTrace;

  @override
  int get hashCode => errorAndStackTrace.hashCode;

  @override
  String toString() =>
      'ErrorNotification{error: $error, stackTrace: $stackTrace}';
}
