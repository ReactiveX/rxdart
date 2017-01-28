import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/observable/stream.dart';

class WindowWithCountObservable<T, S extends StreamObservable<T>>
    extends StreamObservable<S> {
  WindowWithCountObservable(Stream<T> stream, int count, [int skip])
      : super(buildStream(stream, count, skip));

  static Stream<S> buildStream<T, S extends StreamObservable<T>>(
      Stream<T> stream, int count,
      [int skip]) {
    StreamObservable<T> observable;

    return stream.transform(
        new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<Iterable<T>> subscription;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            if (!(input is StreamObservable))
              observable = new StreamObservable<T>(input);

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
    }));
  }
}
