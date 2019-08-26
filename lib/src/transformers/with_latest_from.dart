import 'dart:async';

/// A StreamTransformer that emits when the source stream emits, combining
/// the latest values from the two streams using the provided function.
///
/// If the latestFromStream has not emitted any values, this stream will not
/// emit either.
///
/// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
///
/// ### Example
///
///     new Stream.fromIterable([1, 2]).transform(
///       new WithLatestFromStreamTransformer(
///         new Stream.fromIterable([2, 3]), (a, b) => a + b)
///       .listen(print); // prints 4 (due to the async nature of streams)
class WithLatestFromStreamTransformer<T, S, R>
    extends StreamTransformerBase<T, R> {
  final StreamTransformer<T, R> transformer;

  WithLatestFromStreamTransformer(
      Iterable<Stream<S>> latestFromStreams, R fn(T t, List<S> values))
      : transformer = _buildTransformer(latestFromStreams, fn);

  @override
  Stream<R> bind(Stream<T> stream) => transformer.bind(stream);

  static WithLatestFromStreamTransformer<T, T, List<T>> withList<T>(
    Iterable<Stream<T>> latestFromStreams,
  ) {
    return WithLatestFromStreamTransformer<T, T, List<T>>(
      latestFromStreams,
      (s, values) => [s]..addAll(values),
    );
  }

  static WithLatestFromStreamTransformer<T, S, R> with1<T, S, R>(
    Stream<S> latestFromStream,
    R fn(T t, S s),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, S, R>(
      [latestFromStream],
      (s, values) => fn(s, values[0]),
    );
  }

  static WithLatestFromStreamTransformer<T, dynamic, R> with2<T, A, B, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    R fn(T t, A a, B b),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [latestFromStream1, latestFromStream2],
      (s, values) => fn(s, values[0] as A, values[1] as B),
    );
  }

  static WithLatestFromStreamTransformer<T, dynamic, R> with3<T, A, B, C, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    R fn(T t, A a, B b, C c),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
      ],
      (s, values) {
        return fn(
          s,
          values[0] as A,
          values[1] as B,
          values[2] as C,
        );
      },
    );
  }

  static WithLatestFromStreamTransformer<T, dynamic, R> with4<T, A, B, C, D, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    R fn(T t, A a, B b, C c, D d),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
      ],
      (s, values) {
        return fn(
          s,
          values[0] as A,
          values[1] as B,
          values[2] as C,
          values[3] as D,
        );
      },
    );
  }

  static WithLatestFromStreamTransformer<T, dynamic, R>
      with5<T, A, B, C, D, E, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    R fn(T t, A a, B b, C c, D d, E e),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
      ],
      (s, values) {
        return fn(
          s,
          values[0] as A,
          values[1] as B,
          values[2] as C,
          values[3] as D,
          values[4] as E,
        );
      },
    );
  }

  static WithLatestFromStreamTransformer<T, dynamic, R>
      with6<T, A, B, C, D, E, F, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    R fn(T t, A a, B b, C c, D d, E e, F f),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
      ],
      (s, values) {
        return fn(
          s,
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

  static WithLatestFromStreamTransformer<T, dynamic, R>
      with7<T, A, B, C, D, E, F, G, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
      ],
      (s, values) {
        return fn(
          s,
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

  static WithLatestFromStreamTransformer<T, dynamic, R>
      with8<T, A, B, C, D, E, F, G, H, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    Stream<H> latestFromStream8,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g, H h),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        latestFromStream8,
      ],
      (s, values) {
        return fn(
          s,
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

  static WithLatestFromStreamTransformer<T, dynamic, R>
      with9<T, A, B, C, D, E, F, G, H, I, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    Stream<H> latestFromStream8,
    Stream<I> latestFromStream9,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g, H h, I i),
  ) {
    if (fn == null) {
      throw ArgumentError('Combiner cannot be null');
    }
    return WithLatestFromStreamTransformer<T, dynamic, R>(
      [
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        latestFromStream8,
        latestFromStream9,
      ],
      (s, values) {
        return fn(
          s,
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

  static StreamTransformer<T, R> _buildTransformer<T, S, R>(
    Iterable<Stream<S>> latestFromStreams,
    R fn(T t, List<S> values),
  ) {
    if (latestFromStreams == null) {
      throw ArgumentError('latestFromStreams cannot be null');
    }
    if (latestFromStreams.any((s) => s == null)) {
      throw ArgumentError('All streams must be not null');
    }
    if (fn == null) {
      throw ArgumentError('combiner cannot be null');
    }

    return StreamTransformer<T, R>((Stream<T> input, bool cancelOnError) {
      final len = latestFromStreams.length;
      StreamController<R> controller;
      StreamSubscription<T> subscription;
      final subscriptions = List<StreamSubscription<S>>(len);

      void onDone() {
        if (controller.isClosed) return;
        controller.close();
      }

      controller = StreamController<R>(
        sync: true,
        onListen: () {
          final latestValues = List<S>(len);
          final hasValues = List.filled(len, false);

          subscription = input.listen(
            (T value) {
              if (hasValues.every((hasValue) => hasValue)) {
                try {
                  controller.add(fn(value, List.unmodifiable(latestValues)));
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
            },
            onError: controller.addError,
            onDone: onDone,
          );

          var index = 0;
          for (final latestFromStream in latestFromStreams) {
            final currentIndex = index;
            subscriptions[index] = latestFromStream.listen(
              (latest) {
                hasValues[currentIndex] = true;
                latestValues[currentIndex] = latest;
              },
              onError: controller.addError,
              cancelOnError: cancelOnError,
            );
            index++;
          }
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () {
          final list = List<StreamSubscription>.of(subscriptions)
            ..add(subscription);

          final cancelFutures = list
              .map((subscription) => subscription.cancel())
              .where((cancelFuture) => cancelFuture != null);

          return Future.wait<dynamic>(cancelFutures);
        },
      );

      return controller.stream.listen(null);
    });
  }
}
