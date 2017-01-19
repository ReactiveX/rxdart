import 'package:rxdart/src/observable/stream.dart';

class ConcatEagerObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;

  ConcatEagerObservable(Iterable<Stream<T>> streams, bool asBroadcastStream) {
    final List<StreamSubscription<T>> subscriptions = new List<StreamSubscription<T>>(streams.length);
    final List<Completer<dynamic>> completeEvents = new List<Completer<dynamic>>(streams.length);

    _controller = new StreamController<T>(sync: true,
        onListen: () {
          for (int i=0, len=streams.length; i<len; i++) {
            completeEvents[i] = new Completer<dynamic>();

            subscriptions[i] = streams.elementAt(i).listen(_controller.add,
                onError: _controller.addError,
                onDone: () {
                  completeEvents[i].complete();

                  if (i == len - 1) _controller.close();
                });

            if (i > 0) subscriptions[i].pause(completeEvents[i - 1].future);
          }
        },
        onCancel: () => Future.wait(subscriptions
            .map((StreamSubscription<T> subscription) => subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null))
    );

    setStream(asBroadcastStream ? _controller.stream.asBroadcastStream() : _controller.stream);
  }

}