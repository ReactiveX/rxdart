library rx.observable.combine_latest;

import 'package:rxdart/src/observable/stream.dart';

class CombineLatestObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;

  CombineLatestObservable(Iterable<Stream<dynamic>> streams, Function predicate, bool asBroadcastStream) {
    final List<StreamSubscription<dynamic>> subscriptions = new List<StreamSubscription<dynamic>>(streams.length);

    _controller = new StreamController<T>(sync: true,
      onListen: () {
        final List<dynamic> values = new List<dynamic>(streams.length);
        final List<bool> triggered = new List<bool>.generate(streams.length, (_) => false);
        final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

        void doUpdate(int i, dynamic value) {
          values[i] = value;
          triggered[i] = true;

          if (triggered.reduce((bool a, bool b) => a && b)) updateWithValues(predicate, values);
        }

        void markDone(int i) {
          completedStatus[i] = true;

          if (completedStatus.reduce((bool a, bool b) => a && b)) _controller.close();
        }

        for (int i=0, len=streams.length; i<len; i++) {
          Stream<dynamic> stream = streams.elementAt(i);

          subscriptions[i] = stream.listen((dynamic value) => doUpdate(i, value),
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
    dynamic result = Function.apply(predicate, values);

    if (result is T) _controller.add(result);
    else if (result == null) _controller.add(null);
    else _controller.addError(new ArgumentError('predicate result is of type ${result.runtimeType} and not of expected type $T'));
  }

}