import 'package:rxdart/src/observable/stream.dart';

class AmbObservable<T> extends StreamObservable<T> with ControllerMixin<T> {
  StreamController<T> _controller;

  AmbObservable(Iterable<Stream<T>> streams, bool asBroadcastStream) {
    final List<StreamSubscription<T>> subscriptions =
        new List<StreamSubscription<T>>(streams.length);
    bool isDisambiguated = false;

    _controller = new StreamController<T>(
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

            _controller.add(value);
          }

          for (int i = 0, len = streams.length; i < len; i++) {
            Stream<T> stream = streams.elementAt(i);

            subscriptions[i] = stream.listen((T value) => doUpdate(i, value),
                onError: _controller.addError,
                onDone: () => _controller.close());
          }
        },
        onCancel: () =>
            Future.wait(subscriptions.map((StreamSubscription<T> subscription) {
              if (subscription != null) return subscription.cancel();

              return new Future<dynamic>.value();
            }).where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    setStream(asBroadcastStream
        ? _controller.stream.asBroadcastStream()
        : _controller.stream);
  }
}
