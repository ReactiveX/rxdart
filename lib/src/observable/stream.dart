library rx.observable.stream;

import 'dart:async';

import 'package:rxdart/src/observable.dart' show Observable;
import 'package:rxdart/src/operators/debounce.dart' show DebounceObservable;
import 'package:rxdart/src/operators/retry.dart' show RetryObservable;
import 'package:rxdart/src/operators/throttle.dart' show ThrottleObservable;
import 'package:rxdart/src/operators/buffer_with_count.dart' show BufferWithCountObservable;
import 'package:rxdart/src/operators/window_with_count.dart' show WindowWithCountObservable;
import 'package:rxdart/src/operators/flat_map.dart' show FlatMapObservable;

export 'dart:async';

class StreamObservable<T> extends Observable<T> {

  Stream stream;

  @override
  bool get isBroadcast {
    return (stream != null) ? stream.isBroadcast : super.isBroadcast;
  }

  StreamObservable();


  void setStream(Stream stream) {
    this.stream = stream;
  }

  StreamSubscription<T> listen(void onData(T event),
    { Function onError,
      void onDone(),
      bool cancelOnError }) => stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  Observable map(dynamic convert(T value)) => new StreamObservable<T>()..setStream(stream.map(convert));

  Observable<T> where(bool test(T event)) => new StreamObservable<T>()..setStream(stream.where(test));

  Observable<T> retry([int count]) => new RetryObservable<T>(stream, count);

  Observable<T> debounce(Duration duration) => new DebounceObservable<T>(stream, duration);

  Observable<T> throttle(Duration duration) => new ThrottleObservable<T>(stream, duration);

  Observable<List<T>> bufferWithCount(int count, [int skip]) => new BufferWithCountObservable<T, List<T>>(stream, count, skip) as Observable<List<T>>;

  Observable<Stream<T>> windowWithCount(int count, [int skip]) => new WindowWithCountObservable<T, StreamObservable<T>>(stream, count, skip) as Observable<Stream<T>>;

  Observable flatMap(Stream predicate(T value)) => new FlatMapObservable(stream, predicate);
}

abstract class ControllerMixin<T> {

  StreamController<T> controller;

  void throwError(e, s) => controller.addError(e, s);

}