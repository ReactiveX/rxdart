import 'dart:async';

class MaxStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  MaxStreamTransformer([int compare(T a, T b), bool sync])
      : transformer = _buildTransformer(compare);

  @override
  Stream<T> bind(Stream<T> stream) {
    return transformer.bind(stream);
  }

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
