import 'package:rxdart/src/observable/stream.dart';

class MergeObservable<T> extends StreamObservable<T> {
  MergeObservable(Iterable<Stream<T>> streams, bool asBroadcastStream)
      : super(buildStream<T>(streams, asBroadcastStream));

  static Stream<T> buildStream<T>(
      Iterable<Stream<T>> streams, bool asBroadcastStream) {
    final List<StreamSubscription<T>> subscriptions =
        new List<StreamSubscription<T>>(streams.length);
    StreamController<T> controller;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          final List<bool> completedStatus =
              new List<bool>.generate(streams.length, (_) => false);

          for (int i = 0, len = streams.length; i < len; i++) {
            subscriptions[i] = streams.elementAt(i).listen(controller.add,
                onError: controller.addError, onDone: () {
              completedStatus[i] = true;

              if (completedStatus.reduce((bool a, bool b) => a && b))
                controller.close();
            });
          }
        },
        onCancel: () => Future.wait(subscriptions
            .map((StreamSubscription<T> subscription) => subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    return asBroadcastStream
        ? controller.stream.asBroadcastStream()
        : controller.stream;
  }
}
