import 'dart:async';

StreamTransformer<T, int> countTransformer<T>([bool predicate(T event)]) {
  int _index = 0;

  predicate ??= (T event) => true;

  return new StreamTransformer<T, int>.fromHandlers(
      handleData: (T data, EventSink<int> sink) {
    if (predicate(data)) sink.add(++_index);
  });
}
