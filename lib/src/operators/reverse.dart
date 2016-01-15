library rx.operators.reverse;

import 'package:rxdart/src/observable/stream.dart';

class ReverseObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  ReverseObservable(Stream<T> stream) {
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          StreamObservable<T> observable = (new StreamObservable<T>()..setStream(stream)).replay();
          List<T> replayedValues = <T>[];

          observable.listen(replayedValues.add);

          subscription = stream.listen((T value) => replayedValues.reversed.forEach(controller.add),
            onError: controller.addError,
            onDone: controller.close);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}