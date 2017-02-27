import 'dart:async';

class RepeatStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  RepeatStreamTransformer(int repeatCount)
      : transformer = _buildTransformer(repeatCount);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(int repeatCount) {
    return new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
      for (int i = 0; i < repeatCount; i++) sink.add(data);
    });
  }
}
