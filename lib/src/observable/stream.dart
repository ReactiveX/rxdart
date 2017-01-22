import 'dart:async';

import 'package:rxdart/src/observable.dart' show Observable;
import 'package:rxdart/src/operators/debounce.dart' show DebounceObservable;
import 'package:rxdart/src/operators/defaultIfEmpty.dart'
    show DefaultIfEmptyObservable;
import 'package:rxdart/src/operators/retry.dart' show RetryObservable;
import 'package:rxdart/src/operators/throttle.dart' show ThrottleObservable;
import 'package:rxdart/src/operators/buffer_with_count.dart'
    show BufferWithCountObservable;
import 'package:rxdart/src/operators/window_with_count.dart'
    show WindowWithCountObservable;
import 'package:rxdart/src/operators/flat_map.dart' show FlatMapObservable;
import 'package:rxdart/src/operators/flat_map_latest.dart'
    show FlatMapLatestObservable;
import 'package:rxdart/src/operators/take_until.dart' show TakeUntilObservable;
import 'package:rxdart/src/operators/scan.dart' show ScanObservable;
import 'package:rxdart/src/operators/tap.dart' show TapObservable;
import 'package:rxdart/src/operators/start_with.dart' show StartWithObservable;
import 'package:rxdart/src/operators/start_with_many.dart'
    show StartWithManyObservable;
import 'package:rxdart/src/operators/repeat.dart' show RepeatObservable;
import 'package:rxdart/src/operators/min.dart' show MinObservable;
import 'package:rxdart/src/operators/max.dart' show MaxObservable;
import 'package:rxdart/src/operators/of_type.dart'
    show OfTypeObservable, TypeToken;
import 'package:rxdart/src/operators/interval.dart' show IntervalObservable;
import 'package:rxdart/src/operators/sample.dart' show SampleObservable;
import 'package:rxdart/src/operators/time_interval.dart'
    show TimeIntervalObservable, TimeInterval;
import 'package:rxdart/src/operators/pluck.dart' show PluckObservable;
import 'package:rxdart/src/operators/group_by.dart'
    show GroupByObservable, GroupByMap;
import 'package:rxdart/src/operators/with_latest_from.dart'
    show WithLatestFromObservable;

export 'dart:async';

class StreamObservable<T> implements Observable<T> {
  Stream<T> stream;

  @override
  bool get isBroadcast {
    return (stream != null) ? stream.isBroadcast : false;
  }

  StreamObservable();

  void setStream(Stream<T> stream) {
    this.stream = stream;
  }

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  Observable<T> asBroadcastStream(
          {void onListen(StreamSubscription<T> subscription),
          void onCancel(StreamSubscription<T> subscription)}) =>
      new StreamObservable<T>()
        ..setStream(
            stream.asBroadcastStream(onListen: onListen, onCancel: onCancel));

  @override
  Observable<GroupByMap<S, T>> groupBy<S>(S keySelector(T value),
          {int compareKeys(S keyA, S keyB): null}) =>
      new GroupByObservable<T, S>(stream, keySelector,
          compareKeys: compareKeys);

  @override
  Observable<S> map<S>(S convert(T event)) => new StreamObservable<S>()
    ..setStream(stream.map(convert));

  @override
  Observable<S> asyncMap<S>(dynamic convert(T value)) =>
      new StreamObservable<S>()..setStream(stream.asyncMap(convert));

  @override
  Observable<T> where(bool test(T event)) =>
      new StreamObservable<T>()..setStream(stream.where(test));

  @override
  Observable<S> expand<S>(Iterable<S> convert(T value)) =>
      new StreamObservable<S>()..setStream(stream.expand(convert));

  @override
  Observable<S> asyncExpand<S>(Stream<S> convert(T value)) =>
      new StreamObservable<S>()..setStream(stream.asyncExpand(convert));

  @override
  Observable<T> distinct([bool equals(T previous, T next)]) =>
      new StreamObservable<T>()..setStream(stream.distinct(equals));

  @override
  Observable<T> handleError(Function onError, {bool test(dynamic error)}) =>
      new StreamObservable<T>()
        ..setStream(stream.handleError(onError, test: test));

  @override
  Observable<T> skip(int count) =>
      new StreamObservable<T>()..setStream(stream.skip(count));

  @override
  Observable<T> skipWhile(bool test(T element)) =>
      new StreamObservable<T>()..setStream(stream.skipWhile(test));

  @override
  Observable<T> take(int count) =>
      new StreamObservable<T>()..setStream(stream.take(count));

  @override
  Observable<T> takeWhile(bool test(T element)) =>
      new StreamObservable<T>()..setStream(stream.takeWhile(test));

  @override
  Observable<T> timeout(Duration timeLimit,
          {void onTimeout(EventSink<T> sink)}) =>
      new StreamObservable<T>()
        ..setStream(stream.timeout(timeLimit, onTimeout: onTimeout));

  @override
  Observable<T> retry([int count]) => new RetryObservable<T>(stream, count);

