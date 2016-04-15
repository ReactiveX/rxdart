library rx.operators.take_until;

import 'package:rxdart/src/observable/stream.dart';

class TakeUntilObservable<T, S> extends StreamObservable<T> {

  TakeUntilObservable(Stream<T> stream, Stream<S> otherStream) {
    StreamSubscription<S> otherSubscription;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen(controller.add,
              onError: (e, s) => throwError(e, s),
              onDone: controller.close);

          otherSubscription = otherStream.listen((_) => controller.close(),
              onError: (e, s) => throwError(e, s));
        },
        onCancel: () {
          subscription.cancel();
          otherSubscription.cancel();
        });

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}