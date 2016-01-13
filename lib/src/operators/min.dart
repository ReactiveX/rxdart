library rx.operators.min;

import 'package:rxdart/src/observable/stream.dart';

class MinObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  T _currentMin;

  MinObservable(Stream<T> stream, [int compare(T a, T b)]) {
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            if (compare == null && !(value is Comparable)) {
              final ArgumentError error = new ArgumentError('Stream value is not of type Comparable and missing compare function');

              throwError(error, error.stackTrace);
            }

            if (_currentMin == null) updateValue(value);
            else {
              if (compare != null) {
                if (compare(value, _currentMin) < 0) updateValue(value);
              } else {
                try {
                  Comparable currMin = _currentMin as Comparable, testMin = value as Comparable;

                  if (testMin.compareTo(currMin) < 0) updateValue(value);
                } catch (error) {
                  throwError(error, error.stackTrace);
                }
              }
            }
          },
              onError: (e, s) => throwError(e, s),
              onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);

  }

  void updateValue(T newMin) {
    _currentMin = newMin;

    controller.add(newMin);
  }

}