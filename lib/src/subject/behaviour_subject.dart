import 'dart:async';

import 'package:rxdart/src/observable/stream.dart';

class _BehaviourSink<T> implements EventSink<T> {
  final EventSink<T> _outputSink;
  bool _isClosed = false;

  _BehaviourSink(this._outputSink, bool hasInitialValue, T initialValue) {
    if (hasInitialValue) _outputSink.add(initialValue);
  }

  @override void add(T data) => _outputSink.add(data);

  @override void addError(dynamic e, [StackTrace st]) => _outputSink.addError(e, st);

  @override void close() => _isClosed ? _outputSink.close() : null;
}

class BehaviourSubject<T> implements StreamController<T> {
  final StreamController<T> _controller;

  T _lastValue;
  bool _hasLastValue = false;

  @override
  StreamObservable<T> get stream => new StreamObservable<T>()..setStream(new Stream<T>.eventTransformed(_controller.stream,
          (EventSink<T> sink) => new _BehaviourSink<T>(sink, _controller.stream.isBroadcast && !isClosed ? _hasLastValue : false, _lastValue)));

  @override
  StreamSink<T> get sink => _controller.sink;

  @override
  ControllerCallback get onListen => _controller.onListen;

  @override
  set onListen(void onListenHandler()) {
    _controller.onListen = onListenHandler;
  }

  @override
  ControllerCallback get onPause => _controller.onPause;

  @override
  set onPause(void onPauseHandler()) {
    _controller.onPause = onPauseHandler;
  }

  @override
  ControllerCallback get onResume => _controller.onResume;

  @override
  set onResume(void onResumeHandler()) {
    _controller.onResume = onResumeHandler;
  }

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

  BehaviourSubject._(StreamController<T> controller) : _controller = controller;

  factory BehaviourSubject(
          {void onListen(),
          void onPause(),
          void onResume(),
          onCancel(),
          bool sync: false}) =>
      new BehaviourSubject<T>._(new StreamController<T>(
          onListen: onListen,
          onPause: onPause,
          onResume: onResume,
          onCancel: onCancel,
          sync: sync));

  factory BehaviourSubject.broadcast(
          {void onListen(), onCancel(), bool sync: false}) =>
      new BehaviourSubject<T>._(new StreamController<T>.broadcast(
          onListen: onListen, onCancel: onCancel, sync: sync));

  @override
  void addError(Object error, [StackTrace stackTrace]) => _controller.addError(error, stackTrace);

  @override
  Future<dynamic> addStream(Stream<T> source, {bool cancelOnError: true}) => _controller.addStream(source, cancelOnError: cancelOnError);

  @override
  void add(T event) {
    _lastValue = event;
    _hasLastValue = true;

    _controller.add(event);
  }

  @override
  Future<dynamic> close() {
    _hasLastValue = false;
    _lastValue = null;

    return _controller.close();
  }
}
