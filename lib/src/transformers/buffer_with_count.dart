import 'dart:async';

StreamTransformer<T, S> bufferWithCountTransformer<T, S extends List<T>>(
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