  @override
  Observable<T> debounce(Duration duration) =>
      new DebounceObservable<T>(stream, duration);

  @override
  Observable<T> defaultIfEmpty(T defaultValue) =>
      new DefaultIfEmptyObservable<T>(stream, defaultValue);

  @override
  Observable<T> throttle(Duration duration) =>
      new ThrottleObservable<T>(stream, duration);

  @override
  Observable<List<T>> bufferWithCount(int count, [int skip]) =>
      new BufferWithCountObservable<T, List<T>>(stream, count, skip);

  @override
  Observable<Observable<T>> windowWithCount(int count, [int skip]) =>
      new WindowWithCountObservable<T, StreamObservable<T>>(
          stream, count, skip);

  @override
  Observable<S> flatMap<S>(Stream<S> predicate(T value)) =>
      new FlatMapObservable<T, S>(stream, predicate);

  @override
  Observable<S> flatMapLatest<S>(Stream<S> predicate(T value)) =>
      new FlatMapLatestObservable<T, S>(stream, predicate);

  @override
  Observable<T> takeUntil(Stream<dynamic> otherStream) =>
      new TakeUntilObservable<T, dynamic>(stream, otherStream);

  @override
  Observable<S> scan<S>(S predicate(S accumulated, T value, int index),
          [S seed]) =>
      new ScanObservable<T, S>(stream, predicate, seed);

  @override
  Observable<T> tap(void action(T value)) =>
      new TapObservable<T>(stream, action);

  @override
  Observable<T> startWith(T startValue) =>
      new StartWithObservable<T>(stream, startValue);

  @override
  Observable<T> startWithMany(List<T> startValues) =>
      new StartWithManyObservable<T>(stream, startValues);

  @override
  Observable<T> repeat(int repeatCount) =>
      new RepeatObservable<T>(stream, repeatCount);

  @override
  Observable<T> min([int compare(T a, T b)]) =>
      new MinObservable<T>(stream, compare);

  @override
  Observable<T> max([int compare(T a, T b)]) =>
      new MaxObservable<T>(stream, compare);

  @override
  Observable<S> ofType<S>(TypeToken<S> typeToken) {
    return new OfTypeObservable<T, S>(stream, typeToken);
  }

  @override
  Observable<T> interval(Duration duration) =>
      new IntervalObservable<T>(stream, duration);

  @override
  Observable<T> sample(Stream<dynamic> sampleStream) =>
      new SampleObservable<T>(stream, sampleStream);

  @override
  Observable<R> withLatestFrom<S, R>(
          Stream<S> latestFromStream, R fn(T t, S s)) =>
      new WithLatestFromObservable<T, S, R>(stream, latestFromStream, fn);

  @override
  Observable<TimeInterval<T>> timeInterval() =>
      new TimeIntervalObservable<T, TimeInterval<T>>(stream);

  @override
  Observable<dynamic> pluck(List<dynamic> sequence,
          {bool throwOnNull: false}) =>
      new PluckObservable<T, dynamic>(stream, sequence,
          throwOnNull: throwOnNull);

  @override
  Future<bool> any(bool test(T element)) => stream.any(test);

  @override
  Future<bool> contains(Object needle) => stream.contains(needle);

  @override
  Future<S> drain<S>([S futureValue]) => stream.drain(futureValue);

  @override
  Future<T> elementAt(int index) => stream.elementAt(index);

  @override
  Future<bool> every(bool test(T element)) => stream.every(test);

  @override
  Future<dynamic> firstWhere(bool test(T element), {Object defaultValue()}) =>
      stream.firstWhere(test, defaultValue: defaultValue);

  @override
  Future<dynamic> forEach(void action(T element)) => stream.forEach(action);

  @override
  Future<String> join([String separator = ""]) => stream.join(separator);

  @override
  Future<dynamic> lastWhere(bool test(T element), {Object defaultValue()}) =>
      stream.lastWhere(test, defaultValue: defaultValue);

  @override
  Future<dynamic> pipe(StreamConsumer<T> streamConsumer) =>
      stream.pipe(streamConsumer);

  @override
  Future<S> fold<S>(S initialValue, S combine(S previous, T element)) => stream
      .fold(initialValue, combine);

  @override
  Future<T> reduce(T combine(T previous, T element)) => stream.reduce(combine);

  @override
  Future<T> singleWhere(bool test(T element)) => stream.singleWhere(test);

  @override
  Future<List<T>> toList() => stream.toList();

  @override
  Future<Set<T>> toSet() => stream.toSet();

  @override
  Stream<S> transform<S>(StreamTransformer<T, S> streamTransformer) => stream
      .transform(streamTransformer);

  @override
  Future<T> get first => stream.first;

  @override
  Future<T> get last => stream.last;

  @override
  Future<T> get single => stream.single;

  @override
  Future<bool> get isEmpty => stream.isEmpty;

  @override
  Future<int> get length => stream.length;
}

abstract class ControllerMixin<T> {}
