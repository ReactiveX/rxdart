import 'dart:async';

StreamTransformer<T, T> repeatTransformer<T>(int repeatCount) {
  return new StreamTransformer<T, T>.fromHandlers(
      handleData: (T data, EventSink<T> sink) {
    for (int i = 0; i < repeatCount; i++) sink.add(data);
  });
}
