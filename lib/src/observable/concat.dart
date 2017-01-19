import 'package:rxdart/src/observable/stream.dart';

class ConcatObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;
  StreamSubscription<T> subscription;

  ConcatObservable(Iterable<Stream<T>> streams, bool asBroadcastStream) {
    _controller = new StreamController<T>(sync: true,
        onListen: () {
          final int len = streams.length;
          int index = 0;

          void moveNext() {
            Stream<T> stream = streams.elementAt(index);
            subscription?.cancel();

            subscription = stream.listen(_controller.add,
                onError: _controller.addError,
                onDone: () {
                  index++;

                  if (index == len) _controller.close();
                  else moveNext();
                });
          }

          moveNext();
        },
        onCancel: () => subscription.cancel());

    setStream(asBroadcastStream ? _controller.stream.asBroadcastStream() : _controller.stream);
  }

}