import 'package:rxdart/src/observable.dart';

StreamTransformer<T, T> tapTransformer<T>(
    Stream<T> stream, void action(T value)) {
  return new StreamTransformer<T, T>.fromHandlers(
      handleData: (T data, EventSink<T> sink) {
    action(data);

    sink.add(data);
  });
}
