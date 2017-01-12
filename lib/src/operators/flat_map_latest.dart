import 'package:rxdart/src/observable/stream.dart';

class FlatMapLatestObservable<T, S> extends StreamObservable<S> {

  FlatMapLatestObservable(Stream<T> stream, Stream<S> predicate(T value)) {

    setStream(stream.transform(new StreamTransformer<T, S>(
      (Stream<T> input, bool cancelOnError) {
        StreamController<S> controller;
        StreamSubscription<T> subscription;
        StreamSubscription<S> otherSubscription;
        bool leftClosed = false, rightClosed = false;
        bool hasMainEvent = false;

        controller = new StreamController<S>(sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              otherSubscription?.cancel();

              hasMainEvent = true;

              otherSubscription = predicate(value)
                .listen(controller.add,
                  onError: controller.addError,
                  onDone: () {
                    rightClosed = true;

                    if (leftClosed) controller.close();
                  });
              },
                onError: controller.addError,
                onDone: () {
                  leftClosed = true;

                  if (rightClosed || !hasMainEvent) controller.close();
                },
                cancelOnError: cancelOnError);
          },
            onPause: ([Future<dynamic> resumeSignal]) {
              subscription.pause(resumeSignal);
              otherSubscription?.pause(resumeSignal);
            },
            onResume: () {
              subscription.resume();
              otherSubscription?.resume();
            },
            onCancel: () async {
              await subscription.cancel();

              if (hasMainEvent) await otherSubscription.cancel();
            });

        return controller.stream.listen(null);
      }
    )));
  }

}