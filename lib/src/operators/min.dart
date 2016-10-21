library rx.operators.min;

import 'package:rxdart/src/observable/stream.dart';

class MinObservable<T> extends StreamObservable<T> {

  MinObservable(StreamObservable parent, Stream<T> stream, [int compare(T a, T b)]) {
    this.parent = parent;
    T _currentMin;

    setStream(stream.transform(new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
          if (_currentMin == null) {
            _currentMin = data;

            sink.add(data);
          }
          else {
            if (compare != null) {
              if (compare(data, _currentMin) < 0) {
                _currentMin = data;

                sink.add(data);
              }
            } else {
              try {
                Comparable currMin = _currentMin as Comparable,
                    testMin = data as Comparable;

                if (testMin.compareTo(currMin) < 0) {
                  _currentMin = data;

                  sink.add(data);
                }
              } catch (error) {
                throwError(error, error.stackTrace);
              }
            }
          }
        }
    )));
  }

}