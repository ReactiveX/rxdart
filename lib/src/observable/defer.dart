import 'package:rxdart/src/observable.dart';

class DeferObservable<T> extends Observable<T> {
  DeferObservable(StreamProvider<T> streamProvider)
      : super(buildStream(streamProvider));

  static Stream<T> buildStream<T>(StreamProvider<T> streamProvider) {
    StreamController<T> controller;
    Stream<T> stream = streamProvider();
    bool hasListened = false;

    controller = new StreamController<T>(onListen: () {
      if (!hasListened) {
        stream.listen(controller.add,
            onError: controller.addError, onDone: controller.close);
      }
    });

    return stream.isBroadcast
        ? controller.stream.asBroadcastStream()
        : controller.stream;
  }
}

typedef Stream<T> StreamProvider<T>();
