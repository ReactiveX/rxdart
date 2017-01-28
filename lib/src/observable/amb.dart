import 'package:rxdart/src/observable/stream.dart';

class AmbObservable<T> extends StreamObservable<T> {
  AmbObservable(Iterable<Stream<T>> streams, bool asBroadcastStream)
      : super(buildStream<T>(streams, asBroadcastStream));

  static Stream<T> buildStream<T>(
      Iterable<Stream<T>> streams, bool asBroadcastStream) {
    final List<StreamSubscription<T>> subscriptions =
        new List<StreamSubscription<T>>(streams.length);
    StreamController<T> controller;
    bool isDisambiguated = false;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          void doUpdate(int i, T value) {
            if (!isDisambiguated)
              for (int k = 0, len = subscriptions.length; k < len; k++) {
                if (k != i) {
                  subscriptions[k].cancel();
                  subscriptions[k] = null;
                }
              }

            isDisambiguated = true;

            controller.add(value);
          }

          for (int i = 0, len = streams.length; i < len; i++) {
            Stream<T> stream = streams.elementAt(i);

            subscriptions[i] = stream.listen((T value) => doUpdate(i, value),
                onError: controller.addError, onDone: () => controller.close());
          }
        },
        onCancel: () =>
            Future.wait(subscriptions.map((StreamSubscription<T> subscription) {
              if (subscription != null) return subscription.cancel();

              return new Future<dynamic>.value();
            }).where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    return asBroadcastStream
        ? controller.stream.asBroadcastStream()
        : controller.stream;
  }
}
