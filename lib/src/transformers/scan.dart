import 'package:rxdart/src/observable.dart';

StreamTransformer<T, S> scanTransformer<T, S>(
    Stream<T> stream, S predicate(S accumulated, T value, int index),
    [S seed]) {
  int index = 0;
  S acc = seed;

  return new StreamTransformer<T, S>.fromHandlers(
      handleData: (T data, EventSink<S> sink) {
    acc = predicate(acc, data, index++);

    sink.add(acc);
  });
}
