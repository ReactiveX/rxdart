library rx.operators.debounce;

import 'package:rxdart/src/observable/stream.dart';

class DebounceObservable<T> extends StreamObservable<T> {

  DebounceObservable(StreamObservable parent, Stream<T> stream, Duration duration) {
    this.parent = parent;
    bool _closeAfterNextEvent = false;
    Timer _timer;

    setStream(stream.transform(new StreamTransformer<T, T>(
        (Stream<T> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<T> subscription;

        controller = new StreamController<T>(sync: true,
            onListen: () {
              subscription = input.listen((T value) {
                if (_timer != null && _timer.isActive) _timer.cancel();

                _timer = new Timer(duration, () {
                  controller.add(value);

                  if (_closeAfterNextEvent) controller.close();
                });
              },
              onError: (e, s) => throwError(e, s),
              onDone: () {
                _closeAfterNextEvent = true;
              },
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