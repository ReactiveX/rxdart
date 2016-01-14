library rx.observable;

import 'dart:async';

import 'package:rxdart/src/observable/stream.dart' show StreamObservable;
import 'package:rxdart/src/observable/combine_latest.dart' show CombineLatestObservable;
import 'package:rxdart/src/observable/combine_latest_map.dart' show CombineLatestObservableMap;
import 'package:rxdart/src/observable/merge.dart' show MergeObservable;
import 'package:rxdart/src/observable/zip.dart' show ZipObservable;
import 'package:rxdart/src/observable/tween.dart' show TweenObservable, Ease;

import 'package:rxdart/src/operators/time_interval.dart' show TimeInterval;

export 'package:rxdart/src/observable/tween.dart' show Ease;

export 'package:rxdart/src/operators/time_interval.dart' show TimeInterval;

Observable observable(Stream stream) => new StreamObservable()..setStream(stream);

abstract class Observable<T> extends Stream {

  Observable();

  factory Observable.fromStream(Stream stream) => observable(stream) as Observable<T>;

  factory Observable.fromFuture(Future<T> future) => observable((new Stream<T>.fromFuture(future))) as Observable<T>;

  factory Observable.fromIterable(Iterable<T> data) => observable((new Stream<T>.fromIterable(data))) as Observable<T>;

  factory Observable.periodic(Duration period, [T computation(int computationCount)]) => observable((new Stream<T>.periodic(period, computation))) as Observable<T>;

  factory Observable.eventTransformed(Stream source, EventSink mapSink(EventSink<T> sink)) => observable((new Stream<T>.eventTransformed(source, mapSink))) as Observable<T>;

  factory Observable.combineLatest(Iterable<Stream> streams, Function predicate, {asBroadcastStream: false}) => new CombineLatestObservable(streams, predicate, asBroadcastStream);

  factory Observable.combineLatestMap(Map<String, Stream> streamMap, {asBroadcastStream: false}) => new CombineLatestObservableMap(streamMap, asBroadcastStream);

  factory Observable.merge(Iterable<Stream<T>> streams, {asBroadcastStream: false}) => new MergeObservable(streams, asBroadcastStream);

  factory Observable.zip(Iterable<Stream> streams, Function predicate, {asBroadcastStream: false}) => new ZipObservable(streams, predicate, asBroadcastStream);

  factory Observable.tween(double startValue, double changeInTime, Duration duration, {int intervalMs: 20, Ease ease: Ease.LINEAR, asBroadcastStream: false}) => new TweenObservable(startValue, changeInTime, duration, intervalMs, ease, asBroadcastStream) as Observable<T>;

  Observable asBroadcastStream({
    void onListen(StreamSubscription<T> subscription),
    void onCancel(StreamSubscription<T> subscription) });

  Observable map(dynamic convert(T value));

  Observable asyncMap(dynamic convert(T value));

  Observable expand(Iterable convert(T value));

  Observable asyncExpand(Stream convert(T value));

  Observable<T> distinct([bool equals(T previous, T next)]);

  Observable<T> where(bool test(T event));

  Observable<T> handleError(Function onError, { bool test(error) });

  Observable<T> skip(int count);

  Observable<T> skipWhile(bool test(T element));

  Observable<T> take(int count);

  Observable<T> takeWhile(bool test(T element));

  Observable<T> timeout(Duration timeLimit, {void onTimeout(EventSink sink)});

  Observable<T> retry([int count]);

  Observable<T> debounce(Duration duration);

  Observable<T> throttle(Duration duration);

  Observable<List<T>> bufferWithCount(int count, [int skip]);

  Observable<Observable<T>> windowWithCount(int count, [int skip]);

  Observable flatMap(Stream predicate(T value));

  Observable flatMapLatest(Stream predicate(T value));

  Observable takeUntil(Stream otherStream);

  Observable scan(dynamic predicate(dynamic accumulated, T value, int index), [dynamic seed]);

  Observable<T> tap(void action(T value));

  Observable<T> startWith(List<T> startValues);

  Observable<T> repeat(int repeatCount);

  Observable<T> replay([int bufferSize = 0]);

  Observable<T> min([int compare(T a, T b)]);

  Observable<T> max([int compare(T a, T b)]);

  Observable<T> interval(Duration duration);

  Observable<T> sample(Stream sampleStream);

  Observable<TimeInterval<T>> timeInterval();

}