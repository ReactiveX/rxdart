import 'dart:async';

class MergeStream<T> extends Stream<T> {
  final Iterable<Stream<T>> streams;

  MergeStream(this.streams);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
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

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
