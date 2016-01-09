library rx.observable.throttle;

import 'package:rxdart/src/observable/stream.dart';

class ThrottleObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  Timer _timer;
  Duration _duration;
  bool _closeAfterNextEvent = false;

  ThrottleObservable(Stream<T> stream, Duration duration) : _duration = duration {
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            if (_resetTimer()) controller.add(value);
          },
              onError: (e, s) => throwError(e, s),
              onDone: () => _closeAfterNextEvent = true);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

  bool _resetTimer() {
    if (_timer != null && _timer.isActive) return false;

    _timer = new Timer(_duration, () {
      if (_closeAfterNextEvent) controller.close();
    });

    return true;
  }

}