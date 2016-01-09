library rx.observable.combine_latest;

import 'package:rxdart/src/observable/stream.dart';

class CombineLatestObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  CombineLatestObservable(Iterable<Stream> streams, Function predicate, bool asBroadcastStream) {
    final List<StreamSubscription> subscriptions = new List<StreamSubscription>(streams.length);

    controller = new StreamController<T>(sync: true,
        onListen: () {
          final List values = new List(streams.length);
          final List<bool> triggered = new List<bool>.generate(streams.length, (_) => false);
          final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

          void doUpdate(int i, dynamic value) {
            values[i] = value;
            triggered[i] = true;

            if (triggered.reduce((bool a, bool b) => a && b)) updateWithValues(predicate, values);
          }

          void markDone(int i) {
            completedStatus[i] = true;

            if (completedStatus.reduce((bool a, bool b) => a && b)) controller.close();
          }

          for (int i=0, len=streams.length; i<len; i++) {
            Stream stream = streams.elementAt(i);

            subscriptions[i] = stream.listen((dynamic value) => doUpdate(i, value),
                onError: (e, s) => throwError(e, s),
                onDone: () => markDone(i));
          }
        },
        onCancel: () => Future.wait(subscriptions
            .map((StreamSubscription subscription) => subscription.cancel())
            .where((Future cancelFuture) => cancelFuture != null))
    );

    setStream(asBroadcastStream ? controller.stream.asBroadcastStream() : controller.stream);
  }

  void updateWithValues(Function predicate, Iterable values) {
    T result;

    try {
      result = Function.apply(predicate, values);
      assert(result is T || result == null);
    } catch (e, s) {
      throwError(e, s);
    }

    controller.add(result);
  }

}