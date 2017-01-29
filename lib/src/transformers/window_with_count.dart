import 'dart:async';

import 'package:rxdart/src/transformers/buffer_with_count.dart';

StreamTransformer<T, S> windowWithCountTransformer<T, S extends Stream<T>>(
    int count,
    [int skip]) {
  return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
    StreamController<S> controller;
    StreamSubscription<Iterable<T>> subscription;

    controller = new StreamController<S>(
        sync: true,
        onListen: () {
          subscription = input
              .transform(bufferWithCountTransformer(count, skip))
              .listen((Iterable<T> value) {
            controller.add(new Stream<T>.fromIterable(value));
          },
                  cancelOnError: cancelOnError,
                  onError: controller.addError,
                  onDone: controller.close);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream.listen(null);
  });
}
