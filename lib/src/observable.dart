import 'dart:async';

import 'package:rxdart/src/streams/amb.dart';
import 'package:rxdart/src/streams/combine_latest.dart';
import 'package:rxdart/src/streams/concat.dart';
import 'package:rxdart/src/streams/concat_eager.dart';
import 'package:rxdart/src/streams/defer.dart';
import 'package:rxdart/src/streams/error.dart';
import 'package:rxdart/src/streams/merge.dart';
import 'package:rxdart/src/streams/never.dart';
import 'package:rxdart/src/streams/range.dart';
import 'package:rxdart/src/streams/retry.dart';
import 'package:rxdart/src/streams/timer.dart';
import 'package:rxdart/src/streams/tween.dart';
import 'package:rxdart/src/streams/zip.dart';

import 'package:rxdart/src/transformers/buffer_with_count.dart';
import 'package:rxdart/src/transformers/call.dart';
import 'package:rxdart/src/transformers/concat_map.dart';
import 'package:rxdart/src/transformers/debounce.dart';
import 'package:rxdart/src/transformers/default_if_empty.dart';
import 'package:rxdart/src/transformers/dematerialize.dart';
import 'package:rxdart/src/transformers/flat_map.dart';
import 'package:rxdart/src/transformers/flat_map_latest.dart';
import 'package:rxdart/src/transformers/group_by.dart';
import 'package:rxdart/src/transformers/ignore_elements.dart';
import 'package:rxdart/src/transformers/interval.dart';
import 'package:rxdart/src/transformers/materialize.dart';
import 'package:rxdart/src/transformers/max.dart';
import 'package:rxdart/src/transformers/min.dart';
import 'package:rxdart/src/transformers/of_type.dart';
import 'package:rxdart/src/transformers/on_error_resume_next.dart';
import 'package:rxdart/src/transformers/repeat.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/scan.dart';
import 'package:rxdart/src/transformers/skip_until.dart';
import 'package:rxdart/src/transformers/start_with.dart';
import 'package:rxdart/src/transformers/start_with_many.dart';
import 'package:rxdart/src/transformers/switch_if_empty.dart';
import 'package:rxdart/src/transformers/take_until.dart';
import 'package:rxdart/src/transformers/throttle.dart';
import 'package:rxdart/src/transformers/time_interval.dart';
import 'package:rxdart/src/transformers/timestamp.dart';
import 'package:rxdart/src/transformers/window_with_count.dart';
import 'package:rxdart/src/transformers/with_latest_from.dart';

class Observable<T> extends Stream<T> {
  final Stream<T> stream;

  Observable(this.stream);

  /// Given two or more source [streams], emit all of the items from only
  /// the first of these [streams] to emit an item or notification.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#amb)
  ///
  /// ### Example
  ///
  ///     new Observable.amb([
  ///       new Observable.timer(1, new Duration(days: 1)),
  ///       new Observable.timer(2, new Duration(days: 2)),
  ///       new Observable.timer(3, new Duration(seconds: 1))
  ///     ]).listen(print); // prints 3
  factory Observable.amb(Iterable<Stream<T>> streams) =>
      new Observable<T>(new AmbStream<T>(streams));

