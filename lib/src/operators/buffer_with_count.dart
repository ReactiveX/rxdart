import 'package:rxdart/src/observable.dart';

class BufferWithCountObservable<T, S extends List<T>> extends Observable<S> {
  BufferWithCountObservable(Stream<T> stream, int count, [int skip])
      : super(buildStream<T, S>(stream, count, skip));

  static Stream<S> buildStream<T, S extends List<T>>(
      Stream<T> stream, int count,
      [int skip]) {
    final int skipAmount = ((skip == null) ? count : skip);

    if (skipAmount <= 0 || skipAmount > count) {
      throw new ArgumentError(
          'skip has to be greater than zero and smaller than count');
    }

    final int bufferKeep = count - ((skip == null) ? count : skip);
    List<T> buffer = <T>[];

    return stream.transform(new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
      buffer.add(data);

      if (buffer.length == count) {
        sink.add(buffer);

        buffer = buffer.sublist(count - bufferKeep);
      }
    }, handleDone: (EventSink<S> sink) {
      if (buffer.isNotEmpty) sink.add(buffer);
    }));
  }
}
