library rx.operators.tap;

import 'package:rxdart/src/observable/stream.dart';

class TapObservable<T> extends StreamObservable<T> {

  TapObservable(StreamObservable parent, Stream<T> stream, void action(T value)) {
    this.parent = parent;

    setStream(stream.transform(new StreamTransformer<T, T>.fromHandlers(
      handleData: (T data, EventSink<T> sink) {
        action(data);

        sink.add(data);
      }
    )));
  }

}