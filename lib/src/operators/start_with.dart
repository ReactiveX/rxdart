library rx.operators.start_with;

import 'package:rxdart/src/observable/stream.dart';

class StartWithObservable<T> extends StreamObservable<T> {

  StartWithObservable(Stream<T> stream, List<T> startValues) {
    setStream(stream.transform(new StreamTransformer<T, T>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(sync: true,
          onListen: () {
            startValues.forEach(controller.add);

            subscription = input.listen((T data) {
              controller.add(data);
            },
                onError: (dynamic e, dynamic s) => controller.addError(e, s),
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: () => subscription.pause(),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    }
    )));
  }

}