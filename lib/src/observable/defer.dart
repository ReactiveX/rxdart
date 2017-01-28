import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/observable/stream.dart';

class DeferObservable<T> extends StreamObservable<T> {
  DeferObservable(StreamProvider<T> streamProvider)
      : super(buildStream(streamProvider));

  static Stream<T> buildStream<T>(StreamProvider<T> streamProvider) {
    StreamController<T> controller;
    Stream<T> stream = streamProvider();

    controller = new StreamController<T>(onListen: () {
      stream.listen(controller.add,
          onError: controller.addError, onDone: controller.close);
    });

    return stream.isBroadcast
        ? controller.stream.asBroadcastStream()
        : controller.stream;
  }
}

typedef Stream<T> StreamProvider<T>();
