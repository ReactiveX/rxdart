library rx.operators.start_with;

import 'package:rxdart/src/observable/stream.dart';

class StartWithObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StartWithObservable(Stream<T> stream, T startValue) {
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen(controller.add,
            onError: (e, s) => throwError(e, s),
            onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    controller.add(startValue);

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}