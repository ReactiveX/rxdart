import 'dart:async';

StreamTransformer<S, T> streamTransformed<S, T>(
    StreamTransformer<S, T> transformer) {
  return StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = StreamController<T>(
        sync: true,
        onListen: () {
          subscription = input.transform(transformer).listen(controller.add,
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
