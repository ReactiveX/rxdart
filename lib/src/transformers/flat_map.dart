import 'dart:async';

/// Converts each emitted item into a new Stream using the given mapper
/// function. The newly created Stream will be listened to and begin
/// emitting items downstream.
///
/// The items emitted by each of the new Streams are emitted downstream in the
/// same order they arrive. In other words, the sequences are merged
/// together.
///
/// ### Example
///
///       Stream.fromIterable([4, 3, 2, 1])
///         .transform(FlatMapStreamTransformer((i) =>
///           Stream.fromFuture(
///             Future.delayed(Duration(minutes: i), () => i))
///         .listen(print); // prints 1, 2, 3, 4
class FlatMapStreamTransformer<T, S> extends StreamTransformerBase<T, S> {
  final StreamTransformer<T, S> _transformer;

  /// Constructs a [StreamTransformer] which emits events from the source [Stream] using the given [mapper].
  /// The mapped [Stream] will be listened to and begin emitting items downstream.
  FlatMapStreamTransformer(Stream<S> Function(T value) mapper)
      : _transformer = _buildTransformer(mapper);

  @override
  Stream<S> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      Stream<S> Function(T value) mapper) {
    return StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      final subscriptions = <StreamSubscription<S>>[];
      StreamController<S> controller;
      StreamSubscription<T> subscription;

      var closeAfterNextEvent = false, hasMainEvent = false, openStreams = 0;

      controller = StreamController<S>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  try {
                    StreamSubscription<S> otherSubscription;
                    var otherStream = mapper(value);

                    hasMainEvent = true;

                    openStreams++;

                    otherSubscription = otherStream.listen(controller.add,
                        onError: controller.addError, onDone: () {
                      openStreams--;

                      if (closeAfterNextEvent && openStreams == 0) {
                        controller.close();
                      }
                    });

                    subscriptions.add(otherSubscription);
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                },
                onError: controller.addError,
                onDone: () {
                  if (!hasMainEvent || openStreams == 0) {
                    controller.close();
                  } else {
                    closeAfterNextEvent = true;
                  }
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            subscription.pause(resumeSignal);

            subscriptions.forEach((StreamSubscription<S> otherSubscription) =>
                otherSubscription.pause(resumeSignal));
          },
          onResume: () {
            subscription.resume();

            subscriptions.forEach((StreamSubscription<S> otherSubscription) =>
                otherSubscription.resume());
          },
          onCancel: () {
            final list = List<StreamSubscription<dynamic>>.from(subscriptions)
              ..add(subscription);

            return Future.wait<dynamic>(list
                .map((StreamSubscription<dynamic> subscription) =>
                    subscription.cancel())
                .where((Future<dynamic> cancelFuture) => cancelFuture != null));
          });

      return controller.stream.listen(null);
    });
  }
}

/// Extends the Stream class with the ability to convert the source Stream into
/// a new Stream each time the source emits an item.
extension FlatMapExtension<T> on Stream<T> {
  /// Converts each emitted item into a Stream using the given mapper
  /// function. The newly created Stream will be be listened to and begin
  /// emitting items downstream.
  ///
  /// The items emitted by each of the Streams are emitted downstream in the
  /// same order they arrive. In other words, the sequences are merged
  /// together.
  ///
  /// ### Example
  ///
  ///     RangeStream(4, 1)
  ///       .flatMap((i) => TimerStream(i, Duration(minutes: i))
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<S> flatMap<S>(Stream<S> Function(T value) mapper) =>
      transform(FlatMapStreamTransformer<T, S>(mapper));

  /// Converts each item into a Stream. The Stream must return an
  /// Iterable. Then, each item from the Iterable will be emitted one by one.
  ///
  /// Use case: you may have an API that returns a list of items, such as
  /// a Stream<List<String>>. However, you might want to operate on the individual items
  /// rather than the list itself. This is the job of `flatMapIterable`.
  ///
  /// ### Example
  ///
  ///     RangeStream(1, 4)
  ///       .flatMapIterable((i) => Stream.fromIterable([[i]])
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<S> flatMapIterable<S>(Stream<Iterable<S>> Function(T value) mapper) =>
      transform(FlatMapStreamTransformer<T, Iterable<S>>(mapper))
          .expand((Iterable<S> iterable) => iterable);
}
