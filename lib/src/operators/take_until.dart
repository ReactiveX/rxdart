library rx.operators.take_until;

import 'package:rxdart/src/observable/stream.dart';

class TakeUntilObservable<T, S> extends StreamObservable<T> {

  TakeUntilObservable(StreamObservable parent, Stream<T> stream, Stream<S> otherStream) {
    this.parent = parent;

    setStream(stream.transform(new StreamTransformer<T, T>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> otherSubscription;

      controller = new StreamController<T>(sync: true,
          onListen: () {
            subscription = stream.listen((T data) {
              controller.add(data);
            },
                onError: (e, s) => throwError(e, s),
                onDone: controller.close,
                cancelOnError: cancelOnError);

            otherSubscription = otherStream.listen((_) => controller.close(),
                onError: (e, s) => throwError(e, s),
                cancelOnError: cancelOnError);
          },
          onPause: () => subscription.pause(),
          onResume: () => subscription.resume(),
          onCancel: () {
            subscription.cancel();
            otherSubscription.cancel();
          });

      return controller.stream.listen(null);
    }
    )));
  }

}