  @override
  Future<bool> any(bool test(T element)) => stream.any(test);

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest2(
  ///       new Observable.just(1),
  ///       new Observable.fromIterable([0, 1, 2]),
  ///       (a, b) => a + b)
  ///     .listen(print); //prints 1, 2, 3
  static Observable<T> combineLatest2<A, B, T>(
          Stream<A> streamOne, Stream<B> streamTwo, T combiner(A a, B b)) =>
      new Observable<T>(new CombineLatestStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo], combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest3(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.fromIterable(["c", "c"]),
  ///       (a, b, c) => a + b + c)
  ///     .listen(print); //prints "abc", "abc"
  static Observable<T> combineLatest3<A, B, C, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          T combiner(A a, B b, C c)) =>
      new Observable<T>(new CombineLatestStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree], combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest4(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.fromIterable(["d", "d"]),
  ///       (a, b, c, d) => a + b + c + d)
  ///     .listen(print); //prints "abcd", "abcd"
  static Observable<T> combineLatest4<A, B, C, D, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          T combiner(A a, B b, C c, D d)) =>
      new Observable<T>(new CombineLatestStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
          combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest5(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.fromIterable(["e", "e"]),
  ///       (a, b, c, d, e) => a + b + c + d + e)
  ///     .listen(print); //prints "abcde", "abcde"
  static Observable<T> combineLatest5<A, B, C, D, E, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          T combiner(A a, B b, C c, D d, E e)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive
      ], combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest6(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.fromIterable(["f", "f"]),
  ///       (a, b, c, d, e, f) => a + b + c + d + e + f)
  ///     .listen(print); //prints "abcdef", "abcdef"
  static Observable<T> combineLatest6<A, B, C, D, E, F, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          T combiner(A a, B b, C c, D d, E e, F f)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix
      ], combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest7(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.fromIterable(["g", "g"]),
  ///       (a, b, c, d, e, f, g) => a + b + c + d + e + f + g)
  ///     .listen(print); //prints "abcdefg", "abcdefg"
  static Observable<T> combineLatest7<A, B, C, D, E, F, G, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          T combiner(A a, B b, C c, D d, E e, F f, G g)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven
      ], combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest8(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.just("g"),
  ///       new Observable.fromIterable(["h", "h"]),
  ///       (a, b, c, d, e, f, g, h) => a + b + c + d + e + f + g + h)
  ///     .listen(print); //prints "abcdefgh", "abcdefgh"
  static Observable<T> combineLatest8<A, B, C, D, E, F, G, H, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      new Observable<T>(new CombineLatestStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight
      ], combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The Observable will not emit until all streams have emitted at least one
  /// item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatest9(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.just("g"),
  ///       new Observable.just("h"),
  ///       new Observable.fromIterable(["i", "i"]),
  ///       (a, b, c, d, e, f, g, h, i) => a + b + c + d + e + f + g + h + i)
  ///     .listen(print); //prints "abcdefghi", "abcdefghi"
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
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
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
      ], combiner));

  /// Concatenates all of the specified stream sequences, as long as the
  /// previous stream sequence terminated successfully.
  ///
  /// It does this by subscribing to each stream one by one, emitting all items
  /// and completing before subscribing to the next stream.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#concat)
  ///
  /// ### Example
  ///
  ///     new Observable.concat([
  ///       new Observable.just(1),
  ///       new Observable.timer(2, new Duration(days: 1)),
  ///       new Observable.just(3)
  ///     ])
  ///     .listen(print); // prints 1, 2, 3
  factory Observable.concat(Iterable<Stream<T>> streams) =>
      new Observable<T>(new ConcatStream<T>(streams));

  /// Concatenates all of the specified stream sequences, as long as the
  /// previous stream sequence terminated successfully.
  ///
  /// In the case of concatEager, rather than subscribing to one stream after
  /// the next, all streams are immediately subscribed to. The events are then
  /// captured and emitted at the correct time, after the previous stream has
  /// finished emitting items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#concat)
  ///
  /// ### Example
  ///
  ///     new Observable.concatEager([
  ///       new Observable.just(1),
  ///       new Observable.timer(2, new Duration(days: 1)),
  ///       new Observable.just(3)
  ///     ])
  ///     .listen(print); // prints 1, 2, 3
  factory Observable.concatEager(Iterable<Stream<T>> streams) =>
      new Observable<T>(new ConcatEagerStream<T>(streams));

  /// The defer factory waits until an observer subscribes to it, and then it
  /// creates an Observable with the given factory function.
  ///
  /// In some circumstances, waiting until the last minute (that is, until
  /// subscription time) to generate the Observable can ensure that this
  /// Observable contains the freshest data.
  ///
  /// ### Example
  ///
  ///     new Observable.defer(() => new Observable.just(1))
  ///       .listen(print); //prints 1
  factory Observable.defer(Stream<T> streamFactory()) =>
      new Observable<T>(new DeferStream<T>(streamFactory));

