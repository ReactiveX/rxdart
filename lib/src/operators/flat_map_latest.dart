import 'package:rxdart/src/observable/stream.dart';

class FlatMapLatestObservable<T, S> extends StreamObservable<S> {

  FlatMapLatestObservable(Stream<T> stream, Stream<S> predicate(T value)) {
    bool _leftClosed = false, _rightClosed = false;

    setStream(stream.transform(new StreamTransformer<T, S>(
      (Stream<T> input, bool cancelOnError) {
        StreamController<S> controller;
        StreamSubscription<T> subscription;
        StreamSubscription<S> otherSubscription;

        controller = new StreamController<S>(sync: true,
          onListen: () {
            subscription = input.listen((T value) async {
              await otherSubscription?.cancel();

              otherSubscription = predicate(value)
                .listen(controller.add,
                  onError: controller.addError,
                  onDone: () {
                    _rightClosed = true;

                    if (_leftClosed) controller.close();
                  });
              },
                onError: controller.addError,
                onDone: () {print('cloing left');
                  _leftClosed = true;

                  if (_rightClosed) controller.close();
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
              await otherSubscription?.cancel();
            });

        return controller.stream.listen(null);
      }
    )));
  }

}