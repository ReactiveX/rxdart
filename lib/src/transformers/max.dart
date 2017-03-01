import 'dart:async';

typedef int _MaxStreamTransformerCompare<T>(T a, T b);

class MaxStreamTransformer<T> implements StreamTransformer<T, T> {
  final _MaxStreamTransformerCompare<T> compare;

  MaxStreamTransformer([this.compare]);

  @override
  Stream<T> bind(Stream<T> stream) => _buildTransformer<T>(compare).bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>([int compare(T a, T b)]) {
    T _currentMax;

    return new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
      if (_currentMax == null) {
        _currentMax = data;

        sink.add(data);
      } else {
        if (compare != null) {
          if (compare(data, _currentMax) > 0) {
            _currentMax = data;

            sink.add(data);
          }
        } else {
          try {
            T currMax = _currentMax, testMax = data;

            if (testMax is Comparable<dynamic> &&
                testMax.compareTo(currMax) > 0) {
              _currentMax = data;

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
