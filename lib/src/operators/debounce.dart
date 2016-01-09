library rx.observable.debounce;

import 'package:rxdart/src/observable/stream.dart';

class DebounceObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  Timer _timer;
  Duration _duration;
  T _lastValue;
  bool _closeAfterNextEvent = false;

  DebounceObservable(Stream<T> stream, Duration duration) : _duration = duration {
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            _resetTimer();
            _lastValue = value;
          },
              onError: (e, s) => throwError(e, s),
              onDone: () => _closeAfterNextEvent = true);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

  void _resetTimer() {
    if (_timer != null && _timer.isActive) _timer.cancel();

    _timer = new Timer(_duration, () {
      controller.add(_lastValue);

      if (_closeAfterNextEvent) controller.close();
    });
  }

}