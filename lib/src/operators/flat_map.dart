library rx.operators.flat_map;

import 'package:rxdart/src/observable/stream.dart';

class FlatMapObservable<T, S> extends StreamObservable<S> {

  bool _closeAfterNextEvent = false;

  FlatMapObservable(Stream<T> stream, Stream<S> predicate(T value)) {
    List<Stream<S>> streams = <Stream<S>>[];

    setStream(stream.transform(new StreamTransformer<T, S>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<S>(sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              Stream<S> otherStream = predicate(value);

              streams.add(otherStream);

              otherStream.listen(controller.add,
                  onError: (dynamic e, dynamic s) => controller.addError(e, s),
                  onDone: () {
                    streams.remove(otherStream);

                    if (_closeAfterNextEvent && streams.isEmpty) controller.close();
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