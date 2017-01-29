import 'dart:async';

StreamTransformer<T, T> startWithTransformer<T>(T startValue) {
  return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          controller.add(startValue);

          subscription = input.listen(controller.add,
              onError: controller.addError,
              onDone: controller.close,
              cancelOnError: cancelOnError);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream.listen(null);
  });
}
