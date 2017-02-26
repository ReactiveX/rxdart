import 'dart:async';

class FlatMapLatestStreamTransformer<T, S> implements StreamTransformer<T, S> {
  final StreamTransformer<T, S> transformer;

  FlatMapLatestStreamTransformer(Stream<S> predicate(T value))
      : transformer = _buildTransformer(predicate);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      Stream<S> predicate(T value)) {
    return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> otherSubscription;
      bool leftClosed = false, rightClosed = false;
      bool hasMainEvent = false;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  otherSubscription?.cancel();

                  hasMainEvent = true;

                  otherSubscription = predicate(value).listen(controller.add,
                      onError: controller.addError, onDone: () {
                    rightClosed = true;

                    if (leftClosed) controller.close();
                  });
                },
                onError: controller.addError,
                onDone: () {
                  leftClosed = true;

                  if (rightClosed || !hasMainEvent) controller.close();
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            subscription.pause(resumeSignal);
            otherSubscription?.pause(resumeSignal);
          },
          onResume: () {
            subscription.resume();
            otherSubscription?.resume();
          },
          onCancel: () async {
            await subscription.cancel();

            if (hasMainEvent) await otherSubscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}
