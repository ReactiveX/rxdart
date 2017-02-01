import 'dart:async';

StreamTransformer<T, T> minTransformer<T>([int compare(T a, T b)]) {
  T _currentMin;

  return new StreamTransformer<T, T>.fromHandlers(
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
  });
}
