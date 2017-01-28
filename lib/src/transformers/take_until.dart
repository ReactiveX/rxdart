import 'package:rxdart/src/observable.dart';

StreamTransformer<T, T> takeUntilTransformer<T, S>(
    Stream<T> stream, Stream<S> otherStream) {
  return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;
    StreamSubscription<S> otherSubscription;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          subscription = input.listen((T data) {
            controller.add(data);
          },
              onError: controller.addError,
              onDone: controller.close,
              cancelOnError: cancelOnError);

          otherSubscription = otherStream.listen((_) => controller.close(),
              onError: controller.addError, cancelOnError: cancelOnError);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () {
          return Future.wait(<Future<dynamic>>[
            subscription.cancel(),
            otherSubscription.cancel()
          ].where((Future<dynamic> cancelFuture) => cancelFuture != null));
        });

    return controller.stream.listen(null);
  });
}
