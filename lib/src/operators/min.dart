import 'package:rxdart/src/observable.dart';

class MinObservable<T> extends Observable<T> {
  MinObservable(Stream<T> stream, [int compare(T a, T b)])
      : super(buildStream<T>(stream, compare));

  static Stream<T> buildStream<T>(Stream<T> stream, [int compare(T a, T b)]) {
    T _currentMin;

    return stream.transform(new StreamTransformer<T, T>.fromHandlers(
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
            sink.addError(error);
          }
        }
      }
    }));
  }
}
