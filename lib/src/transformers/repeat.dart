import 'package:rxdart/src/observable.dart';

StreamTransformer<T, T> repeatTransformer<T>(
    Stream<T> stream, int repeatCount) {
  return new StreamTransformer<T, T>.fromHandlers(
      handleData: (T data, EventSink<T> sink) {
    for (int i = 0; i < repeatCount; i++) sink.add(data);
  });
}
