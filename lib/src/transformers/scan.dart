import 'dart:async';

typedef S _ScanStreamTransformerPredicate<T, S>(
    S accumulated, T value, int index);

class ScanStreamTransformer<T, S> implements StreamTransformer<T, S> {
  final _ScanStreamTransformerPredicate<T, S> predicate;
  final S seed;

  ScanStreamTransformer(this.predicate, [this.seed]);

  @override
  Stream<S> bind(Stream<T> stream) =>
      _buildTransformer<T, S>(predicate, seed).bind(stream);

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
