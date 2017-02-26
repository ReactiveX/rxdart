import 'dart:async';

class ScanStreamTransformer<T, S> implements StreamTransformer<T, S> {
  final StreamTransformer<T, S> transformer;

  ScanStreamTransformer(S predicate(S accumulated, T value, int index),
      [S seed])
      : transformer = _buildTransformer(predicate, seed);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      S predicate(S accumulated, T value, int index),
      [S seed]) {
    int index = 0;
    S acc = seed;

    return new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
      acc = predicate(acc, data, index++);

      sink.add(acc);
    });
  }
}
