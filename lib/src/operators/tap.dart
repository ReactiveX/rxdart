library rx.operators.tap;

import 'package:rxdart/src/observable/stream.dart';

class TapObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  TapObservable(StreamObservable parent, Stream<T> stream, void action(T value)) {
    this.parent = parent;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            action(value);

            controller.add(value);
          },
          onError: (e, s) => throwError(e, s),
          onDone: controller.close);
        },
        onCancel: subscription?.cancel);

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}