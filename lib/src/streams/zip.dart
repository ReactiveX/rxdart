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
/// ### Basic Example
///
///     ZipStream(
///       [
///         Stream.fromIterable(['A']),
///         Stream.fromIterable(['B']),
///         Stream.fromIterable(['C', 'D']),
///       ],
///       (values) => values.join(),
///     ).listen(print); // prints 'ABC'
///
/// ### Example with a specific number of Streams
///
/// If you wish to zip a specific number of Streams together with proper types
/// information for the value of each Stream, use the [zip2] - [zip9] operators.
///
///     ZipStream.zip2(
///       Stream.fromIterable(['A']),
///       Stream.fromIterable(['B', 'C']),
///       (a, b) => a + b,
///     )
///     .listen(print); // prints 'AB'
class ZipStream<T, R> extends StreamView<R> {
  ZipStream(
    Iterable<Stream<T>> streams,
    R zipper(List<T> values),
  )   : assert(streams != null && streams.every((s) => s != null),
            'streams cannot be null'),
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
      final len = streams.length;
      List<StreamSubscription<T>> subscriptions, pendingSubscriptions;

      controller = StreamController<R>(
          sync: true,
          onListen: () {
            try {
              Completer<void> completeCurrent;
              final window = _Window<T>(len);
              var index = 0;

              // resets variables for the next zip window
              final next = () {
                completeCurrent?.complete();

                completeCurrent = Completer<List<T>>();

                pendingSubscriptions = subscriptions.toList();
              };

              final doUpdate = (int index) => (T value) {
                    window.onValue(index, value);

                    if (window.isComplete) {
                      // all streams emitted for the current zip index
                      // dispatch event and reset for next
                      try {
                        controller.add(zipper(window.flush()));
                        // reset for next zip event
                        next();
                      } catch (e, s) {
                        controller.addError(e, s);
                      }
                    } else {
                      // other streams are still pending to get to the next
                      // zip event index.
                      // pause this subscription while we await the others
                      //ignore: cancel_subscriptions
                      final subscription = subscriptions[index]
                        ..pause(completeCurrent.future);

                      pendingSubscriptions.remove(subscription);
                    }
                  };

              subscriptions = streams
                  .map((stream) => stream.listen(doUpdate(index++),
                      onError: controller.addError, onDone: controller.close))
                  .toList(growable: false);

              next();
            } catch (e, s) {
              controller.addError(e, s);
            }
          },
          onPause: ([Future<dynamic> resumeSignal]) => pendingSubscriptions
              .forEach((subscription) => subscription.pause(resumeSignal)),
          onResume: () => pendingSubscriptions
              .forEach((subscription) => subscription.resume()),
          onCancel: () => Future.wait<dynamic>(subscriptions
              .map((subscription) => subscription.cancel())
              .where((cancelFuture) => cancelFuture != null)));

      return controller;
    }
  }
}

/// A window keeps track of the values emitted by the different
/// zipped Streams.
class _Window<T> {
  final int size;
  final List<T> _values;

  int _valuesReceived = 0;

  bool get isComplete => _valuesReceived == size;

  _Window(this.size) : _values = List<T>(size);

  void onValue(int index, T value) {
    _values[index] = value;

    _valuesReceived++;
  }

  List<T> flush() {
    _valuesReceived = 0;

    return List.unmodifiable(_values);
  }
}
