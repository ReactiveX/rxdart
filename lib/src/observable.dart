import 'dart:async';

import 'package:rxdart/src/streams/amb.dart';
import 'package:rxdart/src/streams/combine_latest.dart';
import 'package:rxdart/src/streams/concat.dart';
import 'package:rxdart/src/streams/concat_eager.dart';
import 'package:rxdart/src/streams/defer.dart';
import 'package:rxdart/src/streams/error.dart';
import 'package:rxdart/src/streams/merge.dart';
import 'package:rxdart/src/streams/never.dart';
import 'package:rxdart/src/streams/tween.dart';
import 'package:rxdart/src/streams/zip.dart';

import 'package:rxdart/src/transformers/buffer_with_count.dart';
import 'package:rxdart/src/transformers/call.dart';
import 'package:rxdart/src/transformers/debounce.dart';
import 'package:rxdart/src/transformers/default_if_empty.dart';
import 'package:rxdart/src/transformers/flat_map.dart';
import 'package:rxdart/src/transformers/flat_map_latest.dart';
import 'package:rxdart/src/transformers/group_by.dart';
import 'package:rxdart/src/transformers/ignore_elements.dart';
import 'package:rxdart/src/transformers/interval.dart';
import 'package:rxdart/src/transformers/max.dart';
import 'package:rxdart/src/transformers/min.dart';
import 'package:rxdart/src/transformers/of_type.dart';
import 'package:rxdart/src/transformers/on_error_resume_next.dart';
import 'package:rxdart/src/transformers/repeat.dart';
import 'package:rxdart/src/transformers/retry.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/scan.dart';
import 'package:rxdart/src/transformers/start_with.dart';
import 'package:rxdart/src/transformers/start_with_many.dart';
import 'package:rxdart/src/transformers/switch_if_empty.dart';
import 'package:rxdart/src/transformers/take_until.dart';
import 'package:rxdart/src/transformers/throttle.dart';
import 'package:rxdart/src/transformers/time_interval.dart';
import 'package:rxdart/src/transformers/window_with_count.dart';
import 'package:rxdart/src/transformers/with_latest_from.dart';

/// Deprecated: Please use `new Observable(stream)` instead
Observable<S> observable<S>(Stream<S> stream) => new Observable<S>(stream);

class Observable<T> extends Stream<T> {
  final Stream<T> stream;

  Observable(this.stream);

  /// Given two or more source Observables, emit all of the items from only
  /// the first of these Observables to emit an item or notification.
  ///
  /// http://rxmarbles.com/#amb
  factory Observable.amb(Iterable<Stream<T>> streams) =>
      new Observable<T>(new AmbStream<T>(streams));

