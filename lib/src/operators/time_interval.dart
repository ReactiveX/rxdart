library rx.operators.time_interval;

import 'package:rxdart/src/observable/stream.dart';

class TimeIntervalObservable<T, S extends TimeInterval<T>> extends StreamObservable<TimeInterval<T>> {

  TimeIntervalObservable(StreamObservable parent, Stream<T> stream) {
    this.parent = parent;

    controller = new StreamController<S>(sync: true,
        onListen: () {
          Stopwatch stopwatch = new Stopwatch()..start();
          int ems;

          subscription = stream.listen((T value) {
            ems = stopwatch.elapsedMicroseconds;

            stopwatch.stop();

            controller.add(new TimeInterval<T>(value, ems));

            stopwatch = new Stopwatch()
              ..start();
          },
          onError: controller.addError,
          onDone: () {
            stopwatch.stop();
            controller.close();
          });
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}

class TimeInterval<T> {

  final int interval;
  final T value;

  TimeInterval(this.value, this.interval);

}