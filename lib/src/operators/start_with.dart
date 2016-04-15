library rx.operators.start_with;

import 'package:rxdart/src/observable/stream.dart';

class StartWithObservable<T> extends StreamObservable<T> {

  StartWithObservable(Stream<T> stream, List<T> startValues) {
    controller = new StreamController<T>(sync: true,
        onListen: () {
          startValues.forEach(controller.add);

          subscription = stream.listen(controller.add,
            onError: (e, s) => throwError(e, s),
            onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}