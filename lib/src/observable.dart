library rx.observable;

import 'dart:async';

import 'package:rxdart/src/observable/stream.dart' show StreamObservable;
import 'package:rxdart/src/observable/combine_latest.dart' show CombineLatestObservable;
import 'package:rxdart/src/observable/merge.dart' show MergeObservable;
import 'package:rxdart/src/observable/zip.dart' show ZipObservable;
import 'package:rxdart/src/observable/tween.dart' show TweenObservable, Ease;

import 'package:rxdart/src/operators/time_interval.dart' show TimeInterval;

export 'package:rxdart/src/observable/tween.dart' show Ease;

export 'package:rxdart/src/operators/time_interval.dart' show TimeInterval;

Observable<S> observable<S>(Stream<S> stream) => new StreamObservable<S>()..setStream(stream);

abstract class Observable<T> extends Stream<T> {

  Observable();

  factory Observable.fromStream(Stream<T> stream) => observable(stream);

  factory Observable.fromFuture(Future<T> future) => observable((new Stream<T>.fromFuture(future)));

  factory Observable.fromIterable(Iterable<T> data) => observable((new Stream<T>.fromIterable(data)));

  factory Observable.periodic(Duration period, [T computation(int computationCount)]) => observable((new Stream<T>.periodic(period, computation)));

  factory Observable.eventTransformed(Stream<T> source, EventSink<T> mapSink(EventSink<T> sink)) => observable((new Stream<T>.eventTransformed(source, mapSink)));

  factory Observable.combineLatest(Iterable<Stream<dynamic>> streams, Function predicate, {bool asBroadcastStream: false}) => new CombineLatestObservable<T>(streams, predicate, asBroadcastStream);

  factory Observable.merge(Iterable<Stream<T>> streams, {bool asBroadcastStream: false}) => new MergeObservable<T>(streams, asBroadcastStream);

  factory Observable.zip(Iterable<Stream<dynamic>> streams, Function predicate, {bool asBroadcastStream: false}) => new ZipObservable<T>(streams, predicate, asBroadcastStream);

  factory Observable.tween(double startValue, double changeInTime, Duration duration, {int intervalMs: 20, Ease ease: Ease.LINEAR, bool asBroadcastStream: false}) => new TweenObservable<T>(startValue, changeInTime, duration, intervalMs, ease, asBroadcastStream);

  @override Observable<T> asBroadcastStream({
    void onListen(StreamSubscription<T> subscription),
    void onCancel(StreamSubscription<T> subscription) });

  @override Observable<S> map<S>(S convert(T event));

  @override Observable<S> asyncMap<S>(dynamic convert(T value));

  @override Observable<S> expand<S>(Iterable<S> convert(T value));

  @override Observable<S> asyncExpand<S>(Stream<S> convert(T value));

  @override Observable<T> distinct([bool equals(T previous, T next)]);

  @override Observable<T> where(bool test(T event));

  @override Observable<T> handleError(Function onError, { bool test(dynamic error) });

  @override Observable<T> skip(int count);

  @override Observable<T> skipWhile(bool test(T element));

  @override Observable<T> take(int count);

  @override Observable<T> takeWhile(bool test(T element));

  @override Observable<T> timeout(Duration timeLimit, {void onTimeout(EventSink<T> sink)});

  Observable<T> retry([int count]);

  Observable<T> debounce(Duration duration);

  Observable<T> throttle(Duration duration);

  Observable<List<T>> bufferWithCount(int count, [int skip]);

  Observable<Observable<T>> windowWithCount(int count, [int skip]);

  Observable<S> flatMap<S>(Stream<S> predicate(T value));

  Observable<S> flatMapLatest<S>(Stream<S> predicate(T value));

  Observable<T> takeUntil(Stream<dynamic> otherStream);

  Observable<S> scan<S>(S predicate(S accumulated, T value, int index), [S seed]);

  Observable<T> tap(void action(T value));

  Observable<T> startWith(List<T> startValues);

  Observable<T> repeat(int repeatCount);

  Observable<T> min([int compare(T a, T b)]);

  Observable<T> max([int compare(T a, T b)]);

  Observable<T> interval(Duration duration);

  Observable<T> sample(Stream<dynamic> sampleStream);

  Observable<TimeInterval<T>> timeInterval();

  Observable<dynamic> pluck(List<dynamic> sequence, {bool throwOnNull: false});

}