// COPIED from: https://github.com/hoc081098/rxdart_ext/blob/ed5ad736ac0b531348cebef9c1bf5a3130045e89/lib/src/not_replay_value_stream/value_subject.dart

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// A special [StreamController] that captures the latest item that has been
/// added to the controller.
///
/// [ValueSubject] is the same as [PublishSubject], with the ability to capture
/// the latest item has been added to the controller.
/// This [ValueSubject] always has the value, ie. [hasValue] is always true.
///
/// [ValueSubject] is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = ValueSubject<int>(1);
///
///     print(subject.value);          // prints 1
///
///     // observers will receive 3 and done events.
///     subject.stream.listen(print); // prints 2
///     subject.stream.listen(print); // prints 2
///     subject.stream.listen(print); // prints 2
///
///     subject.add(2);
///     subject.close();
@sealed
class ValueSubject<T> extends Subject<T> implements ValueStream<T> {
  final _StreamEvent<T> _event;

  ValueSubject._(
    StreamController<T> controller,
    this._event,
  ) : super(controller, controller.stream);

  /// Constructs a [ValueSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// [seedValue] becomes the current [value] of Subject.
  ///
  /// See also [StreamController.broadcast].
  factory ValueSubject(
    T seedValue, {
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    return ValueSubject._(
      controller,
      _StreamEvent.data(seedValue),
    );
  }

  @override
  void onAdd(T event) => _event.onData(event);

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) =>
      _event.onError(ErrorAndStackTrace(error, stackTrace));

  @override
  ValueStream<T> get stream => _ValueSubjectStream(this);

  @nonVirtual
  @override
  Object get error {
    final errorAndSt = _event.errorAndStackTrace;
    if (errorAndSt != null) {
      return errorAndSt.error;
    }
    throw ValueStreamError.hasNoError();
  }

  @nonVirtual
  @override
  Object? get errorOrNull => _event.errorAndStackTrace?.error;

  @nonVirtual
  @override
  bool get hasError => _event.errorAndStackTrace != null;

  @nonVirtual
  @override
  StackTrace? get stackTrace => _event.errorAndStackTrace?.stackTrace;

  @nonVirtual
  @override
  T get value => _event.value;

  @nonVirtual
  @override
  T get valueOrNull => _event.value;

  @nonVirtual
  @override
  bool get hasValue => true;

  @nonVirtual
  @override
  StreamNotification<T>? get lastEventOrNull {
    // data event
    if (_event.lastEventIsData) {
      return DataNotification(value);
    }

    // error event
    final errorAndSt = _event.errorAndStackTrace;
    if (errorAndSt != null) {
      return ErrorNotification(errorAndSt);
    }

    // no event
    return null;
  }

  @override
  bool get isReplayValueStream => false;
}

class _ValueSubjectStream<T> extends Stream<T> implements ValueStream<T> {
  final ValueSubject<T> _subject;

  _ValueSubjectStream(this._subject);

  @override
  bool get isBroadcast => true;

  // Override == and hashCode so that new streams returned by the same
  // subject are considered equal.
  // The subject returns a new stream each time it's queried,
  // but doesn't have to cache the result.

  @override
  int get hashCode => _subject.hashCode ^ 0x35323532;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ValueSubjectStream && identical(other._subject, _subject);
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _subject.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  Object get error => _subject.error;

  @override
  Object? get errorOrNull => _subject.errorOrNull;

  @override
  bool get hasError => _subject.hasError;

  @override
  bool get hasValue => _subject.hasValue;

  @override
  StreamNotification<T>? get lastEventOrNull => _subject.lastEventOrNull;

  @override
  StackTrace? get stackTrace => _subject.stackTrace;

  @override
  T get value => _subject.value;

  @override
  T? get valueOrNull => _subject.valueOrNull;

  @override
  bool get isReplayValueStream => _subject.isReplayValueStream;
}

/// Class that holds latest value and lasted error emitted from Stream.
class _StreamEvent<T> {
  T _value;
  ErrorAndStackTrace? _errorAndStacktrace;
  var _lastEventIsData = false;

  /// Construct a [_StreamEvent] with data event.
  _StreamEvent.data(T seedValue)
      : _value = seedValue,
        _lastEventIsData = true;

  /// Keep error state.
  void onError(ErrorAndStackTrace errorAndStacktrace) {
    _errorAndStacktrace = errorAndStacktrace;
    _lastEventIsData = false;
  }

  /// Keep data state.
  void onData(T value) {
    _value = value;
    _lastEventIsData = true;
  }

  /// Last emitted value
  /// or null if no data added.
  T get value => _value;

  /// Last emitted error and the corresponding stack trace,
  /// or null if no error added.
  ErrorAndStackTrace? get errorAndStackTrace => _errorAndStacktrace;

  /// Check if the last emitted event is data event.
  bool get lastEventIsData => _lastEventIsData;
}
