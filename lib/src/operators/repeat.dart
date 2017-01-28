import 'package:rxdart/src/observable.dart';

class RepeatObservable<T> extends Observable<T> {
  RepeatObservable(Stream<T> stream, int repeatCount)
      : super(buildStream(stream, repeatCount));

  static Stream<T> buildStream<T>(Stream<T> stream, int repeatCount) {
    return stream.transform(new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
      for (int i = 0; i < repeatCount; i++) sink.add(data);
    }));
  }
}
