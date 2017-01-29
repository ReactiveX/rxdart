import 'dart:async';

StreamTransformer<T, T> tapTransformer<T>(void action(T value)) {
  return new StreamTransformer<T, T>.fromHandlers(
      handleData: (T data, EventSink<T> sink) {
    action(data);

    sink.add(data);
  });
}
