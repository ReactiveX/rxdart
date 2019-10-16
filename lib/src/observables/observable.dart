import 'dart:async';

import 'package:rxdart/streams.dart';

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

  /// Constructs an [Observable], exposing rx methods which can be
  /// invoked to transform the wrapped [Stream].
  Observable(Stream<T> stream) : this._stream = stream;

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an item.
  /// This is helpful when you need to combine a dynamic number of Streams.
  ///
  /// The Observable will not emit any lists of values until all of the source
  /// streams have emitted at least one value.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///    Observable.combineLatest([
  ///      new Observable.just("a"),
  ///      new Observable.fromIterable(["b", "c", "d"])
  ///    ], (list) => list.join())
  ///    .listen(print); // prints "ab", "ac", "ad"
  static Observable<R> combineLatest<T, R>(
          Iterable<Stream<T>> streams, R combiner(List<T> values)) =>
      Observable<R>(CombineLatestStream<T, R>(streams, combiner));

  /// Merges the given Streams into one Observable that emits a List of the
  /// values emitted by the source Stream. This is helpful when you need to
  /// combine a dynamic number of Streams.
  ///
  /// The Observable will not emit any lists of values until all of the source
  /// streams have emitted at least one value.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     Observable.combineLatestList([
  ///       Observable.just(1),
  ///       Observable.fromIterable([0, 1, 2]),
  ///     ])
  ///     .listen(print); // prints [1, 0], [1, 1], [1, 2]
  static Observable<List<T>> combineLatestList<T>(
          Iterable<Stream<T>> streams) =>
      Observable<List<T>>(CombineLatestStream.list<T>(streams));

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
          Stream<A> streamA, Stream<B> streamB, T combiner(A a, B b)) =>
      Observable<T>(CombineLatestStream.combine2(streamA, streamB, combiner));

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
  static Observable<T> combineLatest3<A, B, C, T>(Stream<A> streamA,
          Stream<B> streamB, Stream<C> streamC, T combiner(A a, B b, C c)) =>
      Observable<T>(
          CombineLatestStream.combine3(streamA, streamB, streamC, combiner));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          T combiner(A a, B b, C c, D d)) =>
      Observable<T>(CombineLatestStream.combine4(
          streamA, streamB, streamC, streamD, combiner));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          T combiner(A a, B b, C c, D d, E e)) =>
      Observable<T>(CombineLatestStream.combine5(
          streamA, streamB, streamC, streamD, streamE, combiner));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          T combiner(A a, B b, C c, D d, E e, F f)) =>
      Observable<T>(CombineLatestStream.combine6(
          streamA, streamB, streamC, streamD, streamE, streamF, combiner));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          T combiner(A a, B b, C c, D d, E e, F f, G g)) =>
      Observable<T>(CombineLatestStream.combine7(streamA, streamB, streamC,
          streamD, streamE, streamF, streamG, combiner));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          Stream<H> streamH,
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      Observable<T>(
        CombineLatestStream.combine8(
          streamA,
          streamB,
          streamC,
          streamD,
          streamE,
          streamF,
          streamG,
          streamH,
          combiner,
        ),
      );

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          Stream<H> streamH,
          Stream<I> streamI,
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
      Observable<T>(
        CombineLatestStream.combine9(
          streamA,
          streamB,
          streamC,
          streamD,
          streamE,
          streamF,
          streamG,
          streamH,
          streamI,
          combiner,
        ),
      );

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
      Observable<T>(ConcatStream<T>(streams));

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
      Observable<T>(ConcatEagerStream<T>(streams));

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
  factory Observable.defer(Stream<T> streamFactory(),
          {bool reusable = false}) =>
      Observable<T>(DeferStream<T>(streamFactory, reusable: reusable));

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
      Observable<T>(ErrorStream<T>(error));

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
      Observable<T>((Stream<T>.eventTransformed(source, mapSink)));

  ///  Creates an [Observable] where all last events of existing stream(s) are piped
  ///  through a sink-transformation.
  ///
  /// This operator is best used when you have a group of observables
  /// and only care about the final emitted value of each.
  /// One common use case for this is if you wish to issue multiple
  /// requests on page load (or some other event)
  /// and only want to take action when a response has been received for all.
  ///
  /// In this way it is similar to how you might use [Future].wait.
  ///
  /// Be aware that if any of the inner observables supplied to forkJoin error
  /// you will lose the value of any other observables that would or have already
  /// completed if you do not catch the error correctly on the inner observable.
  ///
  /// If you are only concerned with all inner observables completing
  /// successfully you can catch the error on the outside.
  /// It's also worth noting that if you have an observable
  /// that emits more than one item, and you are concerned with the previous
  /// emissions forkJoin is not the correct choice.
  ///
  /// In these cases you may better off with an operator like combineLatest or zip.
  ///
  /// ### Example
  ///
  ///    Observable.forkJoin([
  ///      new Observable.just("a"),
  ///      new Observable.fromIterable(["b", "c", "d"])
  ///    ], (list) => list.join(', '))
  ///    .listen(print); // prints "a, d"
  static Observable<R> forkJoin<T, R>(
          Iterable<Stream<T>> streams, R combiner(List<T> values)) =>
      Observable<R>(ForkJoinStream<T, R>(streams, combiner));

  /// Merges the given Streams into one Observable that emits a List of the
  /// last values emitted by the source stream(s). This is helpful when you need to
  /// forkJoin a dynamic number of Streams.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoinList([
  ///       Observable.just(1),
  ///       Observable.fromIterable([0, 1, 2]),
  ///     ])
  ///     .listen(print); // prints [1, 2]
  static Observable<List<T>> forkJoinList<T>(Iterable<Stream<T>> streams) =>
      Observable<List<T>>(ForkJoinStream.list<T>(streams));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin2(
  ///       new Observable.just(1),
  ///       new Observable.fromIterable([0, 1, 2]),
  ///       (a, b) => a + b)
  ///     .listen(print); //prints 3
  static Observable<T> forkJoin2<A, B, T>(
          Stream<A> streamA, Stream<B> streamB, T combiner(A a, B b)) =>
      Observable<T>(ForkJoinStream.combine2(streamA, streamB, combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin3(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.fromIterable(["c", "d"]),
  ///       (a, b, c) => a + b + c)
  ///     .listen(print); //prints "abd"
  static Observable<T> forkJoin3<A, B, C, T>(Stream<A> streamA,
          Stream<B> streamB, Stream<C> streamC, T combiner(A a, B b, C c)) =>
      Observable<T>(
          ForkJoinStream.combine3(streamA, streamB, streamC, combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin4(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.fromIterable(["d", "e"]),
  ///       (a, b, c, d) => a + b + c + d)
  ///     .listen(print); //prints "abce"
  static Observable<T> forkJoin4<A, B, C, D, T>(
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          T combiner(A a, B b, C c, D d)) =>
      Observable<T>(ForkJoinStream.combine4(
          streamA, streamB, streamC, streamD, combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin5(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.fromIterable(["e", "f"]),
  ///       (a, b, c, d, e) => a + b + c + d + e)
  ///     .listen(print); //prints "abcdf"
  static Observable<T> forkJoin5<A, B, C, D, E, T>(
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          T combiner(A a, B b, C c, D d, E e)) =>
      Observable<T>(ForkJoinStream.combine5(
          streamA, streamB, streamC, streamD, streamE, combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin6(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.fromIterable(["f", "g"]),
  ///       (a, b, c, d, e, f) => a + b + c + d + e + f)
  ///     .listen(print); //prints "abcdeg"
  static Observable<T> forkJoin6<A, B, C, D, E, F, T>(
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          T combiner(A a, B b, C c, D d, E e, F f)) =>
      Observable<T>(ForkJoinStream.combine6(
          streamA, streamB, streamC, streamD, streamE, streamF, combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin7(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.fromIterable(["g", "h"]),
  ///       (a, b, c, d, e, f, g) => a + b + c + d + e + f + g)
  ///     .listen(print); //prints "abcdefh"
  static Observable<T> forkJoin7<A, B, C, D, E, F, G, T>(
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          T combiner(A a, B b, C c, D d, E e, F f, G g)) =>
      Observable<T>(ForkJoinStream.combine7(streamA, streamB, streamC, streamD,
          streamE, streamF, streamG, combiner));

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin8(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.just("g"),
  ///       new Observable.fromIterable(["h", "i"]),
  ///       (a, b, c, d, e, f, g, h) => a + b + c + d + e + f + g + h)
  ///     .listen(print); //prints "abcdefgi"
  static Observable<T> forkJoin8<A, B, C, D, E, F, G, H, T>(
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          Stream<H> streamH,
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      Observable<T>(
        ForkJoinStream.combine8(
          streamA,
          streamB,
          streamC,
          streamD,
          streamE,
          streamF,
          streamG,
          streamH,
          combiner,
        ),
      );

  /// Merges the given Streams into one Observable sequence by using the
  /// [combiner] function when all of the observable sequences emits their
  /// last item.
  ///
  /// ### Example
  ///
  ///     Observable.forkJoin9(
  ///       new Observable.just("a"),
  ///       new Observable.just("b"),
  ///       new Observable.just("c"),
  ///       new Observable.just("d"),
  ///       new Observable.just("e"),
  ///       new Observable.just("f"),
  ///       new Observable.just("g"),
  ///       new Observable.just("h"),
  ///       new Observable.fromIterable(["i", "j"]),
  ///       (a, b, c, d, e, f, g, h, i) => a + b + c + d + e + f + g + h + i)
  ///     .listen(print); //prints "abcdefghj"
  static Observable<T> forkJoin9<A, B, C, D, E, F, G, H, I, T>(
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          Stream<H> streamH,
          Stream<I> streamI,
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
      Observable<T>(
        ForkJoinStream.combine9(
          streamA,
          streamB,
          streamC,
          streamD,
          streamE,
          streamF,
          streamG,
          streamH,
          streamI,
          combiner,
        ),
      );

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
      Observable<T>((Stream<T>.fromFuture(future)));

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
      Observable<T>((Stream<T>.fromIterable(data)));

  /// Creates an Observable that contains a single value
  ///
  /// The value is emitted when the stream receives a listener.
  ///
  /// ### Example
  ///
  ///      new Observable.just(1).listen(print); // prints 1
  factory Observable.just(T data) =>
      Observable<T>((Stream<T>.fromIterable(<T>[data])));

  /// Creates an Observable that contains no values.
  ///
  /// No items are emitted from the stream, and done is called upon listening.
  ///
  /// ### Example
  ///
  ///     new Observable.empty().listen(
  ///       (_) => print("data"), onDone: () => print("done")); // prints "done"
  factory Observable.empty() => Observable<T>((Stream<T>.empty()));

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
      Observable<T>(MergeStream<T>(streams));

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
  factory Observable.never() => Observable<T>(NeverStream<T>());

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
      Observable<T>((Stream<T>.periodic(period, computation)));

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
      Observable<T>(RaceStream<T>(streams));

  /// Returns an Observable that emits a sequence of Integers within a specified
  /// range.
  ///
  /// ### Example
  ///
  ///     Observable.range(1, 3).listen((i) => print(i)); // Prints 1, 2, 3
  ///
  ///     Observable.range(3, 1).listen((i) => print(i)); // Prints 3, 2, 1
  static Observable<int> range(int startInclusive, int endInclusive) =>
      Observable<int>(RangeStream(startInclusive, endInclusive));

  /// Creates a [Stream] that will recreate and re-listen to the source
  /// Stream the specified number of times until the [Stream] terminates
  /// successfully.
  ///
  /// If [count] is not specified, it repeats indefinitely.
  ///
  /// ### Example
  ///
  ///     new RepeatStream((int repeatCount) =>
  ///       Observable.just('repeat index: $repeatCount'), 3)
  ///         .listen((i) => print(i)); // Prints 'repeat index: 0, repeat index: 1, repeat index: 2'
  factory Observable.repeat(Stream<T> streamFactory(int repeatIndex),
          [int count]) =>
      Observable(RepeatStream<T>(streamFactory, count));

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
    return Observable<T>(RetryStream<T>(streamFactory, count));
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
          Stream<void> retryWhenFactory(dynamic error, StackTrace stack)) =>
      Observable<T>(RetryWhenStream<T>(streamFactory, retryWhenFactory));

  /// Determine whether two Observables emit the same sequence of items.
  /// You can provide an optional [equals] handler to determine equality.
  ///
  /// [Interactive marble diagram](https://rxmarbles.com/#sequenceEqual)
  ///
  /// ### Example
  ///
  ///     Observable.sequenceEqual([
  ///       Stream.fromIterable([1, 2, 3, 4, 5]),
  ///       Stream.fromIterable([1, 2, 3, 4, 5])
  ///     ])
  ///     .listen(print); // prints true
  static Observable<bool> sequenceEqual<A, B>(Stream<A> stream, Stream<B> other,
          {bool equals(A a, B b)}) =>
      Observable(SequenceEqualStream<A, B>(stream, other, equals: equals));

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
      Observable<T>(SwitchLatestStream<T>(streams));

  /// Emits the given value after a specified amount of time.
  ///
  /// ### Example
  ///
  ///     new Observable.timer("hi", new Duration(minutes: 1))
  ///         .listen((i) => print(i)); // print "hi" after 1 minute
  factory Observable.timer(T value, Duration duration) =>
      Observable<T>((TimerStream<T>(value, duration)));

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
          Stream<A> streamA, Stream<B> streamB, T zipper(A a, B b)) =>
      Observable<T>(ZipStream.zip2(streamA, streamB, zipper));

  /// Merges the iterable streams into one observable sequence using the given
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
  ///     Observable.zip(
  ///       [
  ///         Observable.just("Hi "),
  ///         Observable.fromIterable(["Friend", "Dropped"]),
  ///       ],
  ///       (values) => values.first + values.last
  ///     )
  ///     .listen(print); // prints "Hi Friend"
  static Observable<R> zip<T, R>(
          Iterable<Stream<T>> streams, R zipper(List<T> values)) =>
      Observable<R>(ZipStream(streams, zipper));

  /// Merges the iterable streams into one observable sequence using the given
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
  ///     Observable.zipList(
  ///       [
  ///         Observable.just("Hi "),
  ///         Observable.fromIterable(["Friend", "Dropped"]),
  ///       ],
  ///     )
  ///     .listen(print); // prints ['Hi ', 'Friend']
  static Observable<List<T>> zipList<T>(Iterable<Stream<T>> streams) =>
      Observable<List<T>>(ZipStream.list(streams));

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
  static Observable<T> zip3<A, B, C, T>(Stream<A> streamA, Stream<B> streamB,
          Stream<C> streamC, T zipper(A a, B b, C c)) =>
      Observable<T>(ZipStream.zip3(streamA, streamB, streamC, zipper));

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
  static Observable<T> zip4<A, B, C, D, T>(Stream<A> streamA, Stream<B> streamB,
          Stream<C> streamC, Stream<D> streamD, T zipper(A a, B b, C c, D d)) =>
      Observable<T>(ZipStream.zip4(streamA, streamB, streamC, streamD, zipper));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          T zipper(A a, B b, C c, D d, E e)) =>
      Observable<T>(
          ZipStream.zip5(streamA, streamB, streamC, streamD, streamE, zipper));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          T zipper(A a, B b, C c, D d, E e, F f)) =>
      Observable<T>(ZipStream.zip6(
        streamA,
        streamB,
        streamC,
        streamD,
        streamE,
        streamF,
        zipper,
      ));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          T zipper(A a, B b, C c, D d, E e, F f, G g)) =>
      Observable<T>(ZipStream.zip7(
        streamA,
        streamB,
        streamC,
        streamD,
        streamE,
        streamF,
        streamG,
        zipper,
      ));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          Stream<H> streamH,
          T zipper(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      Observable<T>(ZipStream.zip8(
        streamA,
        streamB,
        streamC,
        streamD,
        streamE,
        streamF,
        streamG,
        streamH,
        zipper,
      ));

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
          Stream<A> streamA,
          Stream<B> streamB,
          Stream<C> streamC,
          Stream<D> streamD,
          Stream<E> streamE,
          Stream<F> streamF,
          Stream<G> streamG,
          Stream<H> streamH,
          Stream<I> streamI,
          T zipper(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
      Observable<T>(ZipStream.zip9(
        streamA,
        streamB,
        streamC,
        streamD,
        streamE,
        streamF,
        streamG,
        streamH,
        streamI,
        zipper,
      ));

  @override
  bool get isBroadcast {
    return (_stream != null) ? _stream.isBroadcast : false;
  }

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
}
