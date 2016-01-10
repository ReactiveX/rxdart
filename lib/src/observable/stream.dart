library rx.observable.stream;

import 'dart:async';

import 'package:rxdart/src/observable.dart' show Observable;
import 'package:rxdart/src/operators/debounce.dart' show DebounceObservable;
import 'package:rxdart/src/operators/retry.dart' show RetryObservable;
import 'package:rxdart/src/operators/throttle.dart' show ThrottleObservable;

export 'dart:async';

class StreamObservable<T> extends Observable<T> {

  Stream<T> stream;

  StreamObservable();

  void setStream(Stream<T> stream) {
    this.stream = stream;
  }

  StreamSubscription<T> listen(void onData(T event),
    { Function onError,
      void onDone(),
      bool cancelOnError }) => stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  Observable mapObservable(dynamic convert(T value)) => new StreamObservable()..setStream(stream.map(convert));

  Observable<T> retry([int count]) => new RetryObservable(stream, count);

  Observable<T> debounce(Duration duration) => new DebounceObservable(stream, duration);

  Observable<T> throttle(Duration duration) => new ThrottleObservable(stream, duration);

}

abstract class ControllerMixin<T> {

  StreamController<T> controller;

  void throwError(e, s) => controller.addError(e, s);

}