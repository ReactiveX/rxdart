import 'dart:async';

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
///       new Stream.fromIterable([4, 3, 2, 1])
///         .transform(new FlatMapStreamTransformer((i) =>
///           new Stream.fromFuture(
///             new Future.delayed(new Duration(minutes: i), () => i))
///         .listen(print); // prints 1, 2, 3, 4
class FlatMapStreamTransformer<T, S> extends StreamTransformerBase<T, S> {
  final StreamTransformer<T, S> transformer;

  FlatMapStreamTransformer(Stream<S> mapper(T value))
      : transformer = _buildTransformer(mapper);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      Stream<S> mapper(T value)) {
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
