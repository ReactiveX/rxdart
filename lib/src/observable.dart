library rx.observable;

import 'dart:async';

import 'package:rxdart/src/observable/stream.dart' show StreamObservable;
import 'package:rxdart/src/observable/combine_latest.dart' show CombineLatestObservable;
import 'package:rxdart/src/observable/combine_latest_map.dart' show CombineLatestObservableMap;
import 'package:rxdart/src/observable/merge.dart' show MergeObservable;

Observable observable(Stream stream) => new StreamObservable()..setStream(stream);

abstract class Observable<T> extends Stream {

  Observable();

  factory Observable.fromStream(Stream stream) => observable(stream) as Observable<T>;

  factory Observable.fromFuture(Future<T> future) => observable((new Stream.fromFuture(future)));

  factory Observable.fromIterable(Iterable<T> data) => observable((new Stream.fromIterable(data)));

  factory Observable.periodic(Duration period, [T computation(int computationCount)]) => observable((new Stream.periodic(period, computation)));

  factory Observable.eventTransformed(Stream source, EventSink mapSink(EventSink<T> sink)) => observable((new Stream.eventTransformed(source, mapSink)));

  factory Observable.combineLatest(Iterable<Stream> streams, Function predicate, {asBroadcastStream: false}) => new CombineLatestObservable(streams, predicate, asBroadcastStream);

  factory Observable.combineLatestMap(Map<String, Stream> streamMap, {asBroadcastStream: false}) => new CombineLatestObservableMap(streamMap, asBroadcastStream);

  factory Observable.merge(Iterable<Stream<T>> streams, {asBroadcastStream: false}) => new MergeObservable(streams, asBroadcastStream);

  Observable map(dynamic convert(T value));

  Observable<T> where(bool test(T event));

  Observable<T> retry([int count]);

  Observable<T> debounce(Duration duration);

  Observable<T> throttle(Duration duration);

  Observable<List<T>> bufferWithCount(int count, [int skip]);

  Observable<Stream<T>> windowWithCount(int count, [int skip]);

  Observable flatMap(Stream predicate(T value));

  Observable flatMapLatest(Stream predicate(T value));

  Observable takeUntil(Stream otherStream);

  Observable scan(dynamic predicate(dynamic accumulated, T value, int index), [dynamic seed]);

  Observable<T> tap(void action(T value));

  Observable<T> startWith(List<T> startValues);

  Observable<T> repeat(int repeatCount);

  Observable<T> replay([int bufferSize = 0]);

}