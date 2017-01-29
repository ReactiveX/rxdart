import 'package:rxdart/src/observable.dart';

class DeferStream<T> extends Stream<T> {
  final StreamProvider<T> streamProvider;

  DeferStream(this.streamProvider);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    StreamController<T> controller;
    Stream<T> stream = streamProvider();
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

typedef Stream<T> StreamProvider<T>();
