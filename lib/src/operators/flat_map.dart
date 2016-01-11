library rx.operators.flat_map;

import 'package:rxdart/src/observable/stream.dart';

class FlatMapObservable<T, S> extends StreamObservable<T> {

  StreamController<S> controller;
  Stream<S> _otherStream;
  bool _closeAfterNextEvent = false;

  FlatMapObservable(Stream<T> stream, Stream<S> predicate(T value)) {
    StreamSubscription<T> subscription;

    controller = new StreamController<S>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            _otherStream = predicate(value);

            _otherStream.listen((S otherValue) => controller.add(otherValue),
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