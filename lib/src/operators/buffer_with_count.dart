library rx.operators.buffer_with_count;

import 'package:rxdart/src/observable/stream.dart';

class BufferWithCountObservable<T, S extends List<T>> extends StreamObservable<S> {

  final int count;
  int skipAmount, bufferKeep;

  BufferWithCountObservable(Stream<T> stream, int count, [int skip]) : this.count = count {
    skipAmount = ((skip == null) ? count : skip);
    bufferKeep = count - ((skip == null) ? count : skip);
    List<T> buffer = <T>[];

    setStream(stream.transform(new StreamTransformer<T, S>.fromHandlers(
      handleData: (T data, EventSink<S> sink) {
        if (skipAmount <= 0 || skipAmount > count) {
          final ArgumentError error = new ArgumentError('skip has to be greater than zero and smaller than count');

          sink.addError(error, error.stackTrace);
        }

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