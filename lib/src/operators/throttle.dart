library rx.operators.throttle;

import 'package:rxdart/src/observable/stream.dart';

class ThrottleObservable<T> extends StreamObservable<T> {

  ThrottleObservable(Stream<T> stream, Duration duration) {
    Timer _timer;
    bool _closeAfterNextEvent = false;

    setStream(stream.transform(new StreamTransformer<T, T>(
      (Stream<T> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<T> subscription;

        bool _resetTimer() {
          if (_timer != null && _timer.isActive) return false;

          _timer = new Timer(duration, () {
            if (_closeAfterNextEvent && !controller.isClosed) controller.close();
          });

          return true;
        }

        controller = new StreamController<T>(sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              if (_resetTimer()) controller.add(value);
            },
              onError: controller.addError,
              onDone: () {
                _closeAfterNextEvent = true;
              },
              cancelOnError: cancelOnError);
          },
            onPause: ([Future<dynamic> resumeSignal]) => subscription.pause(resumeSignal),
            onResume: () => subscription.resume(),
            onCancel: () => subscription.cancel());

        return controller.stream.listen(null);
      }
    )));
  }

}