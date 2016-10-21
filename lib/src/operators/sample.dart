library rx.operators.sample;

import 'package:rxdart/src/observable/stream.dart';

class SampleObservable<T> extends StreamObservable<T> {

  SampleObservable(StreamObservable parent, Stream<T> stream, Stream sampleStream) {
    this.parent = parent;

    setStream(stream.transform(new StreamTransformer<T, T>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription sampleSubscription;
      T currentValue;

      controller = new StreamController<T>(sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              currentValue = value;
            },
                onError: throwError);

            sampleSubscription = sampleStream.listen((_) {
              if (currentValue != null) controller.add(currentValue);
            },
                onError: throwError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: () => subscription.pause(),
          onResume: () => subscription.resume(),
          onCancel: () {
            return Future.wait([
              subscription.cancel(),
              sampleSubscription.cancel()
            ].where((Future cancelFuture) => cancelFuture != null));
          });

      return controller.stream.listen(null);
    }
    )));
  }

}