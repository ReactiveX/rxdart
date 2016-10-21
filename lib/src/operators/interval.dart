library rx.operators.interval;

import 'package:rxdart/src/observable/stream.dart';

class IntervalObservable<T> extends StreamObservable<T> {

  IntervalObservable(Stream<T> stream, Duration duration) {
    setStream(stream.transform(new StreamTransformer<T, T>(
        (Stream<T> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<T> subscription;

        controller = new StreamController<T>(sync: true,
            onListen: () {
              subscription = input.listen((T value) {
                subscription.pause();

                new Timer(duration, () {
                  controller.add(value);
                  subscription.resume();
                });
              },
                  onError: (dynamic e, dynamic s) => controller.addError(e, s),
                  onDone: controller.close,
                  cancelOnError: cancelOnError);
            },
            onPause: () => subscription.pause(),
            onResume: () => subscription.resume(),
            onCancel: () => subscription.cancel());

        return controller.stream.listen(null);
      }
    )));
  }

}