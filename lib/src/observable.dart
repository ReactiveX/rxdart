import 'dart:async';

import 'package:rxdart/src/observable/amb.dart' show AmbObservable;
import 'package:rxdart/src/observable/combine_latest.dart'
    show CombineLatestObservable;
import 'package:rxdart/src/observable/concat.dart' show ConcatObservable;
import 'package:rxdart/src/observable/concat_eager.dart'
    show ConcatEagerObservable;
import 'package:rxdart/src/observable/defer.dart' show DeferObservable;
import 'package:rxdart/src/observable/merge.dart' show MergeObservable;
import 'package:rxdart/src/observable/stream.dart' show StreamObservable;
import 'package:rxdart/src/observable/tween.dart' show TweenObservable, Ease;
import 'package:rxdart/src/observable/zip.dart' show ZipObservable;
import 'package:rxdart/src/operators/of_type.dart' show TypeToken;
import 'package:rxdart/src/operators/time_interval.dart' show TimeInterval;
import 'package:rxdart/src/operators/group_by.dart' show GroupByMap;

export 'package:rxdart/src/observable/tween.dart' show Ease;
export 'package:rxdart/src/operators/time_interval.dart' show TimeInterval;
export 'package:rxdart/src/operators/group_by.dart' show GroupByMap;

Observable<S> observable<S>(Stream<S> stream) => new StreamObservable<S>()
  ..setStream(stream);

abstract class Observable<T> extends Stream<T> {
  Observable();

