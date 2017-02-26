import 'dart:async';

class MinStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  MinStreamTransformer([int compare(T a, T b)])
      : transformer = _buildTransformer(compare);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>([int compare(T a, T b)]) {
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
}
