library rx.observable.stream;

import 'dart:async';

import 'package:rxdart/src/observable.dart' show Observable;
import 'package:rxdart/src/operators/debounce.dart' show DebounceObservable;
import 'package:rxdart/src/operators/retry.dart' show RetryObservable;
import 'package:rxdart/src/operators/throttle.dart' show ThrottleObservable;
import 'package:rxdart/src/operators/buffer_with_count.dart' show BufferWithCountObservable;
import 'package:rxdart/src/operators/window_with_count.dart' show WindowWithCountObservable;
import 'package:rxdart/src/operators/flat_map.dart' show FlatMapObservable;
import 'package:rxdart/src/operators/flat_map_latest.dart' show FlatMapLatestObservable;
import 'package:rxdart/src/operators/take_until.dart' show TakeUntilObservable;
import 'package:rxdart/src/operators/scan.dart' show ScanObservable;
import 'package:rxdart/src/operators/tap.dart' show TapObservable;
import 'package:rxdart/src/operators/start_with.dart' show StartWithObservable;
import 'package:rxdart/src/operators/repeat.dart' show RepeatObservable;
import 'package:rxdart/src/operators/replay.dart' show ReplayObservable;
import 'package:rxdart/src/operators/min.dart' show MinObservable;
import 'package:rxdart/src/operators/max.dart' show MaxObservable;
import 'package:rxdart/src/operators/interval.dart' show IntervalObservable;
import 'package:rxdart/src/operators/sample.dart' show SampleObservable;
import 'package:rxdart/src/operators/time_interval.dart' show TimeIntervalObservable, TimeInterval;

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
      bool cancelOnError }) => stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError) as StreamSubscription<T>;

  Observable asBroadcastStream({
    void onListen(StreamSubscription<T> subscription),
    void onCancel(StreamSubscription<T> subscription) }) => new StreamObservable()..setStream(stream.asBroadcastStream(onListen: onListen, onCancel: onCancel));

  Observable map(dynamic convert(T value)) => new StreamObservable()..setStream(stream.map(convert));

  Observable asyncMap(dynamic convert(T value)) => new StreamObservable()..setStream(stream.asyncMap(convert));

  Observable<T> where(bool test(T event)) => new StreamObservable<T>()..setStream(stream.where(test));

  Observable expand(Iterable convert(T value)) => new StreamObservable()..setStream(stream.expand(convert));

  Observable asyncExpand(Stream convert(T value)) => new StreamObservable()..setStream(stream.asyncExpand(convert));

  Observable<T> distinct([bool equals(T previous, T next)]) => new StreamObservable<T>()..setStream(stream.distinct(equals));

  Observable<T> handleError(Function onError, { bool test(error) }) => new StreamObservable<T>()..setStream(stream.handleError(onError, test: test));

  Observable<T> skip(int count) => new StreamObservable<T>()..setStream(stream.skip(count));

  Observable<T> skipWhile(bool test(T element)) => new StreamObservable<T>()..setStream(stream.skipWhile(test));

  Observable<T> take(int count) => new StreamObservable<T>()..setStream(stream.take(count));

  Observable<T> takeWhile(bool test(T element)) => new StreamObservable<T>()..setStream(stream.takeWhile(test));

  Observable<T> timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) => new StreamObservable<T>()..setStream(stream.timeout(timeLimit, onTimeout: onTimeout));

  Observable<T> retry([int count]) => new RetryObservable<T>(stream as Stream<T>, count);

  Observable<T> debounce(Duration duration) => new DebounceObservable<T>(stream as Stream<T>, duration);

  Observable<T> throttle(Duration duration) => new ThrottleObservable<T>(stream as Stream<T>, duration);

  Observable<List<T>> bufferWithCount(int count, [int skip]) => new BufferWithCountObservable<T, List<T>>(stream as Stream<T>, count, skip) as Observable<List<T>>;

  Observable<Observable<T>> windowWithCount(int count, [int skip]) => new WindowWithCountObservable<T, StreamObservable<T>>(stream as Stream<T>, count, skip) as Observable<Stream<T>>;

  Observable flatMap(Stream predicate(T value)) => new FlatMapObservable(stream as Stream<T>, predicate);

  Observable flatMapLatest(Stream predicate(T value)) => new FlatMapLatestObservable(stream as Stream<T>, predicate);

  Observable<T> takeUntil(Stream<dynamic> otherStream) => new TakeUntilObservable<T, dynamic>(stream as Stream<T>, otherStream);

  Observable scan(dynamic predicate(dynamic accumulated, T value, int index), [dynamic seed]) => new ScanObservable(stream as Stream<T>, predicate, seed);

  Observable<T> tap(void action(T value)) => new TapObservable<T>(stream as Stream<T>, action);

  Observable<T> startWith(List<T> startValues) => new StartWithObservable<T>(stream as Stream<T>, startValues);

  Observable<T> repeat(int repeatCount) => new RepeatObservable<T>(stream as Stream<T>, repeatCount);

  Observable<T> replay([int bufferSize = 0]) => new ReplayObservable<T>(stream as Stream<T>, bufferSize);

  Observable<T> min([int compare(T a, T b)]) => new MinObservable<T>(stream, compare);

  Observable<T> max([int compare(T a, T b)]) => new MaxObservable<T>(stream, compare);

  Observable<T> interval(Duration duration) => new IntervalObservable<T>(stream, duration);

  Observable<T> sample(Stream sampleStream) => new SampleObservable<T>(stream, sampleStream);

  Observable<TimeInterval<T>> timeInterval() => new TimeIntervalObservable<T, TimeInterval<T>>(stream) as Observable<TimeInterval<T>>;
}

abstract class ControllerMixin<T> {

  StreamController<T> controller;

  void throwError(e, s) => controller.addError(e, s);

}