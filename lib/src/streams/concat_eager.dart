import 'dart:async';

class ConcatEagerStream<T> extends Stream<T> {
  final Iterable<Stream<T>> streams;

  ConcatEagerStream(this.streams);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
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

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
