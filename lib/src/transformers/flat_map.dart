import 'dart:async';

class FlatMapStreamTransformer<T, S> implements StreamTransformer<T, S> {
  final StreamTransformer<T, S> transformer;

  FlatMapStreamTransformer(Stream<S> predicate(T value))
      : transformer = _buildTransformer(predicate);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      Stream<S> predicate(T value)) {
    return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      final List<Stream<S>> streams = <Stream<S>>[];
      final List<StreamSubscription<S>> subscriptions =
          <StreamSubscription<S>>[];
      StreamController<S> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> otherSubscription;
      bool closeAfterNextEvent = false;
      bool hasMainEvent = false;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  Stream<S> otherStream = predicate(value);

                  hasMainEvent = true;

                  streams.add(otherStream);

                  otherSubscription = otherStream.listen(controller.add,
                      onError: controller.addError, onDone: () {
                    streams.remove(otherStream);
                    subscriptions.remove(otherSubscription);

                    if (closeAfterNextEvent && streams.isEmpty)
                      controller.close();
                  });

                  subscriptions.add(otherSubscription);
                },
                onError: controller.addError,
                onDone: () {
                  if (!hasMainEvent)
                    controller.close();
                  else
                    closeAfterNextEvent = true;
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
            final List<StreamSubscription<dynamic>> list =
                new List<StreamSubscription<dynamic>>.from(subscriptions)
                  ..add(subscription);

            return Future.wait(list
                .map((StreamSubscription<dynamic> subscription) =>
                    subscription.cancel())
                .where((Future<dynamic> cancelFuture) => cancelFuture != null));
          });

      return controller.stream.listen(null);
    });
  }
}
