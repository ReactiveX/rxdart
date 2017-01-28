import 'package:rxdart/src/observable/stream.dart';

class ScanObservable<T, S> extends StreamObservable<S> {
  ScanObservable(
      Stream<T> stream, S predicate(S accumulated, T value, int index),
      [S seed])
      : super(buildStream<T, S>(stream, predicate, seed));

  static Stream<S> buildStream<T, S>(
      Stream<T> stream, S predicate(S accumulated, T value, int index),
      [S seed]) {
    int index = 0;
    S acc = seed;

    return stream.transform(new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
      acc = predicate(acc, data, index++);

      sink.add(acc);
    }));
  }
}
