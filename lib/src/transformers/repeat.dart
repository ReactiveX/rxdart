import 'dart:async';

/// A StreamTransformer that repeats the source's elements the specified
/// number of times.
///
/// ### Example
///
///     new Stream.fromIterable([1])
///       .transform(new RepeatStreamTransformer(3))
///       .listen(print); // prints 1, 1, 1
class RepeatStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  RepeatStreamTransformer(int repeatCount)
      : transformer = _buildTransformer(repeatCount);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(int repeatCount) {
    if (repeatCount == null) {
      throw new ArgumentError('repeatCount cannot be null');
    }

    return new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
          for (int i = 0; i < repeatCount; i++) sink.add(data);
        },
        handleError: (Object error, StackTrace s, EventSink<T> sink) =>
            sink.addError(error));
  }
}
