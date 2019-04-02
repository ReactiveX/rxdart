import 'dart:async';

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
/// ### Basic Example
///
/// This constructor takes in an `Iterable<Stream<T>>` and outputs a
/// `Stream<Iterable<T>>` whenever any of the values change from the source
/// stream. This is useful with a dynamic number of source streams!
///
///     ForkJoinStream.list<String>([
///       Stream.fromIterable(["a"]),
///       Stream.fromIterable(["b"]),
///       Stream.fromIterable(["C", "D"])])
///     .listen(print); //prints ['a', 'b', 'D']
///
/// ### Example with combiner
///
/// If you wish to combine the list of values into a new object before you
///
///     CombineLatestStream(
///       [
///         Stream.fromIterable(["a"]),
///         Stream.fromIterable(["b"]),
///         Stream.fromIterable(["C", "D"])
///       ],
///       (values) => values.last
///     )
///     .listen(print); //prints 'D'
///
/// ### Example with a specific number of Streams
///
/// If you wish to combine a specific number of Streams together with proper
/// types information for the value of each Stream, use the
/// [combine2] - [combine9] operators.
///
///     ForkJoinStream.combine2(
///       Stream.fromIterable([1]),
///       Stream.fromIterable([2, 3]),
///       (a, b) => a + b,
///     )
///     .listen(print); // prints 4
class ForkJoinStream<T, R> extends StreamView<R> {
  ForkJoinStream(
    Iterable<Stream<T>> streams,
    R combiner(List<T> values),
  )   : assert(streams != null && streams.every((s) => s != null),
            'streams cannot be null'),
        assert(streams.isNotEmpty, 'provide at least 1 stream'),
        assert(combiner != null, 'must provide a combiner function'),
        super(_buildController(streams, combiner).stream);

  static ForkJoinStream<T, List<T>> list<T>(
    Iterable<Stream<T>> streams,
  ) =>
      ForkJoinStream<T, List<T>>(
        streams,
        (List<T> values) => values,
      );

  static ForkJoinStream<dynamic, R> combine2<A, B, R>(
    Stream<A> streamOne,
    Stream<B> streamTwo,
    R combiner(A a, B b),
  ) =>
      ForkJoinStream<dynamic, R>(
        [streamOne, streamTwo],
        (List<dynamic> values) => combiner(values[0] as A, values[1] as B),
      );

  static ForkJoinStream<dynamic, R> combine3<A, B, C, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    R combiner(A a, B b, C c),
  ) =>
      ForkJoinStream<dynamic, R>(
        [streamA, streamB, streamC],
        (List<dynamic> values) {
          return combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
          );
        },
      );

  static ForkJoinStream<dynamic, R> combine4<A, B, C, D, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    R combiner(A a, B b, C c, D d),
  ) =>
      ForkJoinStream<dynamic, R>(
        [streamA, streamB, streamC, streamD],
        (List<dynamic> values) {
          return combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
          );
        },
      );

  static ForkJoinStream<dynamic, R> combine5<A, B, C, D, E, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    R combiner(A a, B b, C c, D d, E e),
  ) =>
      ForkJoinStream<dynamic, R>(
        [streamA, streamB, streamC, streamD, streamE],
        (List<dynamic> values) {
          return combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
          );
        },
      );

  static ForkJoinStream<dynamic, R> combine6<A, B, C, D, E, F, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    R combiner(A a, B b, C c, D d, E e, F f),
  ) =>
      ForkJoinStream<dynamic, R>(
        [streamA, streamB, streamC, streamD, streamE, streamF],
        (List<dynamic> values) {
          return combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
          );
        },
      );

  static ForkJoinStream<dynamic, R> combine7<A, B, C, D, E, F, G, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    R combiner(A a, B b, C c, D d, E e, F f, G g),
  ) =>
      ForkJoinStream<dynamic, R>(
        [streamA, streamB, streamC, streamD, streamE, streamF, streamG],
        (List<dynamic> values) {
          return combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
            values[6] as G,
          );
        },
      );

  static ForkJoinStream<dynamic, R> combine8<A, B, C, D, E, F, G, H, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    Stream<H> streamH,
    R combiner(A a, B b, C c, D d, E e, F f, G g, H h),
  ) =>
      ForkJoinStream<dynamic, R>(
        [
          streamA,
          streamB,
          streamC,
          streamD,
          streamE,
          streamF,
          streamG,
          streamH
        ],
        (List<dynamic> values) {
          return combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
            values[6] as G,
            values[7] as H,
          );
        },
      );

  static ForkJoinStream<dynamic, R> combine9<A, B, C, D, E, F, G, H, I, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    Stream<H> streamH,
    Stream<I> streamI,
    R combiner(A a, B b, C c, D d, E e, F f, G g, H h, I i),
  ) =>
      ForkJoinStream<dynamic, R>(
        [
          streamA,
          streamB,
          streamC,
          streamD,
          streamE,
          streamF,
          streamG,
          streamH,
          streamI
        ],
        (List<dynamic> values) {
          return combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
            values[6] as G,
            values[7] as H,
            values[8] as I,
          );
        },
      );

  static StreamController<R> _buildController<T, R>(
    Iterable<Stream<T>> streams,
    R combiner(List<T> values),
  ) {
    StreamController<R> controller;

    controller = StreamController<R>(
        sync: true,
        onListen: () {
          final onDone = (List<T> values) {
            try {
              controller.add(combiner(values));
            } catch (e, s) {
              controller.addError(e, s);
            }

            controller.close();
          };
          Future.wait(streams.map((stream) => stream.last),
                  eagerError: true, cleanUp: (dynamic _) => controller.close())
              .then(onDone, onError: controller.addError);
        });

    return controller;
  }
}
