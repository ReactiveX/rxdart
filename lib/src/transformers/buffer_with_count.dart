import 'dart:async';

class BufferWithCountStreamTransformer<T, S extends List<T>>
    implements StreamTransformer<T, S> {
  final StreamTransformer<T, S> transformer;

  BufferWithCountStreamTransformer(int count, [int skip])
      : transformer = _buildTransformer(count, skip);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S extends List<T>>(
      int count,
      [int skip]) {
    final int skipAmount = ((skip == null) ? count : skip);

    if (skipAmount <= 0 || skipAmount > count) {
      throw new ArgumentError(
          'skip has to be greater than zero and smaller than count');
    }

    final int bufferKeep = count - ((skip == null) ? count : skip);
    List<T> buffer = <T>[];

    return new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
      buffer.add(data);

      if (buffer.length == count) {
        sink.add(buffer);

        buffer = buffer.sublist(count - bufferKeep);
      }
    }, handleDone: (EventSink<S> sink) {
      if (buffer.isNotEmpty) sink.add(buffer);
    });
  }
}
