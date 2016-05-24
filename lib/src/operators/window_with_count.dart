library rx.operators.window_with_count;

import 'package:rxdart/src/observable/stream.dart';

class WindowWithCountObservable<T, S extends StreamObservable<T>> extends StreamObservable<S> {

  StreamObservable<T> observable;

  WindowWithCountObservable(StreamObservable parent, Stream<T> stream, int count, [int skip]) {
    this.parent = parent;

    if (!(stream is StreamObservable)) observable = new StreamObservable<T>()..setStream(stream);

    controller = new StreamController<S>(sync: true,
        onListen: () {
          subscription = observable
              .bufferWithCount(count, skip)
              .map((Iterable<T> value) => new StreamObservable<T>()..setStream(new Stream<T>.fromIterable(value)))
              .listen((StreamObservable<T> value) {
                controller.add(value);
              },
            onError: (e, s) => controller.addError(e, s),
            onDone: () => controller.close()) as StreamSubscription<T>;
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}