  /// Returns an observable sequence that emits an [error], then immediately
  /// completes.
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
  ///
  /// ### Example
  ///
  ///     new Observable.fromFuture(new Future.value("Hello"))
  ///       .listen(print); // prints "Hello"
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
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2]).listen(print); // prints 1, 2
  factory Observable.fromIterable(Iterable<T> data) =>
      new Observable<T>((new Stream<T>.fromIterable(data)));

  /// Creates an Observable that contains a single value
  ///
  /// The value is emitted when the stream receives a listener.
  ///
  /// ### Example
  ///
  ///      new Observable.just(1).listen(print); // prints 1
  factory Observable.just(T data) =>
      new Observable<T>((new Stream<T>.fromIterable(<T>[data])));

  /// Creates an Observable that contains no values.
  ///
  /// No items are emitted from the stream, and done is called upon listening.
  ///
  /// ### Example
  ///
  ///     new Observable.empty().listen(
  ///       (_) => print("data"), onDone: () => print("done")); // prints "done"
  factory Observable.empty() => new Observable<T>((new Stream<T>.empty()));

  /// Flattens the items emitted by the given [streams] into a single Observable
  /// sequence.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#merge)
  ///
  /// ### Example
  ///
  ///     new Observable.merge([
  ///       new Observable.timer(1, new Duration(days: 10)),
  ///       new Observable.just(2)
  ///     ])
  ///     .listen(print); // prints 2, 1
  factory Observable.merge(Iterable<Stream<T>> streams) =>
      new Observable<T>(new MergeStream<T>(streams));

  /// Returns a non-terminating observable sequence, which can be used to denote
  /// an infinite duration.
  ///
  /// The never operator is one with very specific and limited behavior. These
  /// are useful for testing purposes, and sometimes also for combining with
  /// other Observables or as parameters to operators that expect other
  /// Observables as parameters.
  ///
  /// ### Example
  ///
  ///     new Observable.never().listen(print); // Neither prints nor terminates
  factory Observable.never() => new Observable<T>(new NeverStream<T>());

  /// Creates an Observable that repeatedly emits events at [period] intervals.
  ///
  /// The event values are computed by invoking [computation]. The argument to
  /// this callback is an integer that starts with 0 and is incremented for
  /// every event.
  ///
  /// If [computation] is omitted the event values will all be `null`.
  ///
  /// ### Example
  ///
  ///      new Observable.periodic(new Duration(seconds: 1), (i) => i).take(3)
  ///        .listen(print); // prints 0, 1, 2
  factory Observable.periodic(Duration period,
          [T computation(int computationCount)]) =>
      new Observable<T>((new Stream<T>.periodic(period, computation)));

  /// Returns an Observable that emits a sequence of Integers within a specified
  /// range.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 3).listen((i) => print(i)); // Prints 1, 2, 3
  ///
  ///     Observable.range(3, 1).listen((i) => print(i)); // Prints 3, 2, 1
  static Observable<int> range(int startInclusive, int endInclusive) =>
      new Observable<int>(new RangeStream(startInclusive, endInclusive));

  /// Creates an Observable that will recreate and re-listen to the source
  /// Stream the specified number of times until the Stream terminates
  /// successfully.
  ///
  /// If the retry count is not specified, it retries indefinitely. If the retry
  /// count is met, but the Stream has not terminated successfully, a
  /// `RetryError` will be thrown.
  ///
  /// ### Example
  ///
  ///     new Observable.retry(() { new Observable.just(1); })
  ///         .listen((i) => print(i)); // Prints 1
  ///
  ///     new Observable
  ///        .retry(() {
  ///          new Observable.just(1).concatWith([new Observable.error(new Error())]);
  ///        }, 1)
  ///        .listen(print, onError: (e, s) => print(e)); // Prints 1, 1, RetryError
  factory Observable.retry(Stream<T> streamFactory(), [int count]) {
    return new Observable<T>(new RetryStream<T>(streamFactory, count));
  }

  /// Emits the given value after a specified amount of time.
  ///
  /// ### Example
  ///
  ///     new Observable.timer("hi", new Duration(minutes: 1))
  ///         .listen((i) => print(i)); // print "hi" after 1 minute
  factory Observable.timer(T value, Duration duration) =>
      new Observable<T>((new TimerStream<T>(value, duration)));

  /// Creates an Observable that emits values starting from startValue and
  /// incrementing according to the ease type over the duration.
  ///
  /// This function is generally useful for transitions, such as animating
  /// items across a screen or muting the volume of a sound gracefully.
  ///
  /// ### Example
  ///
  ///     Observable
  ///       .tween(0.0, 100.0, const Duration(seconds: 1), ease: Ease.IN)
  ///       .listen((i) => view.setLeft(i)); // Imaginary API as an example
  static Observable<double> tween(
          double startValue, double changeInTime, Duration duration,
          {int intervalMs: 16, Ease ease: Ease.LINEAR}) =>
      new Observable<double>(new TweenStream(
          startValue, changeInTime, duration, intervalMs, ease));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip2(
  ///       new Observable.just("Hi "),
  ///       new Observable.fromIterable(["Friend", "Dropped"]),
  ///       (a, b) => a + b)
  ///     .listen(print); // prints "Hi Friend"
  static Observable<T> zip2<A, B, T>(
          Stream<A> streamOne, Stream<B> streamTwo, T zipper(A a, B b)) =>
      new Observable<T>(
          new ZipStream<T>(<Stream<dynamic>>[streamOne, streamTwo], zipper));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip3(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.fromIterable(["c", "dropped"]),
  ///       (a, b, c) => a + b + c)
  ///     .listen(print); //prints "abc"
  static Observable<T> zip3<A, B, C, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          T zipper(A a, B b, C c)) =>
      new Observable<T>(new ZipStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree], zipper));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip4(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.fromIterable(["d", "dropped"]),
  ///       (a, b, c, d) => a + b + c + d)
  ///     .listen(print); //prints "abcd"
  static Observable<T> zip4<A, B, C, D, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          T zipper(A a, B b, C c, D d)) =>
      new Observable<T>(new ZipStream<T>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
          zipper));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip5(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.fromIterable(["e", "dropped"]),
  ///       (a, b, c, d, e) => a + b + c + d + e)
  ///     .listen(print); //prints "abcde"
  static Observable<T> zip5<A, B, C, D, E, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          T zipper(A a, B b, C c, D d, E e)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive
      ], zipper));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip6(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.fromIterable(["f", "dropped"]),
  ///       (a, b, c, d, e, f) => a + b + c + d + e + f)
  ///     .listen(print); //prints "abcdef"
  static Observable<T> zip6<A, B, C, D, E, F, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          T zipper(A a, B b, C c, D d, E e, F f)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix
      ], zipper));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip7(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.fromIterable(["g", "dropped"]),
  ///       (a, b, c, d, e, f, g) => a + b + c + d + e + f + g)
  ///     .listen(print); //prints "abcdefg"
  static Observable<T> zip7<A, B, C, D, E, F, G, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          T zipper(A a, B b, C c, D d, E e, F f, G g)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven
      ], zipper));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip8(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.just("g"),
  ///       new Observable.fromIterable(["h", "dropped"]),
  ///       (a, b, c, d, e, f, g, h) => a + b + c + d + e + f + g + h)
  ///     .listen(print); //prints "abcdefgh"
  static Observable<T> zip8<A, B, C, D, E, F, G, H, T>(
          Stream<A> streamOne,
          Stream<B> streamTwo,
          Stream<C> streamThree,
          Stream<D> streamFour,
          Stream<E> streamFive,
          Stream<F> streamSix,
          Stream<G> streamSeven,
          Stream<H> streamEight,
          T zipper(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      new Observable<T>(new ZipStream<T>(<Stream<dynamic>>[
        streamOne,
        streamTwo,
        streamThree,
        streamFour,
        streamFive,
        streamSix,
        streamSeven,
        streamEight
      ], zipper));

  /// Merges the specified streams into one observable sequence using the given
  /// zipper function whenever all of the observable sequences have produced
  /// an element at a corresponding index.
  ///
  /// It applies this function in strict sequence, so the first item emitted by
  /// the new Observable will be the result of the function applied to the first
  /// item emitted by Observable #1 and the first item emitted by Observable #2;
  /// the second item emitted by the new zip-Observable will be the result of
  /// the function applied to the second item emitted by Observable #1 and the
  /// second item emitted by Observable #2; and so forth. It will only emit as
  /// many items as the number of items emitted by the source Observable that
  /// emits the fewest items.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#zip)
  ///
  /// ### Example
  ///
  ///     Observable.zip9(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.just("g"),
  ///       new Observable.just("h"),
  ///       new Observable.fromIterable(["i", "dropped"]),
  ///       (a, b, c, d, e, f, g, h, i) => a + b + c + d + e + f + g + h + i)
  ///     .listen(print); //prints "abcdefghi"
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
          T zipper(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
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
      ], zipper));

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
  /// from the source sequence, in batches of [count].
  ///
  /// If [skip] is provided, each group will start where the previous group
  /// ended minus the [skip] value.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 4).bufferWithCount(2)
  ///       .listen(print); // prints [1, 2], [3, 4]
  ///
  /// ### Example with skip
  ///
  ///     Observable.range(1, 4).bufferWithCount(2, 1)
  ///       .listen(print); // prints [1, 2], [2, 3], [3, 4], [4]
  Observable<List<T>> bufferWithCount(int count, [int skip]) =>
      transform(new BufferWithCountStreamTransformer<T, List<T>>(count, skip));

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
  ///     new Observable.just(1).call(onData: print); // Prints: 1
  Observable<T> call(
          {void onCancel(),
          void onData(T event),
          void onDone(),
          void onEach(Notification<T> notification),
          Function onError,
          void onListen(),
          void onPause(Future<dynamic> resumeSignal),
          void onResume()}) =>
      transform(new CallStreamTransformer<T>(
          onCancel: onCancel,
          onData: onData,
          onDone: onDone,
          onEach: onEach,
          onError: onError,
          onListen: onListen,
          onPause: onPause,
          onResume: onResume));

  /// Maps each emitted item to a new [Stream] using the given mapper, then
  /// subscribes to each new stream one after the next until all values are
  /// emitted.
  ///
  /// ConcatMap is similar to flatMap, but ensures order by guaranteeing that
  /// all items from the created stream will be emitted before moving to the
  /// next created stream. This process continues until all created streams have
  /// completed.
  ///
  /// ### Example
  ///
  ///   Observable.range(4, 1)
  ///     .concatMap((i) =>
  ///       new Observable.timer(i, new Duration(minutes: i))
  ///     .listen(print); // prints 4, 3, 2, 1
  Observable<S> concatMap<S>(Stream<S> mapper(T value)) =>
      transform(new ConcatMapStreamTransformer<T, S>(mapper));

  /// Returns an Observable that emits all items from the current Observable,
  /// then emits all items from the given observable, one after the next.
  ///
  /// ### Example
  ///
  ///     new Observable.timer(1, new Duration(seconds: 10))
  ///         .concatWith([new Observable.just(2)])
  ///         .listen(print); // prints 1, 2
  Observable<T> concatWith(Iterable<Stream<T>> other) => new Observable<T>(
      new ConcatStream<T>(<Stream<T>>[stream]..addAll(other)));

  @override
  Future<bool> contains(Object needle) => stream.contains(needle);

  /// Creates an Observable that will only emit items from the source sequence
  /// if a particular time span has passed without the source sequence emitting
  /// another item.
  ///
  /// The Debounce operator filters out items emitted by the source Observable
  /// that are rapidly followed by another emitted item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#debounce)
  ///
  /// ### Example
  ///
  ///     new Observable.range(1, 100).debounce(new Duration(seconds: 1))
  ///       .listen(print); // prints 100
  Observable<T> debounce(Duration duration) =>
      transform(new DebounceStreamTransformer<T>(duration));

  /// Emit items from the source Stream, or a single default item if the source
  /// Stream emits nothing.
  ///
  /// ### Example
  ///
  ///   new Observable.empty().defaultIfEmpty(10).listen(print); // prints 10
  Observable<T> defaultIfEmpty(T defaultValue) =>
      transform(new DefaultIfEmptyStreamTransformer<T>(defaultValue));

  /// Converts the onData, onDone, and onError [Notification] objects from a
  /// materialized stream into normal onData, onDone, and onError events.
  ///
  /// When a stream has been materialized, it emits onData, onDone, and onError
  /// events as [Notification] objects. Dematerialize simply reverses this by
  /// transforming [Notification] objects back to a normal stream of events.
  ///
  /// Example:
  ///     new Observable<Notification<int>>
  ///         .fromIterable([new Notification.onData(1), new Notification.onDone()])
  ///         .dematerialize()
  ///         .listen((i) => print(i)); // Prints 1
  ///
  ///     new Observable<Notification<int>>
  ///         .just(new Notification.onError(new Exception(), null))
  ///         .dematerialize()
  ///         .listen(null, onError: (e, s) { print(e) }); // Prints Exception
  Observable<S> dematerialize<S>() {
    // Since `dematerialize` can operate on any Observable<T>, we must
    // ignore the type and pass it to the streamTransformer, where it
    // will throw an Error if the stream is not a Stream<Notification<S>>

    // ignore: argument_type_not_assignable
    return transform(new DematerializeStreamTransformer<T>());
  }

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
  /// [Interactive marble diagram](http://rxmarbles.com/#distinct)
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

  /// Converts each emitted item into a new Stream using the given mapper
  /// function. The newly created Stream will be be listened to and begin
  /// emitting items downstream.
  ///
  /// The items emitted by each of the new Streams are emitted downstream in the
  /// same order they arrive. In other words, the sequences are merged
  /// together.
  ///
  /// ### Example
  ///
  ///   Observable.range(4, 1)
  ///     .flatMap((i) =>
  ///       new Observable.timer(i, new Duration(minutes: i))
  ///     .listen(print); // prints 1, 2, 3, 4
  Observable<S> flatMap<S>(Stream<S> mapper(T value)) =>
      transform(new FlatMapStreamTransformer<T, S>(mapper));

  /// Converts each emitted item into a new Stream using the given mapper
  /// function. The newly created Stream will be be listened to and begin
  /// emitting items, and any previously created Stream will stop emitting.
  ///
  /// The flatMapLatest operator is similar to the flatMap and concatMap
  /// methods, but it only emits items from the most recently created Stream.
  ///
  /// This can be useful when you only want the very latest state from
  /// asynchronous APIs, for example.
  ///
  /// ### Example
  ///
  ///   Observable.range(4, 1)
  ///     .flatMapLatest((i) =>
  ///       new Observable.timer(i, new Duration(minutes: i))
  ///     .listen(print); // prints 1
  Observable<S> flatMapLatest<S>(Stream<S> mapper(T value)) =>
      transform(new FlatMapLatestStreamTransformer<T, S>(mapper));

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
      transform(new GroupByStreamTransformer<T, S>(keySelector,
          compareKeys: compareKeys));

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

  /// Creates an Observable where all emitted items are ignored, only the
  /// error / completed notifications are passed
  ///
  /// ### Example
  ///
  ///    new Observable.merge([
  ///      new Observable.just(1),
  ///      new Observable.error(new Exception())
  ///    ])
  ///    .listen(print, onError: print); // prints Exception
  Observable<T> ignoreElements() =>
      transform(new IgnoreElementsStreamTransformer<T>());

  /// Creates an Observable that emits each item in the Stream after a given
  /// duration.
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2, 3])
  ///       .interval(new Duration(seconds: 1))
  ///       .listen((i) => print("$i sec"); // prints 1 sec, 2 sec, 3 sec
  Observable<T> interval(Duration duration) =>
      transform(new IntervalStreamTransformer<T>(duration));

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

  /// Adds a subscription to this stream. Returns a [StreamSubscription] which
  /// handles events from the stream using the provided [onData], [onError] and
  /// [onDone] handlers.
  ///
  /// The handlers can be changed on the subscription, but they start out
  /// as the provided functions.
  ///
  /// On each data event from this stream, the subscriber's [onData] handler
  /// is called. If [onData] is `null`, nothing happens.
  ///
  /// On errors from this stream, the [onError] handler is called with the
  /// error object and possibly a stack trace.
  ///
  /// The [onError] callback must be of type `void onError(error)` or
  /// `void onError(error, StackTrace stackTrace)`. If [onError] accepts
  /// two arguments it is called with the error object and the stack trace
  /// (which could be `null` if the stream itself received an error without
  /// stack trace).
  /// Otherwise it is called with just the error object.
  /// If [onError] is omitted, any errors on the stream are considered unhandled,
  /// and will be passed to the current [Zone]'s error handler.
  /// By default unhandled async errors are treated
  /// as if they were uncaught top-level errors.
  ///
  /// If this stream closes and sends a done event, the [onDone] handler is
  /// called. If [onDone] is `null`, nothing happens.
  ///
  /// If [cancelOnError] is true, the subscription is automatically cancelled
  /// when the first error event is delivered. The default is `false`.
  ///
  /// While a subscription is paused, or when it has been cancelled,
  /// the subscription doesn't receive events and none of the
  /// event handler functions are called.
  ///
  /// ### Example
  ///
  ///     new Observable.just(1).listen(print); // prints 1
  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

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

  /// Converts the onData, on Done, and onError events into [Notification]
  /// objects that are passed into the downstream onData listener.
  ///
  /// The [Notification] object contains the [Kind] of event (OnData, onDone, or
  /// OnError), and the item or error that was emitted. In the case of onDone,
  /// no data is emitted as part of the [Notification].
  ///
  /// Example:
  ///     new Observable<int>.just(1)
  ///         .materialize()
  ///         .listen((i) => print(i)); // Prints onData & onDone Notification
  ///
  ///     new Observable<int>.error(new Exception())
  ///         .materialize()
  ///         .listen((i) => print(i)); // Prints onError Notification
  Observable<Notification<T>> materialize() =>
      transform(new MaterializeStreamTransformer<T>());

  /// Creates an Observable that returns the maximum value in the source
  /// sequence according to the specified compare function.
  Observable<T> max([int compare(T a, T b)]) =>
      transform(new MaxStreamTransformer<T>(compare));

  /// Combines the items emitted by multiple streams into a single stream of
  /// items. The items are emitted in the order they are emitted by their
  /// sources.
  ///
  /// ### Example
  ///
  ///     new Observable.timer(1, new Duration(seconds: 10))
  ///         .mergeWith([new Observable.just(2)])
  ///         .listen(print); // prints 2, 1
  Observable<T> mergeWith(Iterable<Stream<T>> streams) => new Observable<T>(
      new MergeStream<T>(<Stream<T>>[stream]..addAll(streams)));

  /// Creates an Observable that returns the minimum value in the source
  /// sequence according to the specified compare function.
  Observable<T> min([int compare(T a, T b)]) =>
      transform(new MinStreamTransformer<T>(compare));

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
  /// ### Examples
  ///
  ///     new Observable.fromIterable([1, "hi"])
  ///       .ofType(new TypeToken<String>)
  ///       .listen(print); // prints "hi"
  ///
  /// As a shortcut, you can use some pre-defined constants to write the above
  /// in the following way:
  ///
  ///     new Observable.fromIterable([1, "hi"])
  ///       .ofType(kString)
  ///       .listen(print); // prints "hi"
  ///
  /// If you'd like to create your own shortcuts like the example above,
  /// simply create a constant:
  ///
  ///     const TypeToken<Map<Int, String>> kMapIntString =
  ///       const TypeToken<Map<Int, String>>();
  Observable<S> ofType<S>(TypeToken<S> typeToken) =>
      transform(new OfTypeStreamTransformer<T, S>(typeToken));

  /// Intercepts error events and switches to the given recovery stream in
  /// that case
  ///
  /// The onErrorResumeNext operator intercepts an onError notification from
  /// the source Observable. Instead of passing the error through to any
  /// listeners, it replaces it with another Stream of items.
  ///
  /// ### Example
  ///
  ///     new Observable.error(new Exception())
  ///       .onErrorResumeNext(new Observable.fromIterable([1, 2, 3]))
  ///       .listen(print); // prints 1, 2, 3
  Observable<T> onErrorResumeNext(Stream<T> recoveryStream) =>
      transform(new OnErrorResumeNextStreamTransformer<T>(recoveryStream));

  /// instructs an Observable to emit a particular item when it encounters an
  /// error, and then terminate normally
  ///
  /// The onErrorReturn operator intercepts an onError notification from
  /// the source Observable. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  ///
  /// ### Example
  ///
  ///     new Observable.error(new Exception())
  ///       .onErrorReturn(1)
  ///       .listen(print); // prints 1
  Observable<T> onErrorReturn(T returnValue) =>
      transform(new OnErrorResumeNextStreamTransformer<T>(
          new Observable<T>.just(returnValue)));

  @override
  Future<dynamic> pipe(StreamConsumer<T> streamConsumer) =>
      stream.pipe(streamConsumer);

  @override
  Future<T> reduce(T combine(T previous, T element)) => stream.reduce(combine);

  /// Creates an Observable that repeats the source's elements the specified
  /// number of times.
  ///
  /// ### Example
  ///
  ///     new Observable.just(1).repeat(3).listen(print); // prints 1, 1, 1
  Observable<T> repeat(int repeatCount) =>
      transform(new RepeatStreamTransformer<T>(repeatCount));

  /// Returns an Observable that, when the specified sample stream emits
  /// an item or completes, emits the most recently emitted item (if any)
  /// emitted by the source stream since the previous emission from
  /// the sample stream.
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2, 3])
  ///       .sample(new Observable.timer(1, new Duration(seconds: 1))
  ///       .listen(print); // prints 3
  Observable<T> sample(Stream<dynamic> sampleStream) =>
      transform(new SampleStreamTransformer<T>(sampleStream));

  /// Applies an accumulator function over an observable sequence and returns
  /// each intermediate result. The optional seed value is used as the initial
  /// accumulator value.
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2, 3])
  ///        .scan((acc, curr, i) => acc + curr, 0)
  ///        .listen(print); // prints 1, 3, 6
  Observable<S> scan<S>(S accumulator(S accumulated, T value, int index),
          [S seed]) =>
      transform(new ScanStreamTransformer<T, S>(accumulator, seed));

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

  /// Starts emitting items only after the given stream emits an item.
  ///
  /// ### Example
  ///
  ///     new Observable.merge([
  ///       new Observable.just(1),
  ///       new Observable.timer(2, new Duration(minutes: 2))
  ///     ])
  ///     .skipUntil(new Observable.timer(true, new Duration(minutes: 1)))
  ///     .listen(print); // prints 2;
  Observable<T> skipUntil<S>(Stream<S> otherStream) =>
      transform(new SkipUntilStreamTransformer<T, S>(otherStream));

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
  ///
  /// ### Example
  ///
  ///     new Observable.just(2).startWith(1).listen(print); // prints 1, 2
  Observable<T> startWith(T startValue) =>
      transform(new StartWithStreamTransformer<T>(startValue));

  /// Prepends a sequence of values to the source Observable.
  ///
  /// ### Example
  ///
  ///     new Observable.just(3).startWithMany([1, 2])
  ///       .listen(print); // prints 1, 2, 3
  Observable<T> startWithMany(List<T> startValues) =>
      transform(new StartWithManyStreamTransformer<T>(startValues));

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
  ///     // Let's pretend we have some Data sources that complete without emitting
  ///     // any items if they don't contain the data we're looking for
  ///     Observable<Data> memory;
  ///     Observable<Data> disk;
  ///     Observable<Data> network;
  ///
  ///     // Start with memory, fallback to disk, then fallback to network.
  ///     // Simple as that!
  ///     Observable<Data> getThatData =
  ///         memory.switchIfEmpty(disk).switchIfEmpty(network);
  Observable<T> switchIfEmpty(Stream<T> fallbackStream) =>
      transform(new SwitchIfEmptyStreamTransformer<T>(fallbackStream));

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
  ///
  /// new Observable.merge([
  ///     new Observable.just(1),
  ///     new Observable.timer(2, new Duration(minutes: 1))
  ///   ])
  ///   .takeUntil(new Observable.timer(3, new Duration(seconds: 10)))
  ///   .listen(print); // prints 1
  Observable<T> takeUntil<S>(Stream<S> otherStream) =>
      transform(new TakeUntilStreamTransformer<T, S>(otherStream));

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
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2, 3])
  ///       .throttle(new Duration(seconds: 1))
  ///       .listen(print); // prints 1
  Observable<T> throttle(Duration duration) =>
      transform(new ThrottleStreamTransformer<T>(duration));

  /// Records the time interval between consecutive values in an observable
  /// sequence.
  ///
  /// ### Example
  ///
  ///     new Observable.just(1)
  ///       .interval(new Duration(seconds: 1))
  ///       .timeInterval()
  ///       .listen(print); // prints TimeInterval{interval: 0:00:01, value: 1}
  Observable<TimeInterval<T>> timeInterval() =>
      transform(new TimeIntervalStreamTransformer<T, TimeInterval<T>>());

  /// The Timeout operator allows you to abort an Observable with an onError
  /// termination if that Observable fails to emit any items during a specified
  /// duration.  You may optionally provide a callback function to execute on
  /// timeout.
  @override
  Observable<T> timeout(Duration timeLimit,
          {void onTimeout(EventSink<T> sink)}) =>
      new Observable<T>(stream.timeout(timeLimit, onTimeout: onTimeout));

  /// Wraps each item emitted by the source Observable in a [Timestamped] object
  /// that includes the emitted item and the time when the item was emitted.
  ///
  /// Example
  ///
  ///     new Observable.just(1)
  ///        .timestamp()
  ///        .listen((i) => print(i)); // prints 'TimeStamp{timestamp: XXX, value: 1}';
  Observable<Timestamped<T>> timestamp() {
    return transform(new TimestampStreamTransformer<T>());
  }

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

  /// Creates an Observable where each item is a Stream containing the items
  /// from the source sequence, in batches of [count].
  ///
  /// If [skip] is provided, each group will start where the previous group
  /// ended minus the [skip] value.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 4)
  ///      .windowWithCount(3)
  ///      .flatMap((i) => i)
  ///      .listen(expectAsync1(print, count: 4)); // prints 1, 2, 3, 4
  Observable<Stream<T>> windowWithCount(int count, [int skip]) => transform(
      new WindowWithCountStreamTransformer<T, Observable<T>>(count, skip));

  /// Creates an Observable that emits when the source stream emits, combining
  /// the latest values from the two streams using the provided function.
  ///
  /// If the latestFromStream has not emitted any values, this stream will not
  /// emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2]).withLatestFrom(
  ///       new Observable.fromIterable([2, 3]), (a, b) => a + b)
  ///       .listen(print); // prints 4 (due to the async nature of streams)
  Observable<R> withLatestFrom<S, R>(
          Stream<S> latestFromStream, R fn(T t, S s)) =>
      transform(
          new WithLatestFromStreamTransformer<T, S, R>(latestFromStream, fn));

  /// Returns an Observable that combines the current stream together with
  /// another stream using a given zipper function.
  ///
  /// ### Example
  ///
  ///     new Observable.just(1)
  ///         .zipWith(new Observable.just(2), (one, two) => one + two)
  ///         .listen(print); // prints 3
  Observable<R>
      zipWith<S, R>(Stream<S> other, R zipper(T t, S s)) => new Observable<R>(
          new ZipStream<R>(<Stream<dynamic>>[stream, other], zipper));
}
