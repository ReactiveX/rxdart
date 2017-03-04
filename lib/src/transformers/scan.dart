import 'dart:async';

/// Applies an accumulator function over an observable sequence and returns
/// each intermediate result. The optional seed value is used as the initial
/// accumulator value.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///        .transform(new ScanStreamTransformer((acc, curr, i) => acc + curr, 0))
///        .listen(print); // prints 1, 3, 6
class ScanStreamTransformer<T, S> implements StreamTransformer<T, S> {
  final _ScanStreamTransformerAccumulator<T, S> accumulator;
  final S seed;

  ScanStreamTransformer(this.accumulator, [this.seed]);

  @override
  Stream<S> bind(Stream<T> stream) =>
      _buildTransformer<T, S>(accumulator, seed).bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      S accumulator(S accumulated, T value, int index),
      [S seed]) {
    int index = 0;
    S acc = seed;

    return new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
      acc = accumulator(acc, data, index++);

      sink.add(acc);
    });
  }
}

typedef S _ScanStreamTransformerAccumulator<T, S>(
    S accumulated, T value, int index);
