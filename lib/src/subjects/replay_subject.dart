import 'dart:async';
import 'dart:collection';

import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/src/observables/replay_observable.dart';
import 'package:rxdart/src/subjects/subject.dart';

/// A special StreamController that captures all of the items that have been
/// added to the controller, and emits those as the first items to any new
/// listener.
///
/// This subject allows sending data, error and done events to the listener.
/// As items are added to the subject, the ReplaySubject will store them.
/// When the stream is listened to, those recorded items will be emitted to
/// the listener. After that, any new events will be appropriately sent to the
/// listeners. It is possible to cap the number of stored events by setting
/// a maxSize value.
///
/// ReplaySubject is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = new ReplaySubject<int>();
///
///     subject.add(1);
///     subject.add(2);
///     subject.add(3);
///
///     subject.stream.listen(print); // prints 1, 2, 3
///     subject.stream.listen(print); // prints 1, 2, 3
///     subject.stream.listen(print); // prints 1, 2, 3
///
/// ### Example with maxSize
///
///     final subject = new ReplaySubject<int>(maxSize: 2);
///
///     subject.add(1);
///     subject.add(2);
///     subject.add(3);
///
///     subject.stream.listen(print); // prints 2, 3
///     subject.stream.listen(print); // prints 2, 3
///     subject.stream.listen(print); // prints 2, 3
class ReplaySubject<T> extends Subject<T> implements ReplayObservable<T> {
  final Queue<T> _queue;
  final int _maxSize;

  factory ReplaySubject({
    int maxSize,
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

    final Queue<T> queue = new Queue<T>();

    return new ReplaySubject<T>._(
      controller,
      new Observable<T>.defer(
          () => new Observable<T>(controller.stream)
              .startWithMany(queue.toList(growable: false)),
          reusable: true),
      queue,
      maxSize,
    );
  }

  ReplaySubject._(
    StreamController<T> controller,
    Observable<T> observable,
    this._queue,
    this._maxSize,
  ) : super(controller, observable);

  @override
  void onAdd(T event) {
    if (_queue.length == _maxSize) {
      _queue.removeFirst();
    }

    _queue.add(event);
  }

  /// Synchronously get the values stored in Subject. May be empty.
  @override
  List<T> get values => _queue.toList(growable: false);
}
