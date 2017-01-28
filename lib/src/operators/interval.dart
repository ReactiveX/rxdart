import 'package:rxdart/src/observable/stream.dart';

class IntervalObservable<T> extends StreamObservable<T> {
  IntervalObservable(Stream<T> stream, Duration duration)
      : super(buildStream(stream, duration));

  static Stream<T> buildStream<T>(Stream<T> stream, Duration duration) {
    return stream.transform(
        new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
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
    }));
  }
}
