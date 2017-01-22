import 'package:rxdart/src/observable/stream.dart';

class BufferWithCountObservable<T, S extends List<T>>
    extends StreamObservable<S> {
  final int count;
  int skipAmount, bufferKeep;

  BufferWithCountObservable(Stream<T> stream, int count, [int skip])
      : this.count = count {
    skipAmount = ((skip == null) ? count : skip);

    if (skipAmount <= 0 || skipAmount > count) {
      throw new ArgumentError(
          'skip has to be greater than zero and smaller than count');
    }

    bufferKeep = count - ((skip == null) ? count : skip);
    List<T> buffer = <T>[];

    setStream(stream.transform(new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
      buffer.add(data);

      if (buffer.length == count) {
        sink.add(buffer);

        buffer = buffer.sublist(count - bufferKeep);
      }
    }, handleDone: (EventSink<S> sink) {
      if (buffer.isNotEmpty) sink.add(buffer);
    })));
  }
}
