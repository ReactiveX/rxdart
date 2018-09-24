import 'dart:async';

import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/src/observables/value_observable.dart';
import 'package:rxdart/src/subjects/subject.dart';

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
///     final subject = new BehaviorSubject<int>();
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
///     final subject = new BehaviorSubject<int>(seedValue: 1);
///
///     subject.stream.listen(print); // prints 1
///     subject.stream.listen(print); // prints 1
///     subject.stream.listen(print); // prints 1
class BehaviorSubject<T> extends Subject<T> implements ValueObservable<T> {
  _Wrapper<T> _wrapper;

  BehaviorSubject._(
    StreamController<T> controller,
    Observable<T> observable,
    this._wrapper,
  ) : super(controller, observable);

  factory BehaviorSubject({
    T seedValue,
    void onListen(),
    void onCancel(),
    bool sync: false,
  }) {
    // ignore: close_sinks
    final StreamController<T> controller = new StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final _Wrapper<T> wrapper = new _Wrapper<T>(seedValue);

    return new BehaviorSubject<T>._(
        controller,
        new Observable<T>.defer(
            () => wrapper.latestValue == null
                ? controller.stream
                : new Observable<T>(controller.stream)
                    .startWith(wrapper.latestValue),
            reusable: true),
        wrapper);
  }

  @override
  void onAdd(T event) {
    _wrapper.latestValue = event;
  }

  @override
  ValueObservable<T> get stream => this;

  /// Get the latest value emitted by the Subject
  @override
  T get value => _wrapper.latestValue;

  /// Set and emit the new value
  set value(T newValue) => add(newValue);
}

class _Wrapper<T> {
  T latestValue;

  _Wrapper(this.latestValue);
}
