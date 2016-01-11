library rx.operators.scan;

import 'package:rxdart/src/observable/stream.dart';

class ScanObservable<T, S> extends StreamObservable<T> {

  StreamController<S> controller;

  ScanObservable(Stream<T> stream, S predicate(S accumulated, T value, int index), [S seed]) {
    StreamSubscription<T> subscription;
    int index = 0;
    S acc = seed;

    controller = new StreamController<S>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            acc = (acc == null) ? value : predicate(acc, value, index++);

            controller.add(acc);
          },
          onError: (e, s) => controller.addError(e, s),
          onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}