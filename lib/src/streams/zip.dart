import 'dart:async';

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
///     new ZipStream([
///         new Stream.fromIterable([1]),
///         new Stream.fromIterable([2, 3])
///       ], (a, b) => a + b)
///       .listen(print); // prints 3
class ZipStream<T, R> extends StreamView<R> {
  ZipStream(
    Iterable<Stream<T>> streams,
    R zipper(List<T> values),
  )   : assert(streams != null && streams.every((s) => s != null),
            'streams cannot be null'),
        assert(streams.length > 1, 'provide at least 2 streams'),
        assert(zipper != null, 'must provide a zipper function'),
        super(_buildController(streams, zipper).stream);

  static ZipStream<T, List<T>> list<T>(Iterable<Stream<T>> streams) {
    return ZipStream<T, List<T>>(
      streams,
      (List<T> values) => values,
    );
  }

  static ZipStream<dynamic, R> zip2<A, B, R>(
    Stream<A> streamOne,
    Stream<B> streamTwo,
    R zipper(A a, B b),
  ) {
    return ZipStream<dynamic, R>(
      [streamOne, streamTwo],
      (List<dynamic> values) => zipper(values[0] as A, values[1] as B),
    );
  }

  static ZipStream<dynamic, R> zip3<A, B, C, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    R zipper(A a, B b, C c),
  ) {
    return ZipStream<dynamic, R>(
      [streamA, streamB, streamC],
      (List<dynamic> values) {
        return zipper(
          values[0] as A,
          values[1] as B,
          values[2] as C,
        );
      },
    );
  }

  static ZipStream<dynamic, R> zip4<A, B, C, D, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    R zipper(A a, B b, C c, D d),
  ) {
    return ZipStream<dynamic, R>(
      [streamA, streamB, streamC, streamD],
      (List<dynamic> values) {
        return zipper(
          values[0] as A,
          values[1] as B,
          values[2] as C,
          values[3] as D,
        );
      },
    );
  }

  static ZipStream<dynamic, R> zip5<A, B, C, D, E, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    R zipper(A a, B b, C c, D d, E e),
  ) {
    return ZipStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE],
      (List<dynamic> values) {
        return zipper(
          values[0] as A,
          values[1] as B,
          values[2] as C,
          values[3] as D,
          values[4] as E,
        );
      },
    );
  }

  static ZipStream<dynamic, R> zip6<A, B, C, D, E, F, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    R zipper(A a, B b, C c, D d, E e, F f),
  ) {
    return ZipStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE, streamF],
      (List<dynamic> values) {
        return zipper(
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

  static ZipStream<dynamic, R> zip7<A, B, C, D, E, F, G, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    R zipper(A a, B b, C c, D d, E e, F f, G g),
  ) {
    return ZipStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE, streamF, streamG],
      (List<dynamic> values) {
        return zipper(
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

  static ZipStream<dynamic, R> zip8<A, B, C, D, E, F, G, H, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    Stream<H> streamH,
    R zipper(A a, B b, C c, D d, E e, F f, G g, H h),
  ) {
    return ZipStream<dynamic, R>(
      [streamA, streamB, streamC, streamD, streamE, streamF, streamG, streamH],
      (List<dynamic> values) {
        return zipper(
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

  static ZipStream<dynamic, R> zip9<A, B, C, D, E, F, G, H, I, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    Stream<D> streamD,
    Stream<E> streamE,
    Stream<F> streamF,
    Stream<G> streamG,
    Stream<H> streamH,
    Stream<I> streamI,
    R zipper(A a, B b, C c, D d, E e, F f, G g, H h, I i),
  ) {
    return ZipStream<dynamic, R>(
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
        return zipper(
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
    R zipper(List<T> values),
  ) {
    {
      StreamController<R> controller;
      final subscriptions = List<StreamSubscription<T>>(streams.length);

      controller = StreamController<R>(
          sync: true,
          onListen: () {
            try {
              final values = List<List<T>>.generate(streams.length, (_) => []);
              final completedStatus =
                  List.generate(streams.length, (_) => false);

              void doUpdate(int index, T value) {
                values[index].add(value);

                if (values.every((v) => v.isNotEmpty)) {
                  try {
                    controller.add(zipper(
                        values.fold([], (prev, vals) => prev..add(vals[0]))));
                  } catch (e, s) {
                    controller.addError(e, s);
                  }

                  values.forEach((v) => v..removeAt(0));
                }
              }

              void markDone(int i) {
                completedStatus[i] = true;

                if (completedStatus.reduce((bool a, bool b) => a && b))
                  controller.close();
              }

              for (var i = 0, len = streams.length; i < len; i++) {
                var stream = streams.elementAt(i);

                subscriptions[i] = stream.listen(
                    (T value) => doUpdate(i, value),
                    onError: controller.addError,
                    onDone: () => markDone(i));
              }
            } catch (e, s) {
              controller.addError(e, s);
            }
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscriptions.where((StreamSubscription<dynamic> subscription) => subscription != null).forEach(
                  (StreamSubscription<dynamic> subscription) =>
                      subscription.pause(resumeSignal)),
          onResume: () =>
              subscriptions.where((StreamSubscription<dynamic> subscription) => subscription != null).forEach(
                  (StreamSubscription<dynamic> subscription) =>
                      subscription.resume()),
          onCancel: () => Future.wait<dynamic>(subscriptions
              .map((StreamSubscription<dynamic> subscription) => subscription.cancel())
              .where((Future<dynamic> cancelFuture) => cancelFuture != null)));

      return controller;
    }
  }
}
