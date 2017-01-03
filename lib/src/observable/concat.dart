import 'package:rxdart/src/observable/stream.dart';

class ConcatObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;
  StreamSubscription<T> _subscription;

  ConcatObservable(Iterable<Stream<T>> streams, bool asBroadcastStream) {
    _controller = new StreamController<T>(sync: true,
        onListen: () => subscribeNext(streams, 0),
        onCancel: () => _subscription?.cancel());

    setStream(asBroadcastStream ? _controller.stream.asBroadcastStream() : _controller.stream);
  }

  void markDone(Iterable<Stream<T>> streams, int i) {
    if (i < streams.length - 1) {
      subscribeNext(streams, i + 1);
    } else {
      _subscription?.cancel()?.whenComplete(_controller.close);
    }
  }

  void subscribeNext(Iterable<Stream<T>> streams, int index) {
    _subscription?.cancel();

    _subscription = streams.elementAt(index).listen(_controller.add,
        onError: _controller.addError,
        onDone: () => markDone(streams, index));
  }

}