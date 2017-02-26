import 'dart:async';

class DefaultIfEmptyStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  DefaultIfEmptyStreamTransformer(T defaultValue)
      : transformer = _buildTransformer(defaultValue);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(T defaultValue) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      bool hasEvent = false;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  hasEvent = true;
                  controller.add(value);
                },
                onError: controller.addError,
                onDone: () {
                  if (!hasEvent) controller.add(defaultValue);
                  controller.close();
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
