import 'package:rxdart/src/observable/stream.dart';

class DefaultIfEmptyObservable<T> extends StreamObservable<T> {
  DefaultIfEmptyObservable(Stream<T> stream, T defaultValue)
      : super(buildStream(stream, defaultValue));

  static Stream<T> buildStream<T>(Stream<T> stream, T defaultValue) {
    return stream.transform(
        new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
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
    }));
  }
}
