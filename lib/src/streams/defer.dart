import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

class DeferStream<T> extends Stream<T> {
  final StreamFactory<T> streamFactory;

  DeferStream(this.streamFactory);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    StreamController<T> controller;
    Stream<T> stream = streamFactory();
    bool hasListened = false;

    controller = new StreamController<T>(onListen: () {
      if (!hasListened) {
        stream.listen(controller.add,
            onError: controller.addError, onDone: controller.close);
      }
    });

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
