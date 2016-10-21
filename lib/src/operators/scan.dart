library rx.operators.scan;

import 'package:rxdart/src/observable/stream.dart';

class ScanObservable<T, S> extends StreamObservable<S> {

  ScanObservable(Stream<T> stream, S predicate(S accumulated, T value, int index), [S seed]) {
    int index = 0;
    S acc = seed;

    setStream(stream.transform(new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
          try {
            acc = predicate(acc, data, index++);

            sink.add(acc);
          } catch (error) {
            sink.addError(error, error.stackTrace);
          }
        }
    )));
  }

}