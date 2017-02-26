import 'dart:async';

class IntervalStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  IntervalStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) => subscription.pause(
                    new Future<T>.delayed(duration, () => value)
                        .then(controller.add)),
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: () => subscription.pause(),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
