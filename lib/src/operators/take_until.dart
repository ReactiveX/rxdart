library rx.operators.take_until;

import 'package:rxdart/src/observable/stream.dart';

class TakeUntilObservable<T, S> extends StreamObservable<T> {

  TakeUntilObservable(Stream<T> stream, Stream<S> otherStream) {
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
                onError: (dynamic e, dynamic s) => controller.addError(e, s),
                onDone: controller.close,
                cancelOnError: cancelOnError);

            otherSubscription = otherStream.listen((_) => controller.close(),
                onError: (dynamic e, dynamic s) => controller.addError(e, s),
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