  @override
  Future<bool> any(bool test(T element)) => stream.any(test);

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  @Deprecated(
      'For better strong mode support, use combineLatest2, combineLatest3, ... instead')
  factory Observable.combineLatest(
          Iterable<Stream<dynamic>> streams, Function predicate) =>
      new Observable<T>(new CombineLatestStream<T>(streams, predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest2<A, B, T>(
          Stream<A> streamOne, Stream<B> streamTwo, T predicate(A a, B b)) =>
      new Observable<T>(new CombineLatestStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo], predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest3<A, B, C, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          T predicate(A a, B b, C c)) =>
      new Observable<T>(new CombineLatestStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree], predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest4<A, B, C, D, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          T predicate(A a, B b, C c, D d)) =>
      new Observable<T>(new CombineLatestStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
          predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest5<A, B, C, D, E, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          T predicate(A a, B b, C c, D d, E e)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive
      ], predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest6<A, B, C, D, E, F, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          T predicate(A a, B b, C c, D d, E e, F f)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix
      ], predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest7<A, B, C, D, E, F, G, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          T predicate(A a, B b, C c, D d, E e, F f, G g)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven
      ], predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest8<A, B, C, D, E, F, G, H, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          T predicate(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight
      ], predicate));

  /// Creates an Observable where each item is the result of passing the latest
  /// values from each feeder stream into the predicate function.
  ///
  /// http://rxmarbles.com/#combineLatest
  static Observable<T> combineLatest9<A, B, C, D, E, F, G, H, I, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          Stream<I> streamNine,
          T predicate(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight,
        streamNine
      ], predicate));

  /// Concatenates all of the specified observable sequences, as long as the
  /// previous observable sequence terminated successfully..
  ///
  /// http://rxmarbles.com/#concat
  factory Observable.concat(Iterable<Stream<T>> streams) =>
      new Observable<T>(new ConcatStream<T>(streams));

  /// Concatenates all of the specified observable sequences,
  /// a backlog is being kept for events that emit on the waiting streams.
  /// When a previous sequence is terminated, all backlog for the next stream
  /// is eagerly emitted at once.
  ///
  factory Observable.concatEager(Iterable<Stream<T>> streams) =>
      new Observable<T>(new ConcatEagerStream<T>(streams));

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
  factory Observable.defer(Stream<T> createStream()) =>
      new Observable<T>(new DeferStream<T>(createStream));

  /// Returns an observable sequence that terminates with an exception, then
  /// immediately completes.
  ///
  /// The error operator is one with very specific and limited behavior. It is
  /// mostly useful for testing purposes.
  ///
  /// ### Example
  ///
  ///     new Observable.error(new ArgumentError());
  factory Observable.error(Object error) =>
      new Observable<T>(new ErrorStream<T>(error));

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
      new Observable<T>((new Stream<T>.eventTransformed(source, mapSink)));

  /// Creates an Observable from the future.
  ///
  /// When the future completes, the stream will fire one event, either
  /// data or error, and then close with a done-event.
  factory Observable.fromFuture(Future<T> future) =>
      new Observable<T>((new Stream<T>.fromFuture(future)));

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
      new Observable<T>((new Stream<T>.fromIterable(data)));

  /// Creates an Observable that contains a single value
  ///
  /// The value is emitted when the stream receives a listener.
  factory Observable.just(T data) =>
      new Observable<T>((new Stream<T>.fromIterable(<T>[data])));

  /// Creates an Observable that contains no values.
  ///
  /// No items are emitted from the stream, and done is called upon listening.
  factory Observable.empty() => observable((new Stream<T>.empty()));

  /// Creates an Observable where each item is the interleaved output emitted by
  /// the feeder streams.
  ///
  /// http://rxmarbles.com/#merge
  factory Observable.merge(Iterable<Stream<T>> streams) =>
      new Observable<T>(new MergeStream<T>(streams));

  /// Returns a non-terminating observable sequence, which can be used to denote
  /// an infinite duration.
  ///
  /// The never operator is one with very specific and limited behavior. These
  /// are useful for testing purposes, and sometimes also for combining with
  /// other Observables or as parameters to operators that expect other
  /// Observables as parameters.
  factory Observable.never() =>
      new Observable<T>(new NeverStream<T>());

  /// Creates an Observable that repeatedly emits events at [period] intervals.
  ///
  /// The event values are computed by invoking [computation]. The argument to
  /// this callback is an integer that starts with 0 and is incremented for
  /// every event.
  ///
  /// If [computation] is omitted the event values will all be `null`.
  factory Observable.periodic(Duration period,
          [T computation(int computationCount)]) =>
      new Observable<T>((new Stream<T>.periodic(period, computation)));

  /// Creates an Observable that emits values starting from startValue and
  /// incrementing according to the ease type over the duration.
  /// todo : needs more detail
  static Observable<double> tween(
          double startValue, double changeInTime, Duration duration,
          {int intervalMs: 20, Ease ease: Ease.LINEAR}) =>
      new Observable<double>(new TweenStream(
          startValue, changeInTime, duration, intervalMs, ease));

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
  @Deprecated('For better strong mode support, use zip2, zip3, ... instead')
  factory Observable.zip(
          Iterable<Stream<dynamic>> streams, Function predicate) =>
      new Observable<T>(new ZipStream<T>(streams, predicate));

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
  static Observable<T> zip2<A, B, T>(
          Stream<A> streamOne, Stream<B> streamTwo, T predicate(A a, B b)) =>
      new Observable<T>(
          new ZipStream<T>(<Stream<dynamic>>[streamOne, streamTwo], predicate));

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
  static Observable<T> zip3<A, B, C, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          T predicate(A a, B b, C c)) =>
      new Observable<T>(new ZipStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree], predicate));

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
  static Observable<T> zip4<A, B, C, D, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          T predicate(A a, B b, C c, D d)) =>
      new Observable<T>(new ZipStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
          predicate));

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
  static Observable<T> zip5<A, B, C, D, E, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          T predicate(A a, B b, C c, D d, E e)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive
      ], predicate));

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
  static Observable<T> zip6<A, B, C, D, E, F, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          T predicate(A a, B b, C c, D d, E e, F f)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix
      ], predicate));

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
  static Observable<T> zip7<A, B, C, D, E, F, G, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          T predicate(A a, B b, C c, D d, E e, F f, G g)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven
      ], predicate));

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
  static Observable<T> zip8<A, B, C, D, E, F, G, H, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          T predicate(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight
      ], predicate));

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
  static Observable<T> zip9<A, B, C, D, E, F, G, H, I, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          Stream<I> streamNine,
          T predicate(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight,
        streamNine
      ], predicate));

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
          void onCancel(StreamSubscription<T> subscription)}) =>
      new Observable<T>(
          stream.asBroadcastStream(onListen: onListen, onCancel: onCancel));

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
  Observable<S> asyncExpand<S>(Stream<S> convert(T value)) =>
      new Observable<S>(stream.asyncExpand(convert));

  /// Creates an Observable with each data event of this stream asynchronously
  /// mapped to a new event.
  ///
  /// This acts like map, except that convert may return a Future, and in that
  /// case, the stream waits for that future to complete before continuing with
  /// its result.
  ///
  /// The returned stream is a broadcast stream if this stream is.
  @override
  Observable<S> asyncMap<S>(dynamic convert(T value)) =>
      new Observable<S>(stream.asyncMap(convert));

  /// Creates an Observable where each item is a list containing the items
  /// from the source sequence, in batches of count.
  ///
  /// If skip is provided, each group will start where the previous group
  /// ended minus count.
  Observable<List<T>> bufferWithCount(int count, [int skip]) =>
      transform(bufferWithCountTransformer(count, skip));

  /// Invokes each callback at the given point in the stream lifecycle
  ///
  /// This method can be used for debugging, logging, etc. by intercepting the
  /// stream at different points to run arbitrary actions.
  ///
  /// It is possible to hook onto the following parts of the stream lifecycle:
  ///
  ///   - onCancel
  ///   - onData
  ///   - onDone
  ///   - onError
  ///   - onListen
  ///   - onPause
  ///   - onResume
  ///
  /// In addition, the `onEach` argument is called at `onData`, `onDone`, and
  /// `onError` with a [Notification] passed in. The [Notification] argument
  /// contains the [Kind] of event (OnData, OnDone, OnError), and the item or
  /// error that was emitted. In the case of onDone, no data is emitted as part
  /// of the [Notification].
  ///
  /// If no callbacks are passed in, a runtime error will be thrown in dev mode
  /// in order to "fail fast" and alert the developer that the operator should
  /// be used or safely removed.
  ///
  /// ### Example
  ///
  ///     new Observable.just(1).call(onData: (i) => print(i)); // Prints: 1
  Observable<T> call(
          {void onCancel(),
          void onData(T event),
          void onDone(),
          void onEach(Notification<T> notification),
          Function onError,
          void onListen(),
          void onPause(Future<dynamic> resumeSignal),
          void onResume()}) =>
      transform(callTransformer(
          onCancel: onCancel,
          onData: onData,
          onDone: onDone,
          onEach: onEach,
          onError: onError,
          onListen: onListen,
          onPause: onPause,
          onResume: onResume));

  @override
  Future<bool> contains(Object needle) => stream.contains(needle);

  /// Creates an Observable that will only emit items from the source sequence
  /// if a particular time span has passed without the source sequence emitting
  /// another item.
  ///
  /// The Debounce operator filters out items emitted by the source Observable
  /// that are rapidly followed by another emitted item.
  ///
  /// http://rxmarbles.com/#debounce
  Observable<T> debounce(Duration duration) =>
      transform(debounceTransformer(duration));

  /// emit items from the source Observable, or a default item if the source
  /// Observable emits nothing
  Observable<T> defaultIfEmpty(T defaultValue) =>
      transform(defaultIfEmptyTransformer(defaultValue));

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
  Observable<T> distinct([bool equals(T previous, T next)]) =>
      new Observable<T>(stream.distinct(equals));

  @override
  Future<S> drain<S>([S futureValue]) => stream.drain(futureValue);

  @override
  Future<T> elementAt(int index) => stream.elementAt(index);

  @override
  Future<bool> every(bool test(T element)) => stream.every(test);

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
  Observable<S> expand<S>(Iterable<S> convert(T value)) =>
      new Observable<S>(stream.expand(convert));

  @override
  Future<T> get first => stream.first;

  @override
  Future<dynamic> firstWhere(bool test(T element), {Object defaultValue()}) =>
      stream.firstWhere(test, defaultValue: defaultValue);

  /// Creates an Observable by applying the predicate to each item emitted by
  /// the original Observable, where that function is itself an Observable that
  /// emits items, and then merges the results of that function applied to every
  /// item emitted by the original Observable, emitting these merged results.
  Observable<S> flatMap<S>(Stream<S> predicate(T value)) =>
      transform(flatMapTransformer(predicate));

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
  Observable<S> flatMapLatest<S>(Stream<S> predicate(T value)) =>
      transform(flatMapLatestTransformer(predicate));

  @override
  Future<S> fold<S>(S initialValue, S combine(S previous, T element)) => stream
      .fold(initialValue, combine);

  @override
  Future<dynamic> forEach(void action(T element)) => stream.forEach(action);

  /// The GroupBy operator divides an Observable that emits items into an
  /// Observable that emits Observables, each one of which emits some subset
  /// of the items from the original source Observable.
  ///
  ///  Which items end up on which Observable is typically decided by a
  ///  discriminating function that evaluates each item and assigns it a
  ///  key. All items with the same key are emitted by the same Observable.
  Observable<GroupByMap<S, T>> groupBy<S>(S keySelector(T value),
          {int compareKeys(S keyA, S keyB): null}) =>
      transform(groupByTransformer(keySelector, compareKeys: compareKeys));

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
  Observable<T> handleError(Function onError, {bool test(dynamic error)}) =>
      new Observable<T>(stream.handleError(onError, test: test));

  /// Creates an observable where all incoming events are ignored, only the error/completed notifications are passed
  Observable<T> ignoreElements() => transform(ignoreElementsTransformer());

  /// Creates an observable that produces a value after each duration.
  Observable<T> interval(Duration duration) =>
      transform(intervalTransformer(duration));

  @override
  bool get isBroadcast {
    return (stream != null) ? stream.isBroadcast : false;
  }

  @override
  Future<bool> get isEmpty => stream.isEmpty;

  @override
  Future<String> join([String separator = ""]) => stream.join(separator);

  @override
  Future<T> get last => stream.last;

  @override
  Future<dynamic> lastWhere(bool test(T element), {Object defaultValue()}) =>
      stream.lastWhere(test, defaultValue: defaultValue);

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  Future<int> get length => stream.length;

  /// Maps values from a source sequence through a function and emits the
  /// returned values.
  ///
  /// The returned sequence completes when the source sequence completes.
  /// The returned sequence throws an error if the source sequence throws an
  /// error.
  @override
  Observable<S>
      map<S>(S convert(T event)) => new Observable<S>(stream.map(convert));

  /// Creates an Observable that returns the maximum value in the source
  /// sequence according to the specified compare function.
  Observable<T> max([int compare(T a, T b)]) =>
      transform(maxTransformer(compare));

  /// Creates an Observable that returns the minimum value in the source
  /// sequence according to the specified compare function.
  Observable<T> min([int compare(T a, T b)]) =>
      transform(minTransformer(compare));

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
  Observable<S> ofType<S>(TypeToken<S> typeToken) =>
      transform(ofTypeTransformer(typeToken));

  /// Intercepts error events and switches to the given stream in that case
  ///
  /// The onErrorResumeNext operator intercepts an onError notification from
  /// the source Observable. Instead of passing it through to any observers, it
  /// replaces it with another Stream of items.
  Observable<T> onErrorResumeNext(Stream<T> recoveryStream) =>
      transform(onErrorResumeNextTransformer(recoveryStream));

  /// instructs an Observable to emit a particular item when it encounters an
  /// error, and then terminate normally
  ///
  /// The onErrorReturn operator intercepts an onError notification from
  /// the source Observable. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  Observable<T> onErrorReturn(T returnValue) => transform(
      onErrorResumeNextTransformer(new Observable<T>.just(returnValue)));

  @override
  Future<dynamic> pipe(StreamConsumer<T> streamConsumer) =>
      stream.pipe(streamConsumer);

  @override
  Future<T> reduce(T combine(T previous, T element)) => stream.reduce(combine);

  /// Creates an Observable that repeats the source's elements the specified
  /// number of times.
  Observable<T> repeat(int repeatCount) =>
      transform(repeatTransformer(repeatCount));

  /// Creates an Observable that will repeat the source sequence the specified
  /// number of times until it successfully terminates. If the retry count is
  /// not specified, it retries indefinitely.
  Observable<T> retry([int count]) => transform(retryTransformer(count));

  /// Creates an Observable that will emit the latest value from the source
  /// sequence whenever the sampleStream itself emits a value.
  Observable<T> sample(Stream<dynamic> sampleStream) =>
      transform(sampleTransformer(sampleStream));

  /// Applies an accumulator function over an observable sequence and returns
  /// each intermediate result. The optional seed value is used as the initial
  /// accumulator value.
  Observable<S> scan<S>(S predicate(S accumulated, T value, int index),
          [S seed]) =>
      transform(scanTransformer(predicate, seed));

  @override
  Future<T> get single => stream.single;

  @override
  Future<T> singleWhere(bool test(T element)) => stream.singleWhere(test);

  /// Skips the first count data events from this stream.
  ///
  /// The returned stream is a broadcast stream if this stream is. For a
  /// broadcast stream, the events are only counted from the time the returned
  /// stream is listened to.
  @override
  Observable<T> skip(int count) => new Observable<T>(stream.skip(count));

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
  Observable<T> skipWhile(bool test(T element)) =>
      new Observable<T>(stream.skipWhile(test));

  /// Prepends a value to the source Observable.
  Observable<T> startWith(T startValue) =>
      transform(startWithTransformer(startValue));

  /// Prepends a sequence of values to the source Observable.
  Observable<T> startWithMany(List<T> startValues) =>
      transform(startWithManyTransformer(startValues));

  /// When the original observable emits no items, this operator subscribes to
  /// the given fallback stream and emits items from that observable instead.
  ///
  /// This can be particularly useful when consuming data from multiple sources.
  /// For example, when using the Repository Pattern. Assuming you have some
  /// data you need to load, you might want to start with the fastest access
  /// point and keep falling back to the slowest point. For example, first query
  /// an in-memory database, then a database on the file system, then a network
  /// call if the data isn't on the local machine.
  ///
  /// This can be achieved quite simply with switchIfEmpty!
  ///
  /// ### Example
  ///
  /// ```
  /// // Let's pretend we have some Data sources that complete without emitting
  /// // any items if they don't contain the data we're looking for
  /// Observable<Data> memory;
  /// Observable<Data> disk;
  /// Observable<Data> network;
  ///
  /// // Start with memory, fallback to disk, then fallback to network.
  /// // Simple as that!
  /// Observable<Data> getThatData =
  ///     memory.switchIfEmpty(disk).switchIfEmpty(network);
  /// ```
  Observable<T> switchIfEmpty(Stream<T> fallbackStream) =>
      transform(switchIfEmptyTransformer(fallbackStream));

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
  Observable<T> take(int count) => new Observable<T>(stream.take(count));

  /// Returns the values from the source observable sequence until the other
  /// observable sequence produces a value.
  Observable<T> takeUntil(Stream<dynamic> otherStream) =>
      transform(takeUntilTransformer(otherStream));

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
  Observable<T> takeWhile(bool test(T element)) =>
      new Observable<T>(stream.takeWhile(test));

  /// Returns an Observable that emits only the first item emitted by the source
  /// Observable during sequential time windows of a specified duration.
  Observable<T> throttle(Duration duration) =>
      transform(throttleTransformer(duration));

  /// Records the time interval between consecutive values in an observable
  /// sequence.
  Observable<TimeInterval<T>> timeInterval() =>
      transform(timeIntervalTransformer<T, TimeInterval<T>>());

  /// The Timeout operator allows you to abort an Observable with an onError
  /// termination if that Observable fails to emit any items during a specified
  /// duration.  You may optionally provide a callback function to execute on
  /// timeout.
  @override
  Observable<T> timeout(Duration timeLimit,
          {void onTimeout(EventSink<T> sink)}) =>
      new Observable<T>(stream.timeout(timeLimit, onTimeout: onTimeout));

  @override
  Observable<S> transform<S>(StreamTransformer<T, S> streamTransformer) =>
      new Observable<S>(super.transform(streamTransformer));

  @override
  Future<List<T>> toList() => stream.toList();

  @override
  Future<Set<T>> toSet() => stream.toSet();

  /// Filters the elements of an observable sequence based on the test.
  @override
  Observable<T> where(bool test(T event)) =>
      new Observable<T>(stream.where(test));

  /// Projects each element of an observable sequence into zero or more windows
  /// which are produced based on element count information.
  Observable<Observable<T>> windowWithCount(int count, [int skip]) =>
      transform(windowWithCountTransformer(count, skip));

  /// Creates an Observable that emits when the source stream emits,
  /// combining the latest values from the two streams using
  /// the provided function.
  ///
  /// If the latestFromStream has not emitted any values, this stream will not
  /// emit either.
  ///
  /// http://rxmarbles.com/#withLatestFrom
  Observable<R> withLatestFrom<S, R>(
          Stream<S> latestFromStream, R fn(T t, S s)) =>
      transform(withLatestFromTransformer(latestFromStream, fn));
}
