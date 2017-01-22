import 'package:rxdart/src/observable/stream.dart';

class MinObservable<T> extends StreamObservable<T> {
  MinObservable(Stream<T> stream, [int compare(T a, T b)]) {
    T _currentMin;

    setStream(stream.transform(new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
      if (_currentMin == null) {
        _currentMin = data;

        sink.add(data);
      } else {
        if (compare != null) {
          if (compare(data, _currentMin) < 0) {
            _currentMin = data;

            sink.add(data);
          }
        } else {
          try {
            T currMin = _currentMin, testMin = data;

            if (testMin is Comparable<dynamic> &&
                testMin.compareTo(currMin) < 0) {
              _currentMin = data;

              sink.add(data);
            }
          } catch (error) {
            sink.addError(error, error.stackTrace);
          }
        }
      }
    })));
  }
}
