library rx.operators.flat_map_latest;

import 'package:rxdart/src/observable/stream.dart';

class FlatMapLatestObservable<T, S> extends StreamObservable<S> {

  FlatMapLatestObservable(Stream<T> stream, Stream<S> predicate(T value)) {
    bool _closeAfterNextEvent = false;

    setStream(stream.transform(new StreamTransformer<T, S>(
      (Stream<T> input, bool cancelOnError) {
        StreamController<S> controller;
        StreamSubscription<T> subscription;
        StreamSubscription<S> otherSubscription;

        controller = new StreamController<S>(sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              otherSubscription?.cancel();

              otherSubscription = predicate(value)
                .listen(controller.add,
                  onError: controller.addError,
                  onDone: () {
                    if (_closeAfterNextEvent) controller.close();
                  });
              },
                onError: controller.addError,
                onDone: () => _closeAfterNextEvent = true,
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
            onCancel: () => Future.wait(<Future<dynamic>>[
              subscription.cancel(),
              otherSubscription?.cancel()
            ].where((Future<dynamic> cancelFuture) => cancelFuture != null))
            );

        return controller.stream.listen(null);
      }
    )));
  }

}