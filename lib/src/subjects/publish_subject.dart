import 'dart:async';

import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/src/subjects/subject.dart';

/// Exactly like a normal broadcast StreamController with one exception:
/// `stream` returns an `Observable` instead of a `Stream`.
///
/// This Subject allows sending data, error and done events to the listener.
///
/// PublishSubject is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = new PublishSubject<int>();
///
///     // observer1 will receive all data and done events
///     subject.stream.listen(observer1);
///     subject.add(1);
///     subject.add(2);
///
///     // observer2 will only receive 3 and done event
///     subject.stream.listen(observe2);
///     subject.add(3);
///     subject.close();
class PublishSubject<T> extends Subject<T> {
  PublishSubject._(StreamController<T> controller, Observable<T> observable)
      : super(controller, observable);

  factory PublishSubject(
      {void onListen(), void onCancel(), bool sync = false}) {
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    return PublishSubject<T>._(
      controller,
      Observable<T>(controller.stream),
    );
  }
}
