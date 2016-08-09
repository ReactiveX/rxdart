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

Observable/*<S>*/ observable/*<S>*/(Stream<dynamic/*=S*/> stream) => new StreamObservable()..setStream(stream);

abstract class Observable<T> extends Stream<T> {

  Observable();

  factory Observable.fromStream(Stream stream) => observable(stream) as Observable<T>;

  factory Observable.fromFuture(Future<T> future) => observable((new Stream<T>.fromFuture(future)));

  factory Observable.fromIterable(Iterable<T> data) => observable((new Stream<T>.fromIterable(data)));

  factory Observable.periodic(Duration period, [T computation(int computationCount)]) => observable((new Stream<T>.periodic(period, computation)));

  factory Observable.eventTransformed(Stream source, EventSink mapSink(EventSink<T> sink)) => observable((new Stream<T>.eventTransformed(source, mapSink)));

  factory Observable/*<S>*/.combineLatest/*<S>*/(Iterable<Stream> streams, Function predicate, {asBroadcastStream: false}) => new CombineLatestObservable(streams, /*=S*/ predicate, asBroadcastStream);

  factory Observable.combineLatestMap(Map<String, Stream<T>> streamMap, {asBroadcastStream: false}) => new CombineLatestObservableMap(streamMap, asBroadcastStream);

  factory Observable.merge(Iterable<Stream<T>> streams, {asBroadcastStream: false}) => new MergeObservable(streams, asBroadcastStream);

  factory Observable/*<S>*/.zip/*<S>*/(Iterable<Stream> streams, Function predicate, {asBroadcastStream: false}) => new ZipObservable(streams, /*=S*/ predicate, asBroadcastStream);

  factory Observable.tween(double startValue, double changeInTime, Duration duration, {int intervalMs: 20, Ease ease: Ease.LINEAR, asBroadcastStream: false}) => new TweenObservable<T>(startValue as T, changeInTime as T, duration, intervalMs, ease, asBroadcastStream);

  Observable<T> asBroadcastStream({
    void onListen(StreamSubscription<T> subscription),
    void onCancel(StreamSubscription<T> subscription) });

  Observable/*<S>*/ map/*<S>*/(/*=S*/ convert(T event));

  Observable/*<S>*/ asyncMap/*<S>*/(dynamic convert(T value));

  Observable/*<S>*/ expand/*<S>*/(Iterable/*<S>*/ convert(T value));

  Observable/*<S>*/ asyncExpand/*<S>*/(Stream/*<S>*/ convert(T value));

  Observable<T> distinct([bool equals(T previous, T next)]);

  Observable<T> where(bool test(T event));

  Observable<T> handleError(Function onError, { bool test(error) });

  Observable<T> skip(int count);

  Observable<T> skipWhile(bool test(T element));

  Observable<T> take(int count);

  Observable<T> takeWhile(bool test(T element));

  Observable<T> timeout(Duration timeLimit, {void onTimeout(EventSink<T> sink)});

  Observable<T> retry([int count]);

  Observable<T> debounce(Duration duration);

  Observable<T> throttle(Duration duration);

  Observable<List<T>> bufferWithCount(int count, [int skip]);

  Observable<Observable<T>> windowWithCount(int count, [int skip]);

  Observable/*<S>*/ flatMap/*<S>*/(Stream/*<S>*/ predicate(T value));

  Observable/*<S>*/ flatMapLatest/*<S>*/(Stream/*<S>*/ predicate(T value));

  Observable<T> takeUntil(Stream otherStream);

  Observable/*<S>*/ scan/*<S>*/(dynamic/*<S>*/ predicate(/*<=S>*/dynamic accumulated, T value, int index), [dynamic/*<S>*/ seed]);

  Observable<T> tap(void action(T value));

  Observable<T> startWith(List<T> startValues);

  Observable<T> repeat(int repeatCount);

  Observable<T> replay({int bufferSize: 0, bool completeWhenBufferExhausted: false});

  Observable<T> min([int compare(T a, T b)]);

  Observable<T> max([int compare(T a, T b)]);

  Observable<T> interval(Duration duration);

  Observable<T> sample(Stream sampleStream);

  Observable<TimeInterval<T>> timeInterval();

  Observable pluck(List<dynamic> sequence, {bool throwOnNull: false});

  Observable<T> reverse();

}