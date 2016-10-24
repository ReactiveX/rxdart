library rx.observable.zip;

import 'package:rxdart/src/observable/stream.dart';

class ZipObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;

  ZipObservable(Iterable<Stream<dynamic>> streams, Function predicate, bool asBroadcastStream) {
    final List<StreamSubscription<dynamic>> subscriptions = new List<StreamSubscription<dynamic>>(streams.length);

    _controller = new StreamController<T>(sync: true,
      onListen: () {
        final List<dynamic> values = new List<dynamic>(streams.length);
        final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

        void doUpdate(StreamSubscription<dynamic> subscription, int index, dynamic value) {
          values[index] = value;

          subscription.pause();

          if (_areAllPaused(subscriptions)) {
            updateWithValues(predicate, values);

            _resumeAll(subscriptions);
          }
        }

        void markDone(int i) {
          completedStatus[i] = true;

          if (completedStatus.reduce((bool a, bool b) => a && b)) _controller.close();
        }

        for (int i=0, len=streams.length; i<len; i++) {
          Stream<dynamic> stream = streams.elementAt(i);

          subscriptions[i] = stream.listen((dynamic value) => doUpdate(subscriptions[i], i, value),
            onError: _controller.addError,
            onDone: () => markDone(i));
        }
      },
      onCancel: () => Future.wait(subscriptions
        .map((StreamSubscription<dynamic> subscription) => subscription.cancel())
        .where((Future<dynamic> cancelFuture) => cancelFuture != null))
    );

    setStream(asBroadcastStream ? _controller.stream.asBroadcastStream() : _controller.stream);
  }

  void updateWithValues(Function predicate, Iterable<dynamic> values) {
    T result;

    try {
      result = Function.apply(predicate, values) as T;

      assert(result is T || result == null);
    } catch (e, s) {
      _controller.addError(e, s);
    }

    _controller.add(result);
  }

  bool _areAllPaused(List<StreamSubscription<dynamic>> subscriptions) {
    for (int i=0, len=subscriptions.length; i<len; i++) {
      if (!subscriptions[i].isPaused) return false;
    }

    return true;
  }

  void _resumeAll(List<StreamSubscription<dynamic>> subscriptions) {
    for (int i=0, len=subscriptions.length; i<len; i++) subscriptions[i].resume();
  }

}