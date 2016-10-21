library rx.operators.buffer_with_count;

import 'package:rxdart/src/observable/stream.dart';

class BufferWithCountObservable<T, S extends List<T>> extends StreamObservable<S> {

  final int count;
  int skipAmount, bufferKeep;

  BufferWithCountObservable(StreamObservable parent, Stream<T> stream, int count, [int skip]) : this.count = count {
    this.parent = parent;

    skipAmount = ((skip == null) ? count : skip);

    if (skipAmount <= 0 || skipAmount > count) {
      final ArgumentError error = new ArgumentError('skip has to be greater than zero and smaller than count');

      controller.addError(error, error.stackTrace);
    }

    bufferKeep = count - ((skip == null) ? count : skip);
    S buffer = <T>[] as S;

    setStream(stream.transform(new StreamTransformer<T, S>.fromHandlers(
      handleData: (T data, EventSink<S> sink) {
        buffer.add(data);

        if (buffer.length == count) {
          sink.add(buffer);

          buffer = buffer.sublist(count - bufferKeep);
        }
      }, handleDone: (EventSink<S> sink) {
        if (buffer.isNotEmpty) sink.add(buffer);
      }
    )));
  }

}