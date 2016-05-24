library rx.operators.flat_map_latest;

import 'package:rxdart/src/observable/stream.dart';

class FlatMapLatestObservable<T, S> extends StreamObservable<S> {

  bool _closeAfterNextEvent = false;

  FlatMapLatestObservable(StreamObservable parent, Stream<T> stream, Stream<S> predicate(T value)) {
    this.parent = parent;

    StreamSubscription<S> otherSubscription;

    stream = stream.asBroadcastStream();

    controller = new StreamController<S>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            otherSubscription?.cancel();

            StreamObservable<S> observable = new StreamObservable<S>()..setStream(predicate(value));

            otherSubscription = observable
                .takeUntil(stream)
                .listen((S otherValue) => controller.add(otherValue),
                onError: (e, s) => controller.addError(e, s),
                onDone: () {
                  if (_closeAfterNextEvent) controller.close();
                });
          },
            onError: (e, s) => controller.addError(e, s),
            onDone: () => _closeAfterNextEvent = true);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}