  /// Given two or more source Observables, emit all of the items from only
  /// the first of these Observables to emit an item or notification.
  ///
  /// http://rxmarbles.com/#amb
  factory Observable.amb(Iterable<Stream<T>> streams,
          {bool asBroadcastStream: false}) =>
      new AmbObservable<T>(streams, asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  @Deprecated(
      'For better strong mode support, use combineTwoLatest, combineThreeLatest, ... instead')
  factory Observable.combineLatest(
          Iterable<Stream<dynamic>> streams, Function predicate,
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(streams, predicate, asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineTwoLatest<A, B, T>(
          Stream<A> streamOne, Stream<B> streamTwo, T predicate(A a, B b),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(<Stream<dynamic>>[streamOne, streamTwo],
          predicate, asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineThreeLatest<A, B, C, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          T predicate(A a, B b, C c),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree],
          predicate,
          asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineFourLatest<A, B, C, D, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          T predicate(A a, B b, C c, D d),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
          predicate,
          asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineFiveLatest<A, B, C, D, E, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          T predicate(A a, B b, C c, D d, E e),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive
      ], predicate, asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineSixLatest<A, B, C, D, E, F, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix
      ], predicate, asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineSevenLatest<A, B, C, D, E, F, G, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven
      ], predicate, asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineEightLatest<A, B, C, D, E, F, G, H, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight
      ], predicate, asBroadcastStream);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineNineLatest<A, B, C, D, E, F, G, H, I, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          Stream<I> streamNine,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new CombineLatestObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight,
        streamNine
      ], predicate, asBroadcastStream);

  /// Concatenates all of the specified observable sequences, as long as the
  /// previous observable sequence terminated successfully..
  ///
  /// http://rxmarbles.com/#concat
  factory Observable.concat(Iterable<Stream<T>> streams,
          {bool asBroadcastStream: false}) =>
      new ConcatObservable<T>(streams, asBroadcastStream);

  /// Concatenates all of the specified observable sequences,
  /// a backlog is being kept for events that emit on the waiting streams.
  /// When a previous sequence is terminated, all backlog for the next stream
  /// is eagerly emitted at once.
  ///
  factory Observable.concatEager(Iterable<Stream<T>> streams,
          {bool asBroadcastStream: false}) =>
      new ConcatEagerObservable<T>(streams, asBroadcastStream);

  /// The defer factory waits until an observer subscribes to it, and then it
  /// generates an Observable with the given function.
  ///
  /// It does this afresh for each subscriber, so although each subscriber may
  /// think it is subscribing to the same Observable, in fact each subscriber
  /// gets its own individual sequence.
  ///
  /// In some circumstances, waiting until the last minute (that is, until
  /// subscription time) to generate the Observable can ensure that this
  /// Observable contains the freshest data.
  factory Observable.defer(Stream<T> create()) =>
      new DeferObservable<T>(create);

  ///  Creates an Observable where all events of an existing stream are piped
  ///  through a sink-transformation.
  ///
  ///  The given [mapSink] closure is invoked when the returned stream is
  ///  listened to. All events from the [source] are added into the event sink
  ///  that is returned from the invocation. The transformation puts all
  ///  transformed events into the sink the [mapSink] closure received during
  ///  its invocation. Conceptually the [mapSink] creates a transformation pipe
  ///  with the input sink being the returned [EventSink] and the output sink
  ///  being the sink it received.
  factory Observable.eventTransformed(
          Stream<T> source, EventSink<T> mapSink(EventSink<T> sink)) =>
      observable((new Stream<T>.eventTransformed(source, mapSink)));

  /// Creates an Observable from the future.
  ///
  /// When the future completes, the stream will fire one event, either
  /// data or error, and then close with a done-event.
  factory Observable.fromFuture(Future<T> future) =>
      observable((new Stream<T>.fromFuture(future)));

  /// Creates an Observable that gets its data from [data].
  ///
  /// The iterable is iterated when the stream receives a listener, and stops
  /// iterating if the listener cancels the subscription.
  ///
  /// If iterating [data] throws an error, the stream ends immediately with
  /// that error. No done event will be sent (iteration is not complete), but no
  /// further data events will be generated either, since iteration cannot
  /// continue.
  factory Observable.fromIterable(Iterable<T> data) =>
      observable((new Stream<T>.fromIterable(data)));

  /// Creates an Observable that contains a single value
  ///
  /// The value is emitted when the stream receives a listener.
  factory Observable.just(T data) =>
      observable((new Stream<T>.fromIterable(<T>[data])));

  /// Creates an Observable that gets its data from [stream].
  ///
  /// If stream throws an error, the Observable ends immediately with
  /// that error. When stream is closed, the Observable will also be closed.
  factory Observable.fromStream(Stream<T> stream) => observable(stream);

  /// Creates an Observable where each item is the interleaved output emitted by
  /// the feeder streams.
  ///
  /// http://rxmarbles.com/#merge
  factory Observable.merge(Iterable<Stream<T>> streams,
          {bool asBroadcastStream: false}) =>
      new MergeObservable<T>(streams, asBroadcastStream);

  /// Creates an Observable that repeatedly emits events at [period] intervals.
  ///
  /// The event values are computed by invoking [computation]. The argument to
  /// this callback is an integer that starts with 0 and is incremented for
  /// every event.
  ///
  /// If [computation] is omitted the event values will all be `null`.
  factory Observable.periodic(Duration period,
          [T computation(int computationCount)]) =>
      observable((new Stream<T>.periodic(period, computation)));

  /// Creates an Observable that emits values starting from startValue and
  /// incrementing according to the ease type over the duration.
  /// todo : needs more detail
  factory Observable.tween(
          double startValue, double changeInTime, Duration duration,
          {int intervalMs: 20,
          Ease ease: Ease.LINEAR,
          bool asBroadcastStream: false}) =>
      new TweenObservable<T>(startValue, changeInTime, duration, intervalMs,
          ease, asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  @Deprecated(
      'For better strong mode support, use zipTwo, zipThree, ... instead')
  factory Observable.zip(Iterable<Stream<dynamic>> streams, Function predicate,
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(streams, predicate, asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipTwo<A, B, T>(
          Stream<A> streamOne, Stream<B> streamTwo, T predicate(A a, B b),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(<Stream<dynamic>>[streamOne, streamTwo], predicate,
          asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipThree<A, B, C, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          T predicate(A a, B b, C c),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(<Stream<dynamic>>[streamOne, streamTwo, streamThree],
          predicate, asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipFour<A, B, C, D, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          T predicate(A a, B b, C c, D d),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
          predicate,
          asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipFive<A, B, C, D, E, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          T predicate(A a, B b, C c, D d, E e),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive
      ], predicate, asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipSix<A, B, C, D, E, F, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix
      ], predicate, asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipSeven<A, B, C, D, E, F, G, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven
      ], predicate, asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipEight<A, B, C, D, E, F, G, H, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight
      ], predicate, asBroadcastStream);

  /// Creates an Observable that applies a function of your choosing to the
  /// combination of items emitted, in sequence, by two (or more) other
  /// Observables, with the results of this function becoming the items emitted
  /// by the returned Observable. It applies this function in strict sequence,
  /// so the first item emitted by the new Observable will be the result of the
  /// function applied to the first item emitted by Observable #1 and the first
  /// item emitted by Observable #2; the second item emitted by the new
  /// zip-Observable will be the result of the function applied to the second
  /// item emitted by Observable #1 and the second item emitted by Observable
  /// #2; and so forth. It will only emit as many items as the number of items
  /// emitted by the source Observable that emits the fewest items.
  ///
  /// http://rxmarbles.com/#zip
  static Observable<T> zipNine<A, B, C, D, E, F, G, H, I, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          Stream<I> streamNine,
          T predicate(A a, B b, C c, D d, E e, F f),
          {bool asBroadcastStream: false}) =>
      new ZipObservable<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight,
        streamNine
      ], predicate, asBroadcastStream);

  /// Returns a multi-subscription stream that produces the same events as this.
  ///
  /// The returned stream will subscribe to this stream when its first
  /// subscriber is added, and will stay subscribed until this stream ends, or a
  /// callback cancels the subscription.
  ///
  /// If onListen is provided, it is called with a subscription-like object that
  /// represents the underlying subscription to this stream. It is possible to
  /// pause, resume or cancel the subscription during the call to onListen. It
  /// is not possible to change the event handlers, including using
  /// StreamSubscription.asFuture.
  ///
  /// If onCancel is provided, it is called in a similar way to onListen when
  /// the returned stream stops having listener. If it later gets a new
  /// listener, the onListen function is called again.
  ///
  /// Use the callbacks, for example, for pausing the underlying subscription
  /// while having no subscribers to prevent losing events, or canceling the
  /// subscription when there are no listeners.
  @override
  Observable<T> asBroadcastStream(
      {void onListen(StreamSubscription<T> subscription),
      void onCancel(StreamSubscription<T> subscription)});

  /// Creates an Observable with the events of a stream per original event.
  ///
  /// This acts like expand, except that convert returns a Stream instead of an
  /// Iterable. The events of the returned stream becomes the events of the
  /// returned stream, in the order they are produced.
  ///
  /// If convert returns null, no value is put on the output stream, just as if
  /// it returned an empty stream.
  ///
  /// The returned stream is a broadcast stream if this stream is.
  @override
  Observable<S> asyncExpand<S>(Stream<S> convert(T value));

  /// Creates an Observable with each data event of this stream asynchronously
  /// mapped to a new event.
  ///
  /// This acts like map, except that convert may return a Future, and in that
  /// case, the stream waits for that future to complete before continuing with
  /// its result.
  ///
  /// The returned stream is a broadcast stream if this stream is.
  @override
  Observable<S> asyncMap<S>(dynamic convert(T value));

  /// Creates an Observable where each item is a list containing the items
  /// from the source sequence, in batches of count.
  ///
  /// If skip is provided, each group will start where the previous group
  /// ended minus count.
  Observable<List<T>> bufferWithCount(int count, [int skip]);

  /// Creates an Observable that will only emit items from the source sequence
  /// if a particular time span has passed without the source sequence emitting
  /// another item.
  ///
  /// The Debounce operator filters out items emitted by the source Observable
  /// that are rapidly followed by another emitted item.
  ///
  /// http://rxmarbles.com/#debounce
  Observable<T> debounce(Duration duration);

  /// emit items from the source Observable, or a default item if the source
  /// Observable emits nothing
  Observable<T> defaultIfEmpty(T defaultValue);

  /// Creates an Observable where data events are skipped if they are equal to
  /// the previous data event.
  ///
  /// The returned stream provides the same events as this stream, except that
  /// it never provides two consecutive data events that are equal.
  ///
  /// Equality is determined by the provided equals method. If that is omitted,
  /// the '==' operator on the last provided data element is used.
  ///
  /// The returned stream is a broadcast stream if this stream is. If a
  /// broadcast stream is listened to more than once, each subscription will
  /// individually perform the equals test.
  ///
  /// http://rxmarbles.com/#distinct
  @override
  Observable<T> distinct([bool equals(T previous, T next)]);

  /// Creates an Observable from this stream that converts each element into
  /// zero or more events.
  ///
  /// Each incoming event is converted to an Iterable of new events, and each of
  /// these new events are then sent by the returned Observable in order.
  ///
  /// The returned Observable is a broadcast stream if this stream is. If a
  /// broadcast stream is listened to more than once, each subscription will
  /// individually call convert and expand the events.
  @override
  Observable<S> expand<S>(Iterable<S> convert(T value));

  /// Creates an Observable by applying the predicate to each item emitted by
  /// the original Observable, where that function is itself an Observable that
  /// emits items, and then merges the results of that function applied to every
  /// item emitted by the original Observable, emitting these merged results.
  Observable<S> flatMap<S>(Stream<S> predicate(T value));

  /// Creates an Observable by transforming the items emitted by the source into
  /// Observables, and mirroring those items emitted by the most-recently
  /// transformed Observable.
  ///
  /// The flatMapLatest operator is similar to the flatMap and concatMap
  /// methods, however, rather than emitting all of the items emitted by all of
  /// the Observables that the operator generates by transforming items from the
  /// source Observable, flatMapLatest instead emits items from each such
  /// transformed Observable only until the next such Observable is emitted,
  /// then it ignores the previous one and begins emitting items emitted by the
  /// new one.
  Observable<S> flatMapLatest<S>(Stream<S> predicate(T value));

  Observable<GroupByMap<S, T>> groupBy<S>(S keySelector(T value),
      {int compareKeys(S keyA, S keyB)});

  /// Creates a wrapper Stream that intercepts some errors from this stream.
  ///
  /// If this stream sends an error that matches test, then it is intercepted by
  /// the handle function.
  ///
  /// The onError callback must be of type void onError(error) or void
  /// onError(error, StackTrace stackTrace). Depending on the function type the
  /// stream either invokes onError with or without a stack trace. The stack
  /// trace argument might be null if the stream itself received an error
  /// without stack trace.
  ///
  /// An asynchronous error e is matched by a test function if test(e) returns
  /// true. If test is omitted, every error is considered matching.
  ///
  /// If the error is intercepted, the handle function can decide what to do
  /// with it. It can throw if it wants to raise a new (or the same) error, or
  /// simply return to make the stream forget the error.
  ///
  /// If you need to transform an error into a data event, use the more generic
  /// Stream.transform to handle the event by writing a data event to the output
  /// sink.
  ///
  /// The returned stream is a broadcast stream if this stream is. If a
  /// broadcast stream is listened to more than once, each subscription will
  /// individually perform the test and handle the error.
  @override
  Observable<T> handleError(Function onError, {bool test(dynamic error)});

  /// Creates an observable that produces a value after each duration.
  Observable<T> interval(Duration duration);

  /// Maps values from a source sequence through a function and emits the
  /// returned values.
  ///
  /// The returned sequence completes when the source sequence completes.
  /// The returned sequence throws an error if the source sequence throws an
  /// error.
  @override
  Observable<S> map<S>(S convert(T event));

  /// Creates an Observable that returns the maximum value in the source
  /// sequence according to the specified compare function.
  Observable<T> max([int compare(T a, T b)]);

  /// Creates an Observable that returns the minimum value in the source
  /// sequence according to the specified compare function.
  Observable<T> min([int compare(T a, T b)]);

  /// Filters a sequence so that only events of a given type pass
  ///
  /// In order to capture the Type correctly, it needs to be wrapped
  /// in a [TypeToken] as the generic parameter.
  ///
  /// Given the way Dart generics work, one cannot simply use the `is T` / `as T`
  /// checks and castings within `OfTypeObservable` itself. Therefore, the
  /// [TypeToken] class was introduced to capture the type of class you'd
  /// like `ofType` to filter down to.
  ///
  /// Example:
  ///
  /// ```dart
  /// myObservable.ofType(new TypeToken<num>);
  /// ```
  ///
  /// As a shortcut, you can use some pre-defined constants to write the above
  /// in the following way:
  ///
  /// ```dart
  /// myObservable.ofType(kNum);
  /// ```
  ///
  /// If you'd like to create your own shortcuts like the example above,
  /// simply create a constant:
  ///
  /// ```dart
  /// const TypeToken<Map<Int, String>> kMapIntString =
  ///   const TypeToken<Map<Int, String>>();
  /// ```
  Observable<S> ofType<S>(TypeToken<S> typeToken);

  /// Creates an Observable containing the value of a specified nested property
  /// from all elements in the Observable sequence. If a property can't be
  /// resolved, it will return undefined for that value.
  Observable<dynamic> pluck(List<dynamic> sequence, {bool throwOnNull: false});

  /// Creates an Observable that repeats the source's elements the specified
  /// number of times.
  Observable<T> repeat(int repeatCount);

  /// Creates an Observable that will repeat the source sequence the specified
  /// number of times until it successfully terminates. If the retry count is
  /// not specified, it retries indefinitely.
  Observable<T> retry([int count]);

  /// Creates an Observable that will emit the latest value from the source
  /// sequence whenever the sampleStream itself emits a value.
  Observable<T> sample(Stream<dynamic> sampleStream);

  /// Creates an Observable that emits when the source stream emits,
  /// combining the latest values from the two streams using
  /// the provided function.
  ///
  /// If the latestFromStream has not emitted any values, this stream will not
  /// emit either.
  ///
  /// http://rxmarbles.com/#withLatestFrom
  Observable<R> withLatestFrom<S, R>(
      Stream<S> latestFromStream, R fn(T t, S s));

  /// Applies an accumulator function over an observable sequence and returns
  /// each intermediate result. The optional seed value is used as the initial
  /// accumulator value.
  Observable<S> scan<S>(S predicate(S accumulated, T value, int index),
      [S seed]);

  /// Skips the first count data events from this stream.
  ///
  /// The returned stream is a broadcast stream if this stream is. For a
  /// broadcast stream, the events are only counted from the time the returned
  /// stream is listened to.
  @override
  Observable<T> skip(int count);

  /// Skip data events from this stream while they are matched by test.
  ///
  /// Error and done events are provided by the returned stream unmodified.
  ///
  /// Starting with the first data event where test returns false for the event
  /// data, the returned stream will have the same events as this stream.
  ///
  /// The returned stream is a broadcast stream if this stream is. For a
  /// broadcast stream, the events are only tested from the time the returned
  /// stream is listened to.
  @override
  Observable<T> skipWhile(bool test(T element));

  /// Prepends a value to the source Observable.
  Observable<T> startWith(T startValue);

  /// Prepends a sequence of values to the source Observable.
  Observable<T> startWithMany(List<T> startValues);

  /// Provides at most the first `n` values of this stream.
  /// Forwards the first n data events of this stream, and all error events, to
  /// the returned stream, and ends with a done event.
  ///
  /// If this stream produces fewer than count values before it's done, so will
  /// the returned stream.
  ///
  /// Stops listening to the stream after the first n elements have been
  /// received.
  ///
  /// Internally the method cancels its subscription after these elements. This
  /// means that single-subscription (non-broadcast) streams are closed and
  /// cannot be reused after a call to this method.
  ///
  /// The returned stream is a broadcast stream if this stream is. For a
  /// broadcast stream, the events are only counted from the time the returned
  /// stream is listened to
  @override
  Observable<T> take(int count);

  /// Returns the values from the source observable sequence until the other
  /// observable sequence produces a value.
  Observable<T> takeUntil(Stream<dynamic> otherStream);

  /// Forwards data events while test is successful.
  ///
  /// The returned stream provides the same events as this stream as long as
  /// test returns true for the event data. The stream is done when either this
  /// stream is done, or when this stream first provides a value that test
  /// doesn't accept.
  ///
  /// Stops listening to the stream after the accepted elements.
  ///
  /// Internally the method cancels its subscription after these elements. This
  /// means that single-subscription (non-broadcast) streams are closed and
  /// cannot be reused after a call to this method.
  ///
  /// The returned stream is a broadcast stream if this stream is. For a
  /// broadcast stream, the events are only tested from the time the returned
  /// stream is listened to.
  @override
  Observable<T> takeWhile(bool test(T element));

  /// Invokes an action for each element in the observable sequence and invokes
  /// an action upon graceful or exceptional termination of the observable
  /// sequence.
  ///
  /// This method can be used for debugging, logging, etc. of query behavior by
  /// intercepting the message stream to run arbitrary actions for messages on
  /// the pipeline.
  Observable<T> tap(void action(T value));

  /// Returns an Observable that emits only the first item emitted by the source
  /// Observable during sequential time windows of a specified duration.
  Observable<T> throttle(Duration duration);

  /// Records the time interval between consecutive values in an observable
  /// sequence.
  Observable<TimeInterval<T>> timeInterval();

  /// The Timeout operator allows you to abort an Observable with an onError
  /// termination if that Observable fails to emit any items during a specified
  /// duration.  You may optionally provide a callback function to execute on
  /// timeout.
  @override
  Observable<T> timeout(Duration timeLimit,
      {void onTimeout(EventSink<T> sink)});

  /// Filters the elements of an observable sequence based on the test.
  @override
  Observable<T> where(bool test(T event));

  /// Projects each element of an observable sequence into zero or more windows
  /// which are produced based on element count information.
  Observable<Observable<T>> windowWithCount(int count, [int skip]);
}
