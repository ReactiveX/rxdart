import 'package:rxdart/src/observable/stream.dart';

class TapObservable<T> extends StreamObservable<T> {

  TapObservable(Stream<T> stream, void action(T value)) {
    setStream(stream.transform(new StreamTransformer<T, T>.fromHandlers(
      handleData: (T data, EventSink<T> sink) {
        action(data);

        sink.add(data);
      }
    )));
  }

}