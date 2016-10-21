library rx.operators.max;

import 'package:rxdart/src/observable/stream.dart';

class MaxObservable<T> extends StreamObservable<T> {

  MaxObservable(Stream<T> stream, [int compare(T a, T b)]) {
    T _currentMax;

    setStream(stream.transform(new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
          if (_currentMax == null) {
            _currentMax = data;

            sink.add(data);
          }
          else {
            if (compare != null) {
              if (compare(data, _currentMax) > 0) {
                _currentMax = data;

                sink.add(data);
              }
            } else {
              try {
                T currMax = _currentMax,
                    testMax = data;

                if ((testMax as Comparable<dynamic>).compareTo(currMax) > 0) {
                  _currentMax = data;

                  sink.add(data);
                }
              } catch (error) {
                sink.addError(error, error.stackTrace);
              }
            }
          }
        }
    )));
  }

}