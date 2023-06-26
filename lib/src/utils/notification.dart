// ignore_for_file: deprecated_member_use_from_same_package

import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// The type of event used in [RxNotification]
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
/// emitted as part of the [RxNotification].
abstract class RxNotification<T> {
  /// References the [NotificationKind] of this [RxNotification] event.
  final NotificationKind kind;

  const RxNotification._(this.kind);

  /// Constructs a [RxNotification] with [NotificationKind.data] and wraps a [value]
  factory RxNotification.data(T value) => DataNotification<T>(value);

  /// Constructs a [RxNotification] with [NotificationKind.done].
  factory RxNotification.done() => DoneNotification();

  /// Constructs a [RxNotification] with [NotificationKind.error] and wraps an [error] and [stackTrace]
  factory RxNotification.error(Object error, StackTrace? stackTrace) =>
      ErrorNotification.from(error, stackTrace);
}

/// TODO
extension RxNotificationExtensions<T> on RxNotification<T> {
  /// A test to determine if this [RxNotification] wraps a data event
  bool get isData => kind == NotificationKind.data;

  /// A test to determine if this [RxNotification] wraps a done event
  bool get isDone => kind == NotificationKind.done;

  /// A test to determine if this [RxNotification] wraps an error event
  bool get isError => kind == NotificationKind.error;

  /// Returns data if [kind] is [NotificationKind.data], otherwise throws a [StateError] error.
  T get requireDataValue => (this as DataNotification<T>).value;

  /// TODO
  T? get dataValueOrNull {
    final self = this;
    return self is DataNotification<T> ? self.value : null;
  }

  /// TODO
  ErrorAndStackTrace get requireErrorAndStackTrace =>
      (this as ErrorNotification).errorAndStackTrace;

  /// TODO
  ErrorAndStackTrace? get errorAndStackTraceOrNull {
    final self = this;
    return self is ErrorNotification ? self.errorAndStackTrace : null;
  }

  /// TODO
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

/// TODO
class DataNotification<T> extends RxNotification<T> {
  /// TODO
  final T value;

  /// TODO
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

/// TODO
class DoneNotification extends RxNotification<Never> {
  /// TODO
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

/// TODO
class ErrorNotification extends RxNotification<Never> {
  /// The wrapped error and stack trace, if applicable
  final ErrorAndStackTrace errorAndStackTrace;

  /// TODO
  Object get error => errorAndStackTrace.error;

  /// TODO
  StackTrace? get stackTrace => errorAndStackTrace.stackTrace;

  /// TODO
  const ErrorNotification(this.errorAndStackTrace)
      : super._(NotificationKind.error);

  /// TODO
  factory ErrorNotification.from(Object error, StackTrace? stackTrace) =>
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
