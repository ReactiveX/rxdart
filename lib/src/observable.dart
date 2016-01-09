library rx.observable;

import 'dart:async';

import 'package:rxdart/src/observable/stream.dart' show StreamObservable;
import 'package:rxdart/src/observable/combine_latest.dart' show CombineLatestObservable;
import 'package:rxdart/src/observable/combine_latest_map.dart' show CombineLatestObservableMap;
import 'package:rxdart/src/observable/merge.dart' show MergeObservable;

Observable observable(Stream stream) => new StreamObservable()..setStream(stream);

abstract class Observable<T> extends Stream {

  Observable();

  factory Observable.fromStream(Stream stream) => observable(stream);

  factory Observable.combineLatest(Iterable<Stream> streams, Function predicate, {asBroadcastStream: false}) => new CombineLatestObservable(streams, predicate, asBroadcastStream);

  factory Observable.combineLatestMap(Map<String, Stream> streamMap, {asBroadcastStream: false}) => new CombineLatestObservableMap(streamMap, asBroadcastStream);

  factory Observable.merge(Iterable<Stream<T>> streams, {asBroadcastStream: false}) => new MergeObservable(streams, asBroadcastStream);

  Observable map(dynamic convert(T value));

  Observable<T> retry([int count]);

  Observable<T> debounce(Duration duration);

  Observable<T> throttle(Duration duration);

}