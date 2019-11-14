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
  final StreamTransformer<T, R> _transformer;

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from [latestFromStreams] using the provided function [fn].
  WithLatestFromStreamTransformer(
      Iterable<Stream<S>> latestFromStreams, R fn(T t, List<S> values))
      : _transformer = _buildTransformer(latestFromStreams, fn);

  @override
  Stream<R> bind(Stream<T> stream) => _transformer.bind(stream);

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from [latestFromStreams] using a [List].
  static WithLatestFromStreamTransformer<T, T, List<T>> withList<T>(
    Iterable<Stream<T>> latestFromStreams,
  ) {
    return WithLatestFromStreamTransformer<T, T, List<T>>(
      latestFromStreams,
      (s, values) => [s]..addAll(values),
    );
  }

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from [latestFromStream] using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

  /// Constructs a [StreamTransformer] that emits when the source [Stream] emits, combining
  /// the latest values from all [latestFromStream]s using the provided function [fn].
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

/// Extends the Stream class with the ability to merge the source Stream with
/// the last emitted item from another Stream.
extension WithLatestFromExtensions<T> on Stream<T> {
  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the two streams using the provided function.
  ///
  /// If the latestFromStream has not emitted any values, this stream will not
  /// emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2]).withLatestFrom(
  ///       Stream.fromIterable([2, 3]), (a, b) => a + b)
  ///       .listen(print); // prints 4 (due to the async nature of streams)
  Stream<R> withLatestFrom<S, R>(Stream<S> latestFromStream, R fn(T t, S s)) =>
      transform(WithLatestFromStreamTransformer.with1(latestFromStream, fn));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the streams into a list. This is helpful when you need
  /// to combine a dynamic number of Streams.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///     Stream.fromIterable([1, 2]).withLatestFromList(
  ///         [
  ///           Stream.fromIterable([2, 3]),
  ///           Stream.fromIterable([3, 4]),
  ///           Stream.fromIterable([4, 5]),
  ///           Stream.fromIterable([5, 6]),
  ///           Stream.fromIterable([6, 7]),
  ///         ],
  ///       ).listen(print); // print [2, 2, 3, 4, 5, 6] (due to the async nature of streams)
  ///
  Stream<List<T>> withLatestFromList(Iterable<Stream<T>> latestFromStreams) =>
      transform(WithLatestFromStreamTransformer.withList(latestFromStreams));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the three streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom2(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         (int a, int b, int c) => a + b + c,
  ///       )
  ///       .listen(print); // prints 7 (due to the async nature of streams)
  Stream<R> withLatestFrom2<A, B, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    R fn(T t, A a, B b),
  ) =>
      transform(WithLatestFromStreamTransformer.with2(
        latestFromStream1,
        latestFromStream2,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the four streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom3(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         (int a, int b, int c, int d) => a + b + c + d,
  ///       )
  ///       .listen(print); // prints 11 (due to the async nature of streams)
  Stream<R> withLatestFrom3<A, B, C, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    R fn(T t, A a, B b, C c),
  ) =>
      transform(WithLatestFromStreamTransformer.with3(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the five streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom4(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         (int a, int b, int c, int d, int e) => a + b + c + d + e,
  ///       )
  ///       .listen(print); // prints 16 (due to the async nature of streams)
  Stream<R> withLatestFrom4<A, B, C, D, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    R fn(T t, A a, B b, C c, D d),
  ) =>
      transform(WithLatestFromStreamTransformer.with4(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the six streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom5(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         (int a, int b, int c, int d, int e, int f) => a + b + c + d + e + f,
  ///       )
  ///       .listen(print); // prints 22 (due to the async nature of streams)
  Stream<R> withLatestFrom5<A, B, C, D, E, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    R fn(T t, A a, B b, C c, D d, E e),
  ) =>
      transform(WithLatestFromStreamTransformer.with5(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the seven streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom6(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         (int a, int b, int c, int d, int e, int f, int g) =>
  ///             a + b + c + d + e + f + g,
  ///       )
  ///       .listen(print); // prints 29 (due to the async nature of streams)
  Stream<R> withLatestFrom6<A, B, C, D, E, F, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    R fn(T t, A a, B b, C c, D d, E e, F f),
  ) =>
      transform(WithLatestFromStreamTransformer.with6(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the eight streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom7(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         Stream.fromIterable([8, 9]),
  ///         (int a, int b, int c, int d, int e, int f, int g, int h) =>
  ///             a + b + c + d + e + f + g + h,
  ///       )
  ///       .listen(print); // prints 37 (due to the async nature of streams)
  Stream<R> withLatestFrom7<A, B, C, D, E, F, G, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g),
  ) =>
      transform(WithLatestFromStreamTransformer.with7(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the nine streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom8(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         Stream.fromIterable([8, 9]),
  ///         Stream.fromIterable([9, 10]),
  ///         (int a, int b, int c, int d, int e, int f, int g, int h, int i) =>
  ///             a + b + c + d + e + f + g + h + i,
  ///       )
  ///       .listen(print); // prints 46 (due to the async nature of streams)
  Stream<R> withLatestFrom8<A, B, C, D, E, F, G, H, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    Stream<H> latestFromStream8,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g, H h),
  ) =>
      transform(WithLatestFromStreamTransformer.with8(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        latestFromStream8,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the ten streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom9(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         Stream.fromIterable([8, 9]),
  ///         Stream.fromIterable([9, 10]),
  ///         Stream.fromIterable([10, 11]),
  ///         (int a, int b, int c, int d, int e, int f, int g, int h, int i, int j) =>
  ///             a + b + c + d + e + f + g + h + i + j,
  ///       )
  ///       .listen(print); // prints 46 (due to the async nature of streams)
  Stream<R> withLatestFrom9<A, B, C, D, E, F, G, H, I, R>(
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
  ) =>
      transform(WithLatestFromStreamTransformer.with9(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        latestFromStream8,
        latestFromStream9,
        fn,
      ));
}
