library rx.operators.window_with_count;

import 'package:rxdart/src/observable/stream.dart';

class WindowWithCountObservable<T, S extends StreamObservable<T>> extends StreamObservable<S> {

  StreamObservable<T> observable;

  WindowWithCountObservable(Stream<T> stream, int count, [int skip]) {
    setStream(stream.transform(new StreamTransformer<T, S>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<S>(sync: true,
          onListen: () {
            if (!(input is StreamObservable)) observable = new StreamObservable<T>()..setStream(input);

            subscription = observable
              .bufferWithCount(count, skip)
              .map((Iterable<T> value) => new StreamObservable<T>()..setStream(new Stream<T>.fromIterable(value)))
              .listen((StreamObservable<T> value) {
                controller.add(value);
              },
                cancelOnError: cancelOnError,
                onError: (dynamic e, dynamic s) => controller.addError(e, s),
                onDone: () => controller.close()) as StreamSubscription<T>;
          },
          onPause: () => subscription.pause(),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    }
    )));
  }

}