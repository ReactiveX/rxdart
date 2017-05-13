import 'dart:async';
import 'package:rxdart/src/observable.dart';

/// A combo class that operates as both a StreamController and Observable.
/// This allows one to send data, error and done events to listeners. Moreover,
/// one can directly scan, flatMap, etc those events directly through the
/// Subject.
///
/// PublishSubject is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// While multiple consumers can subscribe to the PublishSubject, no events will
/// be replayed. If you're looking for such functionality, please examine
/// `ReplaySubject` or `BehaviorSubject`.
///
/// ### Example
///
///     final subject = new PublishSubject<int>();
///
///     subject.listen(print);
///
///     subject.add(1); // prints 1
///     subject.add(2); // prints 2
///     subject.add(3); // prints 3
class PublishSubject<T> extends Observable<T> implements StreamController<T> {
  bool _isAddingStreamItems = false;
  _PublishSubjectStream<T> _subjectStream;

  PublishSubject({void onListen(), onCancel(), bool sync: false})
      : super(new _PublishSubjectStream<T>(
            onListen: onListen, onCancel: onCancel, sync: false)) {
    // ignore: avoid_as
    _subjectStream = stream as _PublishSubjectStream<T>;
  }

  @override
  StreamSink<T> get sink => _subjectStream._controller.sink;

  @override
  ControllerCallback get onListen => _subjectStream._controller.onListen;

  @override
  set onListen(void onListenHandler()) {
    _subjectStream._controller.onListen = onListenHandler;
  }

  @override
  ControllerCallback get onPause => throw new UnsupportedError(
      "PublishSubjects do not support pause callbacks");

  @override
  set onPause(void onPauseHandler()) => throw new UnsupportedError(
      "PublishSubjects do not support pause callbacks");

  @override
  ControllerCallback get onResume => throw new UnsupportedError(
      "PublishSubjects do not support resume callbacks");

  @override
  set onResume(void onResumeHandler()) => throw new UnsupportedError(
      "PublishSubjects do not support resume callbacks");

  @override
  ControllerCancelCallback get onCancel => _subjectStream._controller.onCancel;

  @override
  set onCancel(onCancelHandler()) {
    _subjectStream._controller.onCancel = onCancelHandler;
  }

  @override
  bool get isClosed => _subjectStream._controller.isClosed;

  @override
  bool get isPaused => _subjectStream._controller.isPaused;

  @override
  bool get hasListener => _subjectStream._controller.hasListener;

  @override
  Future<dynamic> get done => _subjectStream._controller.done;

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot add an error while items are being added from addStream");
    }

    _subjectStream._controller.addError(error, stackTrace);
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
      _subjectStream._controller.addError(e, s);

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
    _subjectStream._controller.add(event);
  }

  @override
  Future<dynamic> close() {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot close the subject while items are being added from addStream");
    }

    return _subjectStream._controller.close();
  }
}

class _PublishSubjectStream<T> extends Stream<T> {
  final StreamController<T> _controller;

  _PublishSubjectStream({void onListen(), onCancel(), bool sync: false})
      : _controller = new StreamController<T>.broadcast(
            onListen: onListen, onCancel: onCancel, sync: sync);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
