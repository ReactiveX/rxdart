import 'package:rxdart/src/observable.dart';

class ConcatObservable<T> extends Observable<T> {
  ConcatObservable(Iterable<Stream<T>> streams, bool asBroadcastStream)
      : super(buildStream<T>(streams, asBroadcastStream));

  static Stream<T> buildStream<T>(
      Iterable<Stream<T>> streams, bool asBroadcastStream) {
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

    return asBroadcastStream
        ? controller.stream.asBroadcastStream()
        : controller.stream;
  }
}
