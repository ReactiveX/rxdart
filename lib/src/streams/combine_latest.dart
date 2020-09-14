import 'dart:async';

/// Merges the given Streams into one Stream sequence by using the
/// combiner function whenever any of the source stream sequences emits an
/// item.
///
/// The Stream will not emit until all Streams have emitted at least one
/// item.
///
/// If the provided streams is empty, the resulting sequence completes immediately
/// without emitting any items and without any calls to the combiner function.
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
///       Stream.fromIterable(['a']),
///       Stream.fromIterable(['b']),
///       Stream.fromIterable(['C', 'D'])])
///     .listen(print); //prints ['a', 'b', 'C'], ['a', 'b', 'D']
///
/// ### Example with combiner
///
/// If you wish to combine the list of values into a new object before you
///
///     CombineLatestStream(
///       [
///         Stream.fromIterable(['a']),
///         Stream.fromIterable(['b']),
///         Stream.fromIterable(['C', 'D'])
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
///       Stream.fromIterable([1]),
///       Stream.fromIterable([2, 3]),
///       (a, b) => a + b,
///     )
///     .listen(print); // prints 3, 4
class CombineLatestStream<T, R> extends StreamView<R> {
  /// Constructs a [Stream] that observes an [Iterable] of [Stream]
  /// and builds a [List] containing all latest events emitted by the provided [Iterable] of [Stream].
  /// The [combiner] maps this [List] into a new event of type [R]
  CombineLatestStream(
    Iterable<Stream<T>> streams,
    R Function(List<T> values) combiner,
  )   : assert(streams != null && streams.every((s) => s != null),
            'streams cannot be null'),
        assert(combiner != null, 'must provide a combiner function'),
        super(_buildController(streams, combiner).stream);

  /// Constructs a [CombineLatestStream] using a default combiner, which simply
  /// yields a [List] of all latest events emitted by the provided [Iterable] of [Stream].
  static CombineLatestStream<T, List<T>> list<T>(
    Iterable<Stream<T>> streams,
  ) {
    return CombineLatestStream<T, List<T>>(
      streams,
      (List<T> values) => values,
    );
  }

  /// Constructs a [CombineLatestStream] from a pair of [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
  static CombineLatestStream<dynamic, R> combine2<A, B, R>(
    Stream<A> streamOne,
    Stream<B> streamTwo,
    R Function(A a, B b) combiner,
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamOne, streamTwo],
      (List<dynamic> values) => combiner(values[0] as A, values[1] as B),
    );
  }

  /// Constructs a [CombineLatestStream] from 3 [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
  static CombineLatestStream<dynamic, R> combine3<A, B, C, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    R Function(A a, B b, C c) combiner,
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC],
      (List<dynamic> values) {
        return combiner(
          values[0] as A,
          values[1] as B,
          values[2] as C,
        );
      },
    );
  }

  /// Constructs a [CombineLatestStream] from 4 [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
  static CombineLatestStream<dynamic, R> combine4<A, B, C, D, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    R Function(A a, B b, C c, D d) combiner,
  ) {
    return CombineLatestStream<dynamic, R>(
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
  }

  /// Constructs a [CombineLatestStream] from 5 [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
  static CombineLatestStream<dynamic, R> combine5<A, B, C, D, E, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    R Function(A a, B b, C c, D d, E e) combiner,
  ) {
    return CombineLatestStream<dynamic, R>(
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
  }

  /// Constructs a [CombineLatestStream] from 6 [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
  static CombineLatestStream<dynamic, R> combine6<A, B, C, D, E, F, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    R Function(A a, B b, C c, D d, E e, F f) combiner,
  ) {
    return CombineLatestStream<dynamic, R>(
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
  }

  /// Constructs a [CombineLatestStream] from 7 [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
  static CombineLatestStream<dynamic, R> combine7<A, B, C, D, E, F, G, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    R Function(A a, B b, C c, D d, E e, F f, G g) combiner,
  ) {
    return CombineLatestStream<dynamic, R>(
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
  }

  /// Constructs a [CombineLatestStream] from 8 [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
  static CombineLatestStream<dynamic, R> combine8<A, B, C, D, E, F, G, H, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    Stream<H> streamH,
    R Function(A a, B b, C c, D d, E e, F f, G g, H h) combiner,
  ) {
    return CombineLatestStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE, streamF, streamG, streamH],
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
  }

  /// Constructs a [CombineLatestStream] from 9 [Stream]s
  /// where [combiner] is used to create a new event of type [R], based on the
  /// latest events emitted by the provided [Stream]s.
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
    R Function(A a, B b, C c, D d, E e, F f, G g, H h, I i) combiner,
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
  }

  static StreamController<R> _buildController<T, R>(
    Iterable<Stream<T>> streams,
    R Function(List<T> values) combiner,
  ) {
    if (streams.isEmpty) {
      return StreamController<R>()..close();
    }

    final len = streams.length;
    List<StreamSubscription<dynamic>> subscriptions;
    StreamController<R> controller;

    controller = StreamController<R>(
      sync: true,
      onListen: () {
        final values = List<T>(len);
        var triggered = 0, completed = 0, index = 0;

        final allHaveEvent = () => triggered == len;

        final onDone = () {
          if (++completed == len) controller.close();
        };
        final onUpdate = (int index) => (T value) => values[index] = value;

        subscriptions = streams.map((stream) {
          final onUpdateForStream = onUpdate(index++);
          var hasFirstEvent = false;

          return stream.listen(
            (T value) {
              onUpdateForStream(value);

              if (!hasFirstEvent) {
                hasFirstEvent = true;
                triggered++;
              }

              if (allHaveEvent()) {
                try {
                  controller.add(combiner(List.unmodifiable(values)));
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
            },
            onError: controller.addError,
            onDone: onDone,
          );
        }).toList(growable: false);
      },
      onPause: () =>
          subscriptions.forEach((subscription) => subscription.pause()),
      onResume: () =>
          subscriptions.forEach((subscription) => subscription.resume()),
      onCancel: () => Future.wait<dynamic>(subscriptions
          .map((subscription) => subscription.cancel())
          .where((cancelFuture) => cancelFuture != null)),
    );

    return controller;
  }
}
