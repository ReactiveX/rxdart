import 'dart:async';

import 'package:rxdart/src/rx.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/src/transformers/start_with.dart';
import 'package:rxdart/src/transformers/start_with_error.dart';

/// A special StreamController that captures the latest item that has been
/// added to the controller, and emits that as the first item to any new
/// listener.
///
/// This subject allows sending data, error and done events to the listener.
/// The latest item that has been added to the subject will be sent to any
/// new listeners of the subject. After that, any new events will be
/// appropriately sent to the listeners. It is possible to provide a seed value
/// that will be emitted if no items have been added to the subject.
///
/// BehaviorSubject is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = BehaviorSubject<int>();
///
///     subject.add(1);
///     subject.add(2);
///     subject.add(3);
///
///     subject.stream.listen(print); // prints 3
///     subject.stream.listen(print); // prints 3
///     subject.stream.listen(print); // prints 3
///
/// ### Example with seed value
///
///     final subject = BehaviorSubject<int>.seeded(1);
///
///     subject.stream.listen(print); // prints 1
///     subject.stream.listen(print); // prints 1
///     subject.stream.listen(print); // prints 1
class BehaviorSubject<T> extends Subject<T> implements ValueStream<T> {
  _Wrapper<T> _wrapper;

  BehaviorSubject._(
    StreamController<T> controller,
    Stream<T> stream,
    this._wrapper,
  ) : super(controller, stream);

  /// Constructs a [BehaviorSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// See also [StreamController.broadcast]
  factory BehaviorSubject({
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>();

    return BehaviorSubject<T>._(
        controller,
        Rx.defer<T>(_deferStream(wrapper, controller, sync), reusable: true),
        wrapper);
  }

  /// Constructs a [BehaviorSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// [seedValue] becomes the current [value] and is emitted immediately.
  ///
  /// See also [StreamController.broadcast]
  factory BehaviorSubject.seeded(
    T seedValue, {
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>.seeded(seedValue);

    return BehaviorSubject<T>._(
      controller,
      Rx.defer<T>(_deferStream(wrapper, controller, sync), reusable: true),
      wrapper,
    );
  }

  static Stream<T> Function() _deferStream<T>(
          _Wrapper<T> wrapper, StreamController<T> controller, bool sync) =>
      () {
        if (wrapper.latestIsError) {
          return controller.stream.transform(StartWithErrorStreamTransformer(
              wrapper.latestError, wrapper.latestStackTrace, sync));
        } else if (wrapper.latestIsValue) {
          return controller.stream.transform(
              StartWithStreamTransformer(wrapper.latestValue, sync: sync));
        }

        return controller.stream;
      };

  @override
  void onAdd(T event) => _wrapper.setValue(event);

  @override
  void onAddError(Object error, [StackTrace stackTrace]) =>
      _wrapper.setError(error, stackTrace);

  @override
  ValueStream<T> get stream => this;

  @override
  bool get hasValue => _wrapper.latestIsValue;

  /// Get the latest value emitted by the Subject
  @override
  T get value => _wrapper.latestValue;

  /// Set and emit the new value
  set value(T newValue) => add(newValue);

  @override
  bool get hasError => _wrapper.latestIsError;

  /// Get the latest error emitted by the Subject
  @override
  Object get error => _wrapper.latestError;
}

class _Wrapper<T> {
  T latestValue;
  Object latestError;
  StackTrace latestStackTrace;

  bool latestIsValue = false, latestIsError = false;

  /// Non-seeded constructor
  _Wrapper();

  _Wrapper.seeded(this.latestValue) : latestIsValue = true;

  void setValue(T event) {
    latestIsValue = true;
    latestIsError = false;

    latestValue = event;

    latestError = null;
    latestStackTrace = null;
  }

  void setError(Object error, [StackTrace stackTrace]) {
    latestIsValue = false;
    latestIsError = true;

    latestValue = null;

    latestError = error;
    latestStackTrace = stackTrace;
  }
}
