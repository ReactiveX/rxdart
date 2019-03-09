import 'dart:async';

/// Merges the given Streams into one Stream sequence by using the
/// combiner function whenever any of the source stream sequences emits an
/// item.
///
/// The Stream will not emit until all Streams have emitted at least one
/// item.
///
/// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
///
/// ### Basic Example
///
/// This constructor takes in an `Iterable<Stream<T>>` and outputs a
/// `Stream<Iterable<T>>` whenever any of the values change from the source
/// stream. This is useful with a dynamic number of source streams!
///
///     CombineLatestStream.list<String>([
///       Stream.fromIterable(["a"]),
///       Stream.fromIterable(["b"]),
///       Stream.fromIterable(["C", "D"])])
///     .listen(print); //prints ['a', 'b', 'C'], ['a', 'b', 'D']
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
///     .listen(print); //prints 'C', 'D'
///
/// ### Example with a specific number of Streams
///
/// If you wish to combine a specific number of Streams together with proper
/// types information for the value of each Stream, use the
/// [combine2] - [combine9] operators.
///
///     CombineLatestStream.combine2(
///       Stream.fromIterable(1),
///       Stream.fromIterable([2, 3]),
///       (a, b) => a + b,
///     )
///     .listen(print); // prints 3, 4
class CombineLatestStream<T, R> extends StreamView<R> {
  CombineLatestStream(
    Iterable<Stream<T>> streams,
    R combiner(List<T> values),
  )   : assert(streams != null && streams.every((s) => s != null),
            'streams cannot be null'),
        assert(streams.length > 1, 'provide at least 2 streams'),
        assert(combiner != null, 'must provide a combiner function'),
        super(_buildController(streams, combiner).stream);

  static CombineLatestStream<T, List<T>> list<T>(
    Iterable<Stream<T>> streams,
  ) {
    return CombineLatestStream<T, List<T>>(
      streams,
      (values) => values,
    );
  }

  static CombineLatestStream<dynamic, R> combine2<A, B, R>(
    Stream<A> streamOne,
    Stream<B> streamTwo,
    R combiner(A a, B b),
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamOne, streamTwo],
      (values) => combiner(values[0] as A, values[1] as B),
    );
  }

  static CombineLatestStream<dynamic, R> combine3<A, B, C, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    R combiner(A a, B b, C c),
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC],
      (values) => combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
          ),
    );
  }

  static CombineLatestStream<dynamic, R> combine4<A, B, C, D, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    R combiner(A a, B b, C c, D d),
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC, streamD],
      (values) => combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
          ),
    );
  }

  static CombineLatestStream<dynamic, R> combine5<A, B, C, D, E, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    R combiner(A a, B b, C c, D d, E e),
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE],
      (values) => combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
          ),
    );
  }

  static CombineLatestStream<dynamic, R> combine6<A, B, C, D, E, F, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    R combiner(A a, B b, C c, D d, E e, F f),
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE, streamF],
      (values) => combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
          ),
    );
  }

  static CombineLatestStream<dynamic, R> combine7<A, B, C, D, E, F, G, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    R combiner(A a, B b, C c, D d, E e, F f, G g),
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE, streamF, streamG],
      (values) => combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
            values[6] as G,
          ),
    );
  }

  static CombineLatestStream<dynamic, R> combine8<A, B, C, D, E, F, G, H, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    Stream<H> streamH,
    R combiner(A a, B b, C c, D d, E e, F f, G g, H h),
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE, streamF, streamG, streamH],
      (values) => combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
            values[6] as G,
            values[7] as H,
          ),
    );
  }

  static CombineLatestStream<dynamic, R> combine9<A, B, C, D, E, F, G, H, I, R>(
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
  ) {
    return CombineLatestStream<dynamic, R>(
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
      (values) => combiner(
            values[0] as A,
            values[1] as B,
            values[2] as C,
            values[3] as D,
            values[4] as E,
            values[5] as F,
            values[6] as G,
            values[7] as H,
            values[8] as I,
          ),
    );
  }

  static StreamController<R> _buildController<T, R>(
    Iterable<Stream<T>> streams,
    R combiner(List<T> values),
  ) {
    final subscriptions = List<StreamSubscription<dynamic>>(streams.length);
    StreamController<R> controller;

    controller = StreamController<R>(
      sync: true,
      onListen: () {
        final len = streams.length;
        final values = List<T>(len);
        var pendingOnValue = len, pendingOnDone = len;

        final maybeDispatchNext = () {
          // if all Streams have emitted at least one event,
          // then dispatch a new combineLatest event.
          if (pendingOnValue == 0) {
            try {
              controller.add(combiner(values.toList(growable: false)));
            } catch (e, s) {
              controller.addError(e, s);
            }
          }
        };

        final onEvent = (int index) {
          var hasEmittedOnce = false;

          return (T value) {
            values[index] = value;

            if (!hasEmittedOnce) {
              hasEmittedOnce = true;
              pendingOnValue--;
            }

            maybeDispatchNext();
          };
        };

        final onDone = () {
          pendingOnDone--;

          if (pendingOnDone == 0) controller.close();
        };

        for (var i = 0; i < len; i++) {
          final stream = streams.elementAt(i);

          subscriptions[i] = stream.listen(
            onEvent(i),
            onError: controller.addError,
            onDone: onDone,
          );
        }
      },
      onPause: ([Future resumeSignal]) => subscriptions
          .forEach((subscription) => subscription.pause(resumeSignal)),
      onResume: () =>
          subscriptions.forEach((subscription) => subscription.resume()),
      onCancel: () => Future.wait<dynamic>(subscriptions
          .map((subscription) => subscription.cancel())
          .where((cancelFuture) => cancelFuture != null)),
    );

    return controller;
  }
}
