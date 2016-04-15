library rx.operators.interval;

import 'package:rxdart/src/observable/stream.dart';

class IntervalObservable<T> extends StreamObservable<T> {

  IntervalObservable(Stream<T> stream, Duration duration) {
    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            subscription.pause();

            new Timer(duration, () {
              controller.add(value);
              subscription.resume();
            });
          },
              onError: (e, s) => throwError(e, s),
              onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}