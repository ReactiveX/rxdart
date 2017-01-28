import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/observable.dart';

StreamTransformer<T, S> windowWithCountTransformer<T, S extends Observable<T>>(
    Stream<T> stream, int count,
    [int skip]) {
  Observable<T> observable;

  return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
    StreamController<S> controller;
    StreamSubscription<Iterable<T>> subscription;

    controller = new StreamController<S>(
        sync: true,
        onListen: () {
          if (!(input is Observable))
            observable = new Observable<T>(input);
          else
            observable = input;

          subscription = observable.bufferWithCount(count, skip).listen(
              (Iterable<T> value) {
            controller.add(new Observable<T>.fromIterable(value));
          },
              cancelOnError: cancelOnError,
              onError: controller.addError,
              onDone: controller.close);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream.listen(null);
  });
}
