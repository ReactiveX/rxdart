library rx.operators.flat_map_latest;

import 'package:rxdart/src/observable/stream.dart';

class FlatMapLatestObservable<T, S> extends StreamObservable<S> {

  bool _closeAfterNextEvent = false;

  FlatMapLatestObservable(Stream<T> stream, Stream<S> predicate(T value)) {
    setStream(stream.transform(new StreamTransformer<T, S>(
        (Stream<T> input, bool cancelOnError) {
          StreamController<S> controller;
          StreamSubscription<T> subscription;
          StreamSubscription<S> otherSubscription;

          controller = new StreamController<S>(sync: true,
              onListen: () {
                subscription = input.listen((T value) {
                  otherSubscription?.cancel();

                  StreamObservable<S> observable = new StreamObservable<S>()..setStream(predicate(value));

                  otherSubscription = observable
                      .listen((S otherValue) => controller.add(otherValue),
                      onError: (dynamic e, dynamic s) => controller.addError(e, s),
                      onDone: () {
                        if (_closeAfterNextEvent) controller.close();
                      });
                },
                    onError: (dynamic e, dynamic s) => controller.addError(e, s),
                    onDone: () => _closeAfterNextEvent = true,
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