import 'dart:async';

StreamTransformer<T, T> switchIfEmptyTransformer<T>(Stream<T> fallbackStream) {
  return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
    StreamController<T> controller;
    StreamSubscription<T> defaultSubscription;
    StreamSubscription<T> switchSubscription;
    bool hasEvent = false;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          defaultSubscription = input.listen(
              (T value) {
                hasEvent = true;
                controller.add(value);
              },
              onError: controller.addError,
              onDone: () {
                if (!hasEvent) {
                  switchSubscription = fallbackStream.listen((T value) {
                    controller.add(value);
                  },
                      onError: controller.addError,
                      onDone: controller.close,
                      cancelOnError: cancelOnError);
                }
              },
              cancelOnError: cancelOnError);
        },
        onPause: ([Future<dynamic> resumeSignal]) {
          defaultSubscription?.pause(resumeSignal);
          switchSubscription?.pause(resumeSignal);
        },
        onResume: () {
          defaultSubscription?.resume();
          switchSubscription?.resume();
        },
        onCancel: () {
          return Future.wait(<Future<dynamic>>[
            defaultSubscription?.cancel(),
            switchSubscription?.cancel()
          ]);
        });

    return controller.stream.listen(null);
  });
}
