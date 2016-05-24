library rx.operators.flat_map;

import 'package:rxdart/src/observable/stream.dart';

class FlatMapObservable<T, S> extends StreamObservable<S> {

  bool _closeAfterNextEvent = false;

  FlatMapObservable(StreamObservable parent, Stream<T> stream, Stream<S> predicate(T value)) {
    this.parent = parent;

    List<Stream<S>> streams = <Stream<S>>[];

    controller = new StreamController<S>(sync: true,
        onListen: () {
          subscription = stream.listen((T value) {
            Stream<S> otherStream = predicate(value);

            streams.add(otherStream);

            otherStream.listen(controller.add,
                onError: (e, s) => controller.addError(e, s),
                onDone: () {
                  streams.remove(otherStream);

                  if (_closeAfterNextEvent && streams.isEmpty) controller.close();
                });
          },
          onError: (e, s) => controller.addError(e, s),
          onDone: () => _closeAfterNextEvent = true);
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}