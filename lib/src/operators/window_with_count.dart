import 'package:rxdart/src/observable/stream.dart';

class WindowWithCountObservable<T, S extends StreamObservable<T>>
    extends StreamObservable<S> {
  StreamObservable<T> observable;

  WindowWithCountObservable(Stream<T> stream, int count, [int skip]) {
    setStream(stream.transform(
        new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<Iterable<T>> subscription;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            if (!(input is StreamObservable))
              observable = new StreamObservable<T>()..setStream(input);

            subscription = observable.bufferWithCount(count, skip).listen(
                (Iterable<T> value) {
              controller.add(new StreamObservable<T>()
                ..setStream(new Stream<T>.fromIterable(value)));
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
    })));
  }
}
