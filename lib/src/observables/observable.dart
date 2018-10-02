import 'dart:async';

import 'package:rxdart/futures.dart';
import 'package:rxdart/samplers.dart';
import 'package:rxdart/src/observables/connectable_observable.dart';
import 'package:rxdart/src/observables/replay_observable.dart';
import 'package:rxdart/src/observables/value_observable.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/transformers.dart';

/// A wrapper class that extends Stream. It combines all the Streams and
/// StreamTransformers contained in this library into a fluent api.
///
/// ### Example
///
///     new Observable(new Stream.fromIterable([1]))
///       .interval(new Duration(seconds: 1))
///       .flatMap((i) => new Observable.just(2))
///       .take(1)
///       .listen(print); // prints 2
///
/// ### Learning RxDart
///
/// This library contains documentation and examples for each method. In
/// addition, more complex examples can be found in the
/// [RxDart github repo](https://github.com/ReactiveX/rxdart) demonstrating how
/// to use RxDart with web, command line, and Flutter applications.
///
/// #### Additional Resources
///
/// In addition to the RxDart documentation and examples, you can find many
/// more articles on Dart Streams that teach the fundamentals upon which
/// RxDart is built.
///
///   - [Asynchronous Programming: Streams](https://www.dartlang.org/tutorials/language/streams)
///   - [Single-Subscription vs. Broadcast Streams](https://www.dartlang.org/articles/libraries/broadcast-streams)
///   - [Creating Streams in Dart](https://www.dartlang.org/articles/libraries/creating-streams)
///   - [Testing Streams: Stream Matchers](https://pub.dartlang.org/packages/test#stream-matchers)
///
/// ### Dart Streams vs Observables
///
/// In order to integrate fluently with the Dart ecosystem, the Observable class
/// extends the Dart `Stream` class. This provides several advantages:
///
///    - Observables work with any API that expects a Dart Stream as an input.
///    - Inherit the many methods and properties from the core Stream API.
///    - Ability to create Streams with language-level syntax.
///
/// Overall, we attempt to follow the Observable spec as closely as we can, but
/// prioritize fitting in with the Dart ecosystem when a trade-off must be made.
/// Therefore, there are some important differences to note between Dart's
/// `Stream` class and standard Rx `Observable`.
///
/// First, Cold Observables in Dart are single-subscription. In other words,
/// you can only listen to Observables once, unless it is a hot (aka broadcast)
/// Stream. If you attempt to listen to a cold stream twice, a StateError will
/// be thrown. If you need to listen to a stream multiple times, you can simply
/// create a factory function that returns a new instance of the stream.
///
/// Second, many methods contained within, such as `first` and `last` do not
/// return a `Single` nor an `Observable`, but rather must return a Dart Future.
/// Luckily, Dart Futures are easy to work with, and easily convert back to a
/// Stream using the `myFuture.asStream()` method if needed.
///
/// Third, Streams in Dart do not close by default when an error occurs. In Rx,
/// an Error causes the Observable to terminate unless it is intercepted by
/// an operator. Dart has mechanisms for creating streams that close when an
/// error occurs, but the majority of Streams do not exhibit this behavior.
///
/// Fourth, Dart streams are asynchronous by default, whereas Observables are
/// synchronous by default, unless you schedule work on a different Scheduler.
/// You can create synchronous Streams with Dart, but please be aware the the
/// default is simply different.
///
/// Finally, when using Dart Broadcast Streams (similar to Hot Observables),
/// please know that `onListen` will only be called the first time the
/// broadcast stream is listened to.
class Observable<T> extends Stream<T> {
  final Stream<T> _stream;

  Observable(Stream<T> stream) : this._stream = stream;

  /// Deprecated: please use [Observable.race].
  ///
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
  @deprecated
  factory Observable.amb(Iterable<Stream<T>> streams) =>
      new Observable<T>(new RaceStream<T>(streams));

