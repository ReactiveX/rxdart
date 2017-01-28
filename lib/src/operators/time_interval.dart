import 'package:rxdart/src/observable/stream.dart';

class TimeIntervalObservable<T, S extends TimeInterval<T>>
    extends StreamObservable<TimeInterval<T>> {
  TimeIntervalObservable(Stream<T> stream) : super(buildStream(stream));

  static Stream<TimeInterval<T>> buildStream<T, S extends TimeInterval<T>>(
      Stream<T> stream) {
    return stream.transform(
        new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<TimeInterval<T>> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            Stopwatch stopwatch = new Stopwatch()..start();
            int ems;

            subscription = input.listen(
                (T value) {
                  ems = stopwatch.elapsedMicroseconds;

                  stopwatch.stop();

                  controller.add(new TimeInterval<T>(value, ems));

                  stopwatch = new Stopwatch()..start();
                },
                onError: controller.addError,
                onDone: () {
                  stopwatch.stop();
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

class TimeInterval<T> {
  final int interval;
  final T value;

  TimeInterval(this.value, this.interval);
}
