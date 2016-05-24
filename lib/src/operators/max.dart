library rx.operators.max;

import 'package:rxdart/src/observable/stream.dart';

class MaxObservable<T> extends StreamObservable<T> {

  T _currentMax;

  MaxObservable(StreamObservable parent, Stream<T> stream, [int compare(T a, T b)]) {
    this.parent = parent;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            if (_currentMax == null) updateValue(value);
            else {
              if (compare != null) {
                if (compare(value, _currentMax) > 0) updateValue(value);
              } else {
                try {
                  Comparable currMax = _currentMax as Comparable,
                      testMax = value as Comparable;

                  if (testMax.compareTo(currMax) > 0) updateValue(value);
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

  void updateValue(T newMax) {
    _currentMax = newMax;

    controller.add(newMax);
  }

}