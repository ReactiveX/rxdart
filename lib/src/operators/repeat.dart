library rx.operators.repeat;

import 'package:rxdart/src/observable/stream.dart';

class RepeatObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  RepeatObservable(Stream<T> stream, int repeatCount) {
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            for (int i=0; i<repeatCount; i++) controller.add(value);
          },
          onError: (e, s) => throwError(e, s),
          onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}