import 'package:rxdart/src/observable/stream.dart';

class RepeatObservable<T> extends StreamObservable<T> {
  RepeatObservable(Stream<T> stream, int repeatCount) {
    setStream(stream.transform(new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
      for (int i = 0; i < repeatCount; i++) sink.add(data);
    })));
  }
}
