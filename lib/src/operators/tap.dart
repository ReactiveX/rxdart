import 'package:rxdart/src/observable.dart';

class TapObservable<T> extends Observable<T> {
  TapObservable(Stream<T> stream, void action(T value))
      : super(buildStream(stream, action));

  static Stream<T> buildStream<T>(Stream<T> stream, void action(T value)) {
    return stream.transform(new StreamTransformer<T, T>.fromHandlers(
        handleData: (T data, EventSink<T> sink) {
      action(data);

      sink.add(data);
    }));
  }
}
