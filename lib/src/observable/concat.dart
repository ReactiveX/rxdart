import 'package:rxdart/src/observable/stream.dart';

class ConcatObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;

  ConcatObservable(Iterable<Stream<T>> streams, bool asBroadcastStream) {
    final List<StreamSubscription<T>> subscriptions = new List<StreamSubscription<T>>(streams.length);
    final List<List<T>> buffer = new List<List<T>>.generate(streams.length, (_) => <T>[]);

    _controller = new StreamController<T>(sync: true,
        onListen: () {
          final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

          void drainNext(int index) {
            if (index < streams.length) {
              for (int i=0, len=buffer.length; i<len; i++) {
                if (buffer[i].isNotEmpty) {
                  buffer[i].forEach(_controller.add);
                  buffer[i].clear();

                  break;
                }
              }
            }
          }

          void markDone(int i) {
            completedStatus[i] = true;
            drainNext(i + 1);

            if (completedStatus.reduce((bool a, bool b) => a && b)) _controller.close();
          }

          void handleEvent(T event, int index) {
            bool isBuffered = false;

            for (int i=0, len=completedStatus.length; i<len; i++) {
              if (i < index && !completedStatus[i]) {
                isBuffered = true;

                buffer[index].add(event);

                break;
              }
            }

            if (!isBuffered) _controller.add(event);
          }

          for (int i=0, len=streams.length; i<len; i++) {
            subscriptions[i] = streams.elementAt(i).listen((T event) => handleEvent(event, i),
                onError: _controller.addError,
                onDone: () => markDone(i));
          }
        },
        onCancel: () => Future.wait(subscriptions
            .map((StreamSubscription<T> subscription) => subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null))
    );

    setStream(asBroadcastStream ? _controller.stream.asBroadcastStream() : _controller.stream);
  }

}