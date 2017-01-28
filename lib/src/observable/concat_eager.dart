import 'package:rxdart/src/observable/stream.dart';

class ConcatEagerObservable<T> extends StreamObservable<T>
    {
  ConcatEagerObservable(Iterable<Stream<T>> streams, bool asBroadcastStream)
      : super(buildStream<T>(streams, asBroadcastStream));

  static Stream<T> buildStream<T>(
      Iterable<Stream<T>> streams, bool asBroadcastStream) {
    final List<StreamSubscription<T>> subscriptions =
        new List<StreamSubscription<T>>(streams.length);
    final List<Completer<dynamic>> completeEvents =
        new List<Completer<dynamic>>(streams.length);
    StreamController<T> controller;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          for (int i = 0, len = streams.length; i < len; i++) {
            completeEvents[i] = new Completer<dynamic>();

            subscriptions[i] = streams.elementAt(i).listen(controller.add,
                onError: controller.addError, onDone: () {
              completeEvents[i].complete();

              if (i == len - 1) controller.close();
            });

            if (i > 0) subscriptions[i].pause(completeEvents[i - 1].future);
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