  @override
  AsObservableFuture<bool> any(bool test(T element)) =>
      new AsObservableFuture<bool>(_stream.any(test));

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
      new Observable<T>(new CombineLatestStream<T, A, B, Null, Null, Null, Null,
              Null, Null, Null>(
          <Stream<dynamic>>[streamOne, streamTwo],
          (A a, B b,
                  [Null c, Null d, Null e, Null f, Null g, Null h, Null i]) =>
              combiner(a, b)));

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
      new Observable<T>(new CombineLatestStream<T, A, B, C, Null, Null, Null,
              Null, Null, Null>(
          <Stream<dynamic>>[streamOne, streamTwo, streamThree],
          (A a, B b, [C c, Null d, Null e, Null f, Null g, Null h, Null i]) =>
              combiner(a, b, c)));

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
      new Observable<T>(
          new CombineLatestStream<T, A, B, C, D, Null, Null, Null, Null, Null>(
              <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
              (A a, B b, [C c, D d, Null e, Null f, Null g, Null h, Null i]) =>
                  combiner(a, b, c, d)));

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
      new Observable<T>(
          new CombineLatestStream<T, A, B, C, D, E, Null, Null, Null, Null>(
              <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive
          ],
              (A a, B b, [C c, D d, E e, Null f, Null g, Null h, Null i]) =>
                  combiner(a, b, c, d, e)));

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
      new Observable<T>(
          new CombineLatestStream<T, A, B, C, D, E, F, Null, Null, Null>(
              <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix
          ],
              (A a, B b, [C c, D d, E e, F f, Null g, Null h, Null i]) =>
                  combiner(a, b, c, d, e, f)));

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
      new Observable<T>(
          new CombineLatestStream<T, A, B, C, D, E, F, G, Null, Null>(
              <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix,
            streamSeven
          ],
              (A a, B b, [C c, D d, E e, F f, G g, Null h, Null i]) =>
                  combiner(a, b, c, d, e, f, g)));

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
      new Observable<T>(
          new CombineLatestStream<T, A, B, C, D, E, F, G, H, Null>(
              <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix,
            streamSeven,
            streamEight
          ],
              (A a, B b, [C c, D d, E e, F f, G g, H h, Null i]) =>
                  combiner(a, b, c, d, e, f, g, h)));

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
      new Observable<T>(new CombineLatestStream<T, A, B, C, D, E, F, G, H, I>(
          <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix,
            streamSeven,
            streamEight,
            streamNine
          ],
          (A a, B b, [C c, D d, E e, F f, G g, H h, I i]) =>
              combiner(a, b, c, d, e, f, g, h, i)));

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
  /// By default, DeferStreams are single-subscription. However, it's possible
  /// to make them reusable.
  ///
  /// ### Example
  ///
  ///     new Observable.defer(() => new Observable.just(1))
  ///       .listen(print); //prints 1
  factory Observable.defer(Stream<T> streamFactory(), {bool reusable: false}) =>
      new Observable<T>(new DeferStream<T>(streamFactory, reusable: reusable));

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

  /// Given two or more source [streams], emit all of the items from only
  /// the first of these [streams] to emit an item or notification.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#amb)
  ///
  /// ### Example
  ///
  ///     new Observable.race([
  ///       new Observable.timer(1, new Duration(days: 1)),
  ///       new Observable.timer(2, new Duration(days: 2)),
  ///       new Observable.timer(3, new Duration(seconds: 1))
  ///     ]).listen(print); // prints 3
  factory Observable.race(Iterable<Stream<T>> streams) =>
      new Observable<T>(new RaceStream<T>(streams));

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
  /// [RetryError] will be thrown. The RetryError will contain all of the Errors
  /// and StackTraces that caused the failure.
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

  /// Creates a Stream that will recreate and re-listen to the source
  /// Stream when the notifier emits a new value. If the source Stream
  /// emits an error or it completes, the Stream terminates.
  ///
  /// If the [retryWhenFactory] emits an error a [RetryError] will be
  /// thrown. The RetryError will contain all of the [Error]s and
  /// [StackTrace]s that caused the failure.
  ///
  /// ### Basic Example
  /// ```dart
  /// new RetryWhenStream<int>(
  ///   () => new Stream<int>.fromIterable(<int>[1]),
  ///   (dynamic error, StackTrace s) => throw error,
  /// ).listen(print); // Prints 1
  /// ```
  ///
  /// ### Periodic Example
  /// ```dart
  /// new RetryWhenStream<int>(
  ///   () => new Observable<int>
  ///       .periodic(const Duration(seconds: 1), (int i) => i)
  ///       .map((int i) => i == 2 ? throw 'exception' : i),
  ///   (dynamic e, StackTrace s) {
  ///     return new Observable<String>
  ///         .timer('random value', const Duration(milliseconds: 200));
  ///   },
  /// ).take(4).listen(print); // Prints 0, 1, 0, 1
  /// ```
  ///
  /// ### Complex Example
  /// ```dart
  /// bool errorHappened = false;
  /// new RetryWhenStream(
  ///   () => new Observable
  ///       .periodic(const Duration(seconds: 1), (i) => i)
  ///       .map((i) {
  ///         if (i == 3 && !errorHappened) {
  ///           throw 'We can take this. Please restart.';
  ///         } else if (i == 4) {
  ///           throw 'It\'s enough.';
  ///         } else {
  ///           return i;
  ///         }
  ///       }),
  ///   (e, s) {
  ///     errorHappened = true;
  ///     if (e == 'We can take this. Please restart.') {
  ///       return new Observable.just('Ok. Here you go!');
  ///     } else {
  ///       return new Observable.error(e);
  ///     }
  ///   },
  /// ).listen(
  ///   print,
  ///   onError: (e, s) => print(e),
  /// ); // Prints 0, 1, 2, 0, 1, 2, 3, RetryError
  /// ```
  factory Observable.retryWhen(Stream<T> streamFactory(),
      Stream<void> retryWhenFactory(dynamic error, StackTrace stack)) {
    return new Observable<T>(
        new RetryWhenStream<T>(streamFactory, retryWhenFactory));
  }

  /// Convert a Stream that emits Streams (aka a "Higher Order Stream") into a
  /// single Observable that emits the items emitted by the
  /// most-recently-emitted of those Streams.
  ///
  /// This Observable will unsubscribe from the previously-emitted Stream when
  /// a new Stream is emitted from the source Stream and subscribe to the new
  /// Stream.
  ///
  /// ### Example
  ///
  /// ```dart
  /// final switchLatestStream = new SwitchLatestStream<String>(
  ///   new Stream.fromIterable(<Stream<String>>[
  ///     new Observable.timer('A', new Duration(seconds: 2)),
  ///     new Observable.timer('B', new Duration(seconds: 1)),
  ///     new Observable.just('C'),
  ///   ]),
  /// );
  ///
  /// // Since the first two Streams do not emit data for 1-2 seconds, and the
  /// // 3rd Stream will be emitted before that time, only data from the 3rd
  /// // Stream will be emitted to the listener.
  /// switchLatestStream.listen(print); // prints 'C'
  /// ```
  factory Observable.switchLatest(Stream<Stream<T>> streams) =>
      new Observable<T>(new SwitchLatestStream<T>(streams));

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
          new ZipStream<T, A, B, Null, Null, Null, Null, Null, Null, Null>(
              <Stream<dynamic>>[streamOne, streamTwo],
              (A a, B b,
                      [Null c,
                      Null d,
                      Null e,
                      Null f,
                      Null g,
                      Null h,
                      Null i]) =>
                  zipper(a, b)));

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
      new Observable<T>(
          new ZipStream<T, A, B, C, Null, Null, Null, Null, Null, Null>(
              <Stream<dynamic>>[streamOne, streamTwo, streamThree],
              (A a, B b,
                      [C c, Null d, Null e, Null f, Null g, Null h, Null i]) =>
                  zipper(a, b, c)));

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
      new Observable<T>(
          new ZipStream<T, A, B, C, D, Null, Null, Null, Null, Null>(
              <Stream<dynamic>>[streamOne, streamTwo, streamThree, streamFour],
              (A a, B b, [C c, D d, Null e, Null f, Null g, Null h, Null i]) =>
                  zipper(a, b, c, d)));

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
      new Observable<T>(new ZipStream<T, A, B, C, D, E, Null, Null, Null, Null>(
          <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive
          ],
          (A a, B b, [C c, D d, E e, Null f, Null g, Null h, Null i]) =>
              zipper(a, b, c, d, e)));

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
      new Observable<T>(new ZipStream<T, A, B, C, D, E, F, Null, Null, Null>(
          <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix
          ],
          (A a, B b, [C c, D d, E e, F f, Null g, Null h, Null i]) =>
              zipper(a, b, c, d, e, f)));

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
      new Observable<T>(new ZipStream<T, A, B, C, D, E, F, G, Null, Null>(
          <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix,
            streamSeven
          ],
          (A a, B b, [C c, D d, E e, F f, G g, Null h, Null i]) =>
              zipper(a, b, c, d, e, f, g)));

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
      new Observable<T>(new ZipStream<T, A, B, C, D, E, F, G, H, Null>(
          <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix,
            streamSeven,
            streamEight
          ],
          (A a, B b, [C c, D d, E e, F f, G g, H h, Null i]) =>
              zipper(a, b, c, d, e, f, g, h)));

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
      new Observable<T>(new ZipStream<T, A, B, C, D, E, F, G, H, I>(
          <Stream<dynamic>>[
            streamOne,
            streamTwo,
            streamThree,
            streamFour,
            streamFive,
            streamSix,
            streamSeven,
            streamEight,
            streamNine
          ],
          (A a, B b, [C c, D d, E e, F f, G g, H h, I i]) =>
              zipper(a, b, c, d, e, f, g, h, i)));

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
          _stream.asBroadcastStream(onListen: onListen, onCancel: onCancel));

  /// Maps each emitted item to a new [Stream] using the given mapper, then
  /// subscribes to each new stream one after the next until all values are
  /// emitted.
  ///
  /// asyncExpand is similar to flatMap, but ensures order by guaranteeing that
  /// all items from the created stream will be emitted before moving to the
  /// next created stream. This process continues until all created streams have
  /// completed.
  ///
  /// This is functionally equivalent to `concatMap`, which exists as an alias
  /// for a more fluent Rx API.
  ///
  /// ### Example
  ///
  ///     Observable.range(4, 1)
  ///       .asyncExpand((i) =>
  ///         new Observable.timer(i, new Duration(minutes: i))
  ///       .listen(print); // prints 4, 3, 2, 1
  @override
  Observable<S> asyncExpand<S>(Stream<S> mapper(T value)) =>
      new Observable<S>(_stream.asyncExpand(mapper));

  /// Creates an Observable with each data event of this stream asynchronously
  /// mapped to a new event.
  ///
  /// This acts like map, except that convert may return a Future, and in that
  /// case, the stream waits for that future to complete before continuing with
  /// its result.
  ///
  /// The returned stream is a broadcast stream if this stream is.
  @override
  Observable<S> asyncMap<S>(FutureOr<S> convert(T value)) =>
      new Observable<S>(_stream.asyncMap(convert));

  /// Creates an Observable where each item is a [List] containing the items
  /// from the source sequence, batched by the [sampler].
  ///
  /// ### Example with [onCount]
  ///
  ///     Observable.range(1, 4)
  ///       .buffer(onCount(2))
  ///       .listen(print); // prints [1, 2], [3, 4]
  ///
  /// ### Example with [onFuture]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .buffer(onFuture(() => new Future.delayed(const Duration(milliseconds: 220))))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  ///
  /// ### Example with [onTest]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .buffer(onTest((i) => i % 2 == 0))
  ///       .listen(print); // prints [0], [1, 2] [3, 4] [5, 6] ...
  ///
  /// ### Example with [onTime]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .buffer(onTime(const Duration(milliseconds: 220)))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  ///
  /// ### Example with [onStream]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .buffer(onStream(new Stream.periodic(const Duration(milliseconds: 220), (int i) => i)))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  ///
  /// You can create your own sampler by extending [StreamView]
  /// should the above samplers be insufficient for your use case.
  Observable<List<T>> buffer(SamplerBuilder<T, List<T>> sampler) =>
      transform(new BufferStreamTransformer<T>((Stream<T> stream,
              OnDataTransform<T, List<T>> bufferHandler,
              OnDataTransform<List<T>, List<T>> scheduleHandler) =>
          sampler(stream, bufferHandler, scheduleHandler)));

  /// Creates an Observable where each item is a [List] containing the items
  /// from the source sequence, in batches of [count].
  ///
  /// If [skip] is provided, each group will start where the previous group
  /// ended minus the [skip] value.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 4)
  ///       .bufferCount(2)
  ///       .listen(print); // prints [1, 2], [3, 4]
  ///
  /// ### Example with skip
  ///
  ///     Observable.range(1, 4).bufferCount(2, 1)
  ///       .listen(print); // prints [1, 2], [2, 3], [3, 4], [4]
  Observable<List<T>> bufferCount(int count, [int skip]) => transform(
      new BufferStreamTransformer<T>(onCount<T, List<T>>(count, skip)));

  /// Deprecated: Please use [bufferCount]
  ///
  /// Creates an Observable where each item is a [List] containing the items
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
  ///     Observable.range(1, 4)
  ///       .bufferWithCount(2, 1)
  ///       .listen(print); // prints [1, 2], [2, 3], [3, 4], [4]
  @deprecated
  Observable<List<T>> bufferWithCount(int count, [int skip]) => transform(
      new BufferStreamTransformer<T>(onCount<T, List<T>>(count, skip)));

  /// Creates an Observable where each item is a [List] containing the items
  /// from the source sequence, batched whenever [onFutureHandler] completes.
  ///
  /// ### Example
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .bufferFuture(() => new Future.delayed(const Duration(milliseconds: 220)))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  Observable<List<T>> bufferFuture<O>(Future<O> onFutureHandler()) => transform(
      new BufferStreamTransformer<T>(onFuture<T, List<T>, O>(onFutureHandler)));

  /// Creates an Observable where each item is a [List] containing the items
  /// from the source sequence, batched whenever [onTestHandler] passes.
  ///
  /// ### Example
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .bufferTest((i) => i % 2 == 0)
  ///       .listen(print); // prints [0], [1, 2] [3, 4] [5, 6] ...
  Observable<List<T>> bufferTest(bool onTestHandler(T event)) => transform(
      new BufferStreamTransformer<T>(onTest<T, List<T>>(onTestHandler)));

  /// Creates an Observable where each item is a [List] containing the items
  /// from the source sequence, sampled on a time frame with [duration].
  ///
  /// ### Example
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .bufferTime(const Duration(milliseconds: 220))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  Observable<List<T>> bufferTime(Duration duration) =>
      transform(new BufferStreamTransformer<T>(onTime(duration)));

  /// Creates an Observable where each item is a [List] containing the items
  /// from the source sequence, sampled on [onStream].
  ///
  /// ### Example
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .bufferWhen(new Stream.periodic(const Duration(milliseconds: 220), (int i) => i))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  Observable<List<T>> bufferWhen<O>(Stream<O> other) =>
      transform(new BufferStreamTransformer<T>(onStream(other)));

  ///
  /// Adapt this stream to be a `Stream<R>`.
  ///
  /// If this stream already has the desired type, its returned directly.
  /// Otherwise it is wrapped as a `Stream<R>` which checks at run-time that
  /// each data event emitted by this stream is also an instance of [R].
  ///
  @override
  Observable<R> cast<R>() => new Observable<R>(_stream.cast<R>());

  /// Maps each emitted item to a new [Stream] using the given mapper, then
  /// subscribes to each new stream one after the next until all values are
  /// emitted.
  ///
  /// ConcatMap is similar to flatMap, but ensures order by guaranteeing that
  /// all items from the created stream will be emitted before moving to the
  /// next created stream. This process continues until all created streams have
  /// completed.
  ///
  /// This is a simple alias for Dart Stream's `asyncExpand`, but is included to
  /// ensure a more consistent Rx API.
  ///
  /// ### Example
  ///
  ///     Observable.range(4, 1)
  ///       .concatMap((i) =>
  ///         new Observable.timer(i, new Duration(minutes: i))
  ///       .listen(print); // prints 4, 3, 2, 1
  Observable<S> concatMap<S>(Stream<S> mapper(T value)) =>
      new Observable<S>(_stream.asyncExpand(mapper));

  /// Returns an Observable that emits all items from the current Observable,
  /// then emits all items from the given observable, one after the next.
  ///
  /// ### Example
  ///
  ///     new Observable.timer(1, new Duration(seconds: 10))
  ///         .concatWith([new Observable.just(2)])
  ///         .listen(print); // prints 1, 2
  Observable<T> concatWith(Iterable<Stream<T>> other) => new Observable<T>(
      new ConcatStream<T>(<Stream<T>>[_stream]..addAll(other)));

  @override
  AsObservableFuture<bool> contains(Object needle) =>
      new AsObservableFuture<bool>(_stream.contains(needle));

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
  ///     new Observable.range(1, 100)
  ///       .debounce(new Duration(seconds: 1))
  ///       .listen(print); // prints 100
  Observable<T> debounce(Duration duration) =>
      transform(new DebounceStreamTransformer<T>(duration));

  /// Emit items from the source Stream, or a single default item if the source
  /// Stream emits nothing.
  ///
  /// ### Example
  ///
  ///     new Observable.empty().defaultIfEmpty(10).listen(print); // prints 10
  Observable<T> defaultIfEmpty(T defaultValue) =>
      transform(new DefaultIfEmptyStreamTransformer<T>(defaultValue));

  /// The Delay operator modifies its source Observable by pausing for
  /// a particular increment of time (that you specify) before emitting
  /// each of the source Observable’s items.
  /// This has the effect of shifting the entire sequence of items emitted
  /// by the Observable forward in time by that specified increment.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#delay)
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2, 3, 4])
  ///       .delay(new Duration(seconds: 1))
  ///       .listen(print); // [after one second delay] prints 1, 2, 3, 4 immediately
  Observable<T> delay(Duration duration) =>
      transform(new DelayStreamTransformer<T>(duration));

  /// Converts the onData, onDone, and onError [Notification] objects from a
  /// materialized stream into normal onData, onDone, and onError events.
  ///
  /// When a stream has been materialized, it emits onData, onDone, and onError
  /// events as [Notification] objects. Dematerialize simply reverses this by
  /// transforming [Notification] objects back to a normal stream of events.
  ///
  /// ### Example
  ///
  ///     new Observable<Notification<int>>
  ///         .fromIterable([new Notification.onData(1), new Notification.onDone()])
  ///         .dematerialize()
  ///         .listen((i) => print(i)); // Prints 1
  ///
  /// ### Error example
  ///
  ///     new Observable<Notification<int>>
  ///         .just(new Notification.onError(new Exception(), null))
  ///         .dematerialize()
  ///         .listen(null, onError: (e, s) { print(e) }); // Prints Exception
  Observable<S> dematerialize<S>() {
    return cast<Notification<S>>()
        .transform(new DematerializeStreamTransformer<S>());
  }

  /// WARNING: More commonly known as distinctUntilChanged in other Rx
  /// implementations. Creates an Observable where data events are skipped if
  /// they are equal to the previous data event.
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
  /// [Interactive marble diagram](http://rxmarbles.com/#distinctUntilChanged)
  @override
  Observable<T> distinct([bool equals(T previous, T next)]) =>
      new Observable<T>(_stream.distinct(equals));

  /// WARNING: More commonly known as distinct in other Rx implementations.
  /// Creates an Observable where data events are skipped if they have already
  /// been emitted before.
  ///
  /// Equality is determined by the provided equals and hashCode methods.
  /// If these are omitted, the '==' operator and hashCode on the last provided
  /// data element are used.
  ///
  /// The returned stream is a broadcast stream if this stream is. If a
  /// broadcast stream is listened to more than once, each subscription will
  /// individually perform the equals and hashCode tests.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#distinct)
  Observable<T> distinctUnique({bool equals(T e1, T e2), int hashCode(T e)}) =>
      transform(new DistinctUniqueStreamTransformer<T>(
          equals: equals, hashCode: hashCode));

  /// Invokes the given callback function when the stream subscription is
  /// cancelled. Often called doOnUnsubscribe or doOnDispose in other
  /// implementations.
  ///
  /// ### Example
  ///
  ///     final subscription = new Observable.timer(1, new Duration(minutes: 1))
  ///       .doOnCancel(() => print("hi"));
  ///       .listen(null);
  ///
  ///     subscription.cancel(); // prints "hi"
  Observable<T> doOnCancel(void onCancel()) =>
      transform(new DoStreamTransformer<T>(onCancel: onCancel));

  /// Invokes the given callback function when the stream emits an item. In
  /// other implementations, this is called doOnNext.
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2, 3])
  ///       .doOnData(print)
  ///       .listen(null); // prints 1, 2, 3
  Observable<T> doOnData(void onData(T event)) =>
      transform(new DoStreamTransformer<T>(onData: onData));

  /// Invokes the given callback function when the stream finishes emitting
  /// items. In other implementations, this is called doOnComplete(d).
  ///
  /// ### Example
  ///
  ///     new Observable.fromIterable([1, 2, 3])
  ///       .doOnDone(() => print("all set"))
  ///       .listen(null); // prints "all set"
  Observable<T> doOnDone(void onDone()) =>
      transform(new DoStreamTransformer<T>(onDone: onDone));

  /// Invokes the given callback function when the stream emits data, emits
  /// an error, or emits done. The callback receives a [Notification] object.
  ///
  /// The [Notification] object contains the [Kind] of event (OnData, onDone,
  /// or OnError), and the item or error that was emitted. In the case of
  /// onDone, no data is emitted as part of the [Notification].
  ///
  /// ### Example
  ///
  ///     new Observable.just(1)
  ///       .doOnEach(print)
  ///       .listen(null); // prints Notification{kind: OnData, value: 1, errorAndStackTrace: null}, Notification{kind: OnDone, value: null, errorAndStackTrace: null}
  Observable<T> doOnEach(void onEach(Notification<T> notification)) =>
      transform(new DoStreamTransformer<T>(onEach: onEach));

  /// Invokes the given callback function when the stream emits an error.
  ///
  /// ### Example
  ///
  ///     new Observable.error(new Exception())
  ///       .doOnError((error, stacktrace) => print("oh no"))
  ///       .listen(null); // prints "Oh no"
  Observable<T> doOnError(Function onError) =>
      transform(new DoStreamTransformer<T>(onError: onError));

  /// Invokes the given callback function when the stream is first listened to.
  ///
  /// ### Example
  ///
  ///     new Observable.just(1)
  ///       .doOnListen(() => print("Is someone there?"))
  ///       .listen(null); // prints "Is someone there?"
  Observable<T> doOnListen(void onListen()) =>
      transform(new DoStreamTransformer<T>(onListen: onListen));

  /// Invokes the given callback function when the stream subscription is
  /// paused.
  ///
  /// ### Example
  ///
  ///     final subscription = new Observable.just(1)
  ///       .doOnPause(() => print("Gimme a minute please"))
  ///       .listen(null);
  ///
  ///     subscription.pause(); // prints "Gimme a minute please"
  Observable<T> doOnPause(void onPause(Future<dynamic> resumeSignal)) =>
      transform(new DoStreamTransformer<T>(onPause: onPause));

  /// Invokes the given callback function when the stream subscription
  /// resumes receiving items.
  ///
  /// ### Example
  ///
  ///     final subscription = new Observable.just(1)
  ///       .doOnResume(() => print("Let's do this!"))
  ///       .listen(null);
  ///
  ///     subscription.pause();
  ///     subscription.resume(); "Let's do this!"
  Observable<T> doOnResume(void onResume()) =>
      transform(new DoStreamTransformer<T>(onResume: onResume));

  @override
  AsObservableFuture<S> drain<S>([S futureValue]) =>
      new AsObservableFuture<S>(_stream.drain(futureValue));

  @override
  AsObservableFuture<T> elementAt(int index) =>
      new AsObservableFuture<T>(_stream.elementAt(index));

  @override
  AsObservableFuture<bool> every(bool test(T element)) =>
      new AsObservableFuture<bool>(_stream.every(test));

  /// Converts items from the source stream into a new Stream using a given
  /// mapper. It ignores all items from the source stream until the new stream
  /// completes.
  ///
  /// Useful when you have a noisy source Stream and only want to respond once
  /// the previous async operation is finished.
  ///
  /// ### Example
  ///
  ///     Observable.range(0, 2).interval(new Duration(milliseconds: 50))
  ///       .exhaustMap((i) =>
  ///         new Observable.timer(i, new Duration(milliseconds: 75)))
  ///       .listen(print); // prints 0, 2
  Observable<S> exhaustMap<S>(Stream<S> mapper(T value)) =>
      transform(new ExhaustMapStreamTransformer<T, S>(mapper));

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
      new Observable<S>(_stream.expand(convert));

  @override
  AsObservableFuture<T> get first => new AsObservableFuture<T>(_stream.first);

  @override
  AsObservableFuture<T> firstWhere(bool test(T element),
          {dynamic defaultValue(), T orElse()}) =>
      new AsObservableFuture<T>(_stream.firstWhere(test, orElse: orElse));

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
  ///     Observable.range(4, 1)
  ///       .flatMap((i) =>
  ///         new Observable.timer(i, new Duration(minutes: i))
  ///       .listen(print); // prints 1, 2, 3, 4
  Observable<S> flatMap<S>(Stream<S> mapper(T value)) =>
      transform(new FlatMapStreamTransformer<T, S>(mapper));

  /// Converts each item into a new Stream. The Stream must return an
  /// Iterable. Then, each item from the Iterable will be emitted one by one.
  ///
  /// Use case: you may have an API that returns a list of items, such as
  /// a Stream<List<String>>. However, you might want to operate on the individual items
  /// rather than the list itself. This is the job of `flatMapIterable`.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 4)
  ///       .flatMapIterable((i) =>
  ///         new Observable.just([i])
  ///       .listen(print); // prints 1, 2, 3, 4
  Observable<S> flatMapIterable<S>(Stream<Iterable<S>> mapper(T value)) =>
      transform(new FlatMapStreamTransformer<T, Iterable<S>>(mapper))
          .expand((Iterable<S> iterable) => iterable);

  /// Deprecated: Please use [switchMap] instead.
  ///
  /// This is the old name of this method This Converts each emitted item into a new Stream using the given mapper
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
  ///     Observable.range(4, 1)
  ///       .flatMapLatest((i) =>
  ///         new Observable.timer(i, new Duration(minutes: i))
  ///       .listen(print); // prints 1
  @deprecated
  Observable<S> flatMapLatest<S>(Stream<S> mapper(T value)) =>
      transform(new SwitchMapStreamTransformer<T, S>(mapper));

  @override
  AsObservableFuture<S> fold<S>(
          S initialValue, S combine(S previous, T element)) =>
      new AsObservableFuture<S>(_stream.fold(initialValue, combine));

  @override
  AsObservableFuture<dynamic> forEach(void action(T element)) =>
      new AsObservableFuture<dynamic>(_stream.forEach(action));

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
      new Observable<T>(_stream.handleError(onError, test: test));

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
    return (_stream != null) ? _stream.isBroadcast : false;
  }

  @override
  AsObservableFuture<bool> get isEmpty =>
      new AsObservableFuture<bool>(_stream.isEmpty);

  @override
  AsObservableFuture<String> join([String separator = ""]) =>
      new AsObservableFuture<String>(_stream.join(separator));

  @override
  AsObservableFuture<T> get last => new AsObservableFuture<T>(_stream.last);

  @override
  AsObservableFuture<T> lastWhere(bool test(T element),
          {Object defaultValue(), T orElse()}) =>
      new AsObservableFuture<T>(_stream.lastWhere(test, orElse: orElse));

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
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  AsObservableFuture<int> get length =>
      new AsObservableFuture<int>(_stream.length);

  /// Maps values from a source sequence through a function and emits the
  /// returned values.
  ///
  /// The returned sequence completes when the source sequence completes.
  /// The returned sequence throws an error if the source sequence throws an
  /// error.
  @override
  Observable<S> map<S>(S convert(T event)) =>
      new Observable<S>(_stream.map(convert));

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

  /// Converts a Stream into a Future that completes with the largest item emitted
  /// by the Stream.
  ///
  /// This is similar to finding the max value in a list, but the values are
  /// asynchronous.
  ///
  /// ### Example
  ///
  ///     final max = await new Observable.fromIterable([1, 2, 3]).max();
  ///
  ///     print(max); // prints 3
  ///
  /// ### Example with custom [Comparator]
  ///
  ///     final observable = new Observable.fromIterable("short", "looooooong");
  ///     final max = await observable.max((a, b) => a.length - b.length);
  ///
  ///     print(max); // prints "looooooong"
  AsObservableFuture<T> max([Comparator<T> comparator]) =>
      new AsObservableFuture<T>(new StreamMaxFuture<T>(_stream, comparator));

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
      new MergeStream<T>(<Stream<T>>[_stream]..addAll(streams)));

  /// Converts a Stream into a Future that completes with the smallest item
  /// emitted by the Stream.
  ///
  /// This is similar to finding the min value in a list, but the values are
  /// asynchronous!
  ///
  /// ### Example
  ///
  ///     final min = await new Observable.fromIterable([1, 2, 3]).min();
  ///
  ///     print(min); // prints 1
  ///
  /// ### Example with custom [Comparator]
  ///
  ///     final observable = new Observable.fromIterable("short", "looooooong");
  ///     final min = await observable.min((a, b) => a.length - b.length);
  ///
  ///     print(min); // prints "short"
  AsObservableFuture<T> min([Comparator<T> comparator]) =>
      new AsObservableFuture<T>(new StreamMinFuture<T>(_stream, comparator));

  /// Filters a sequence so that only events of a given type pass
  ///
  /// In order to capture the Type correctly, it needs to be wrapped
  /// in a [TypeToken] as the generic parameter.
  ///
  /// Given the way Dart generics work, one cannot simply use the `is T` / `as T`
  /// checks and castings with this method alone. Therefore, the
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
  /// If you need to perform logic based on the type of error that was emitted,
  /// please consider using [onErrorResume].
  ///
  /// ### Example
  ///
  ///     new Observable.error(new Exception())
  ///       .onErrorResumeNext(new Observable.fromIterable([1, 2, 3]))
  ///       .listen(print); // prints 1, 2, 3
  Observable<T> onErrorResumeNext(Stream<T> recoveryStream) => transform(
      new OnErrorResumeStreamTransformer<T>((dynamic e) => recoveryStream));

  /// Intercepts error events and switches to a recovery stream created by the
  /// provided [recoveryFn].
  ///
  /// The onErrorResume operator intercepts an onError notification from
  /// the source Observable. Instead of passing the error through to any
  /// listeners, it replaces it with another Stream of items created by the
  /// [recoveryFn].
  ///
  /// The [recoveryFn] receives the emitted error and returns a Stream. You can
  /// perform logic in the [recoveryFn] to return different Streams based on the
  /// type of error that was emitted.
  ///
  /// If you do not need to perform logic based on the type of error that was
  /// emitted, please consider using [onErrorResumeNext] or [onErrorReturn].
  ///
  /// ### Example
  ///
  ///     new Observable<int>.error(new Exception())
  ///       .onErrorResume((dynamic e) =>
  ///           new Observable.just(e is StateError ? 1 : 0)
  ///       .listen(print); // prints 0
  Observable<T> onErrorResume(Stream<T> Function(dynamic error) recoveryFn) =>
      transform(new OnErrorResumeStreamTransformer<T>(recoveryFn));

  /// instructs an Observable to emit a particular item when it encounters an
  /// error, and then terminate normally
  ///
  /// The onErrorReturn operator intercepts an onError notification from
  /// the source Observable. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  ///
  /// If you need to perform logic based on the type of error that was emitted,
  /// please consider using [onErrorReturnWith].
  ///
  /// ### Example
  ///
  ///     new Observable.error(new Exception())
  ///       .onErrorReturn(1)
  ///       .listen(print); // prints 1
  Observable<T> onErrorReturn(T returnValue) =>
      transform(new OnErrorResumeStreamTransformer<T>(
          (dynamic e) => new Observable<T>.just(returnValue)));

  /// instructs an Observable to emit a particular item created by the
  /// [returnFn] when it encounters an error, and then terminate normally.
  ///
  /// The onErrorReturnWith operator intercepts an onError notification from
  /// the source Observable. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  ///
  /// The [returnFn] receives the emitted error and returns a Stream. You can
  /// perform logic in the [returnFn] to return different Streams based on the
  /// type of error that was emitted.
  ///
  /// If you do not need to perform logic based on the type of error that was
  /// emitted, please consider using [onErrorReturn].
  ///
  /// ### Example
  ///
  ///     new Observable.error(new Exception())
  ///       .onErrorReturnWith((e) => e is Exception ? 1 : 0)
  ///       .listen(print); // prints 1
  Observable<T> onErrorReturnWith(T Function(dynamic error) returnFn) =>
      transform(new OnErrorResumeStreamTransformer<T>(
          (dynamic e) => new Observable<T>.just(returnFn(e))));

  @override
  AsObservableFuture<dynamic> pipe(StreamConsumer<T> streamConsumer) =>
      new AsObservableFuture<dynamic>(_stream.pipe(streamConsumer));

  @override
  AsObservableFuture<T> reduce(T combine(T previous, T element)) =>
      new AsObservableFuture<T>(_stream.reduce(combine));

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
  AsObservableFuture<T> get single => new AsObservableFuture<T>(_stream.single);

  @override
  AsObservableFuture<T> singleWhere(bool test(T element), {T orElse()}) =>
      new AsObservableFuture<T>(_stream.singleWhere(test, orElse: orElse));

  /// Skips the first count data events from this stream.
  ///
  /// The returned stream is a broadcast stream if this stream is. For a
  /// broadcast stream, the events are only counted from the time the returned
  /// stream is listened to.
  @override
  Observable<T> skip(int count) => new Observable<T>(_stream.skip(count));

  /// Starts emitting items only after the given stream emits an item.
  ///
  /// ### Example
  ///
  ///     new Observable.merge([
  ///         new Observable.just(1),
  ///         new Observable.timer(2, new Duration(minutes: 2))
  ///       ])
  ///       .skipUntil(new Observable.timer(true, new Duration(minutes: 1)))
  ///       .listen(print); // prints 2;
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
      new Observable<T>(_stream.skipWhile(test));

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

  /// Converts each emitted item into a new Stream using the given mapper
  /// function. The newly created Stream will be be listened to and begin
  /// emitting items, and any previously created Stream will stop emitting.
  ///
  /// The switchMap operator is similar to the flatMap and concatMap methods,
  /// but it only emits items from the most recently created Stream.
  ///
  /// This can be useful when you only want the very latest state from
  /// asynchronous APIs, for example.
  ///
  /// ### Example
  ///
  ///     Observable.range(4, 1)
  ///       .switchMap((i) =>
  ///         new Observable.timer(i, new Duration(minutes: i))
  ///       .listen(print); // prints 1
  Observable<S> switchMap<S>(Stream<S> mapper(T value)) =>
      transform(new SwitchMapStreamTransformer<T, S>(mapper));

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
  Observable<T> take(int count) => new Observable<T>(_stream.take(count));

  /// Returns the values from the source observable sequence until the other
  /// observable sequence produces a value.
  ///
  /// ### Example
  ///
  ///     new Observable.merge([
  ///         new Observable.just(1),
  ///         new Observable.timer(2, new Duration(minutes: 1))
  ///       ])
  ///       .takeUntil(new Observable.timer(3, new Duration(seconds: 10)))
  ///       .listen(print); // prints 1
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
      new Observable<T>(_stream.takeWhile(test));

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
      transform(new TimeIntervalStreamTransformer<T>());

  /// The Timeout operator allows you to abort an Observable with an onError
  /// termination if that Observable fails to emit any items during a specified
  /// duration.  You may optionally provide a callback function to execute on
  /// timeout.
  @override
  Observable<T> timeout(Duration timeLimit,
          {void onTimeout(EventSink<T> sink)}) =>
      new Observable<T>(_stream.timeout(timeLimit, onTimeout: onTimeout));

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
  AsObservableFuture<List<T>> toList() =>
      new AsObservableFuture<List<T>>(_stream.toList());

  @override
  AsObservableFuture<Set<T>> toSet() =>
      new AsObservableFuture<Set<T>>(_stream.toSet());

  /// Filters the elements of an observable sequence based on the test.
  @override
  Observable<T> where(bool test(T event)) =>
      new Observable<T>(_stream.where(test));

  /// Creates an Observable where each item is a [Stream] containing the items
  /// from the source sequence, batched by the [sampler].
  ///
  /// ### Example with [onCount]
  ///
  ///     Observable.range(1, 4)
  ///       .window(onCount(2))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 1, 2, next window 3, 4
  ///
  /// ### Example with [onFuture]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .window(onFuture(() => new Future.delayed(const Duration(milliseconds: 220))))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
  ///
  /// ### Example with [onTest]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .window(onTest((i) => i % 2 == 0))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, next window 1, 2 next window 3, 4,  ...
  ///
  /// ### Example with [onTime]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .window(onTime(const Duration(milliseconds: 220)))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
  ///
  /// ### Example with [onStream]
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .window(onStream(new Stream.periodic(const Duration(milliseconds: 220), (int i) => i)))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
  ///
  /// You can create your own sampler by extending [StreamView]
  /// should the above samplers be insufficient for your use case.
  Observable<Stream<T>> window(SamplerBuilder<T, Stream<T>> sampler) =>
      transform(new WindowStreamTransformer<T>((Stream<T> stream,
              OnDataTransform<T, Stream<T>> bufferHandler,
              OnDataTransform<Stream<T>, Stream<T>> scheduleHandler) =>
          sampler(stream, bufferHandler, scheduleHandler)));

  /// Creates an Observable where each item is a [Stream] containing the items
  /// from the source sequence, in batches of [count].
  ///
  /// If [skip] is provided, each group will start where the previous group
  /// ended minus the [skip] value.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 4)
  ///       .windowCount(2)
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 1, 2, next window 3, 4
  ///
  /// ### Example with skip
  ///
  ///     Observable.range(1, 4)
  ///       .windowCount(2, 1)
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 1, 2, next window 2, 3, next window 3, 4, next window 4
  Observable<Stream<T>> windowCount(int count, [int skip]) =>
      transform(new WindowStreamTransformer<T>(onCount(count, skip)));

  /// Deprecated: Please use [windowCount]
  ///
  /// Creates an Observable where each item is a [Stream] containing the items
  /// from the source sequence, in batches of [count].
  ///
  /// If [skip] is provided, each group will start where the previous group
  /// ended minus the [skip] value.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 4)
  ///       .windowCount(2)
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 1, 2, next window 3, 4
  ///
  /// ### Example with skip
  ///
  ///     Observable.range(1, 4)
  ///       .windowCount(2, 1)
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 1, 2, next window 2, 3, next window 3, 4, next window 4
  @deprecated
  Observable<Stream<T>> windowWithCount(int count, [int skip]) =>
      transform(new WindowStreamTransformer<T>(onCount(count, skip)));

  /// Creates an Observable where each item is a [Stream] containing the items
  /// from the source sequence, batched whenever [onFutureHandler] completes.
  ///
  /// ### Example
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .windowFuture(() => new Future.delayed(const Duration(milliseconds: 220)))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
  Observable<Stream<T>> windowFuture<O>(Future<O> onFutureHandler()) =>
      transform(new WindowStreamTransformer<T>(onFuture(onFutureHandler)));

  /// Creates an Observable where each item is a [Stream] containing the items
  /// from the source sequence, batched whenever [onTestHandler] passes.
  ///
  /// ### Example
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .windowTest((i) => i % 2 == 0)
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, next window 1, 2 next window 3, 4,  ...
  Observable<Stream<T>> windowTest(bool onTestHandler(T event)) =>
      transform(new WindowStreamTransformer<T>(onTest(onTestHandler)));

  /// Creates an Observable where each item is a [Stream] containing the items
  /// from the source sequence, sampled on a time frame with [duration].
  ///
  /// ### Example
  ///
  ////     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .windowTime(const Duration(milliseconds: 220))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
  Observable<Stream<T>> windowTime(Duration duration) =>
      transform(new WindowStreamTransformer<T>(onTime(duration)));

  /// Creates an Observable where each item is a [Stream] containing the items
  /// from the source sequence, sampled on [onStream].
  ///
  /// ### Example
  ///
  ///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
  ///       .windowWhen(new Stream.periodic(const Duration(milliseconds: 220), (int i) => i))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
  Observable<Stream<T>> windowWhen<O>(Stream<O> other) =>
      transform(new WindowStreamTransformer<T>(onStream(other)));

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
  Observable<R> zipWith<S, R>(Stream<S> other, R zipper(T t, S s)) =>
      new Observable<R>(
          new ZipStream<R, T, S, Null, Null, Null, Null, Null, Null, Null>(
              <Stream<dynamic>>[_stream, other],
              (
                      [T a,
                      S b,
                      Null c,
                      Null d,
                      Null e,
                      Null f,
                      Null g,
                      Null h,
                      Null i]) =>
                  zipper(a, b)));

  /// Convert the current Observable into a [ConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publish();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // Subject
  /// subscription.cancel();
  /// ```
  ConnectableObservable<T> publish() => PublishConnectableObservable<T>(this);

  /// Convert the current Observable into a [ValueConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValue();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the last emitted value
  /// connectable.listen(print); // Prints 3
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject
  /// subscription.cancel();
  /// ```
  ValueConnectableObservable<T> publishValue({T seedValue}) =>
      ValueConnectableObservable<T>(this, seedValue: seedValue);

  /// Convert the current Observable into a [ReplayConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays a given number of items to any new
  /// listener. It also provides access to the emitted values synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishReplay();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the emitted value, up to a specified
  /// // maxSize
  /// connectable.listen(print); // Prints 1, 2, 3
  ///
  /// // Can access a list of the emitted values synchronously. Prints [1, 2, 3]
  /// print(connectable.values);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ReplaySubject
  /// subscription.cancel();
  /// ```
  ReplayConnectableObservable<T> publishReplay({int maxSize}) =>
      ReplayConnectableObservable<T>(this, maxSize: maxSize);

  /// Convert the current Observable into a new Observable that can be listened
  /// to multiple times. It will automatically begin emitting items when first
  /// listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream
  /// final observable = Observable.fromIterable([1, 2, 3]).share();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // PublishSubject
  /// subscription.cancel();
  /// ```
  Observable<T> share() => publish().refCount();

  /// Convert the current Observable into a new [ValueObservable] that can
  /// be listened to multiple times. It will automatically begin emitting items
  /// when first listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// It will replay the latest emitted value to any new listener.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final observable = Observable.fromIterable([1, 2, 3]).shareValue();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(observable.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueObservable<T> shareValue({T seedValue}) =>
      publishValue(seedValue: seedValue).refCount();

  /// Convert the current Observable into a new [ReplayObservable] that can
  /// be listened to multiple times. It will automatically begin emitting items
  /// when first listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for gaining access to the l
  ///
  /// It will replay the emitted values to any new listener, up to a given
  /// [maxSize].
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final observable = Observable.fromIterable([1, 2, 3]).shareReplay();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the emitted values up to a given maxSize
  /// // Prints [1, 2, 3]
  /// print(observable.values);
  ///
  /// // Subscribe again later. This will print 1, 2, 3 because it receives the
  /// // last emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ReplaySubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ReplayObservable<T> shareReplay({int maxSize}) =>
      publishReplay(maxSize: maxSize).refCount();
}
