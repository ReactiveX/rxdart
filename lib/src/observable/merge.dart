import 'package:rxdart/src/observable/stream.dart';

class MergeObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;

  MergeObservable(Iterable<Stream<T>> streams, bool asBroadcastStream) {
    final List<StreamSubscription<T>> subscriptions = new List<StreamSubscription<T>>(streams.length);

    _controller = new StreamController<T>(sync: true,
      onListen: () {
        final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

        for (int i=0, len=streams.length; i<len; i++) {
          subscriptions[i] = streams.elementAt(i).listen(_controller.add,
            onError: _controller.addError,
            onDone: () {
              completedStatus[i] = true;

              if (completedStatus.reduce((bool a, bool b) => a && b)) _controller.close();
            });
        }
      },
      onCancel: () => Future.wait(subscriptions
        .map((StreamSubscription<T> subscription) => subscription.cancel())
        .where((Future<dynamic> cancelFuture) => cancelFuture != null))
    );

    setStream(asBroadcastStream ? _controller.stream.asBroadcastStream() : _controller.stream);
  }

}