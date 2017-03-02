import 'dart:async';

class ConcatStream<T> extends Stream<T> {
  final StreamController<T> controller;

  ConcatStream(Iterable<Stream<T>> streams)
      : controller = _buildController(streams);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  static StreamController<T> _buildController<T>(Iterable<Stream<T>> streams) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          final int len = streams.length;
          int index = 0;

          void moveNext() {
            Stream<T> stream = streams.elementAt(index);
            subscription?.cancel();

            subscription = stream.listen(controller.add,
                onError: controller.addError, onDone: () {
              index++;

              if (index == len)
                controller.close();
              else
                moveNext();
            });
          }

          moveNext();
        },
        onCancel: () => subscription.cancel());

    return controller;
  }
}
