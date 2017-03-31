import 'dart:async';
import 'package:rxdart/src/observable.dart';

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
///     subject.listen(print); // prints 3
///     subject.listen(print); // prints 3
///     subject.listen(print); // prints 3
///
/// ### Example with seed value
///
///     final subject = new BehaviorSubject<int>(seedValue: 1);
///
///     subject.listen(print); // prints 1
///     subject.listen(print); // prints 1
///     subject.listen(print); // prints 1
class BehaviorSubject<T> implements StreamController<T> {
  final StreamController<T> _controller;
  bool _isAddingStreamItems = false;
  T _latestValue;
  Observable<T> _observable;

  BehaviorSubject({T seedValue, void onListen(), onCancel(), bool sync: false})
      : _controller = new StreamController<T>.broadcast(
            onListen: onListen, onCancel: onCancel, sync: sync),
        _latestValue = seedValue {
    _observable = new Observable<T>.defer(
        () => _latestValue == null
            ? _controller.stream
            : new Observable<T>(_controller.stream).startWith(_latestValue),
        reusable: true);
  }

  @override
  Observable<T> get stream => _observable;

  @override
  StreamSink<T> get sink => _controller.sink;

  @override
  ControllerCallback get onListen => _controller.onListen;

  @override
  set onListen(void onListenHandler()) {
    _controller.onListen = onListenHandler;
  }

  @override
  ControllerCallback get onPause => throw new UnsupportedError(
      "BehaviorSubjects do not support pause callbacks");

  @override
  set onPause(void onPauseHandler()) => throw new UnsupportedError(
      "BehaviorSubjects do not support pause callbacks");

  @override
  ControllerCallback get onResume => throw new UnsupportedError(
      "BehaviorSubjects do not support resume callbacks");

  @override
  set onResume(void onResumeHandler()) => throw new UnsupportedError(
      "BehaviorSubjects do not support resume callbacks");

  @override
  ControllerCancelCallback get onCancel => _controller.onCancel;

  @override
  set onCancel(onCancelHandler()) {
    _controller.onCancel = onCancelHandler;
  }

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  bool get hasListener => _controller.hasListener;

  @override
  Future<dynamic> get done => _controller.done;

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot add an error while items are being added from addStream");
    }

    _controller.addError(error, stackTrace);
  }

  @override
  Future<dynamic> addStream(Stream<T> source, {bool cancelOnError: true}) {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot add items while items are being added from addStream");
    }

    final Completer<T> completer = new Completer<T>();
    _isAddingStreamItems = true;

    source.listen((T item) {
      _add(item);
    }, onError: (dynamic e, dynamic s) {
      _controller.addError(e, s);

      if (cancelOnError) {
        _isAddingStreamItems = false;
        completer.completeError(e);
      }
    }, onDone: () {
      _isAddingStreamItems = false;
      completer.complete();
    }, cancelOnError: cancelOnError);

    return completer.future;
  }

  @override
  void add(T event) {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot add items while items are being added from addStream");
    }

    _add(event);
  }

  void _add(T event) {
    _latestValue = event;

    _controller.add(event);
  }

  @override
  Future<dynamic> close() {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot close the subject while items are being added from addStream");
    }

    _latestValue = null;

    return _controller.close();
  }
}
