library rx.observable.merge;

import 'package:rxdart/src/observable/stream.dart';

class MergeObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  MergeObservable(Iterable<Stream> streams, bool asBroadcastStream) {
    final List<StreamSubscription> subscriptions = new List<StreamSubscription>(streams.length);

    controller = new StreamController<T>(sync: true,
        onListen: () {
          final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

          void markDone(int i) {
            completedStatus[i] = true;

            if (completedStatus.reduce((bool a, bool b) => a && b)) controller.close();
          }

          for (int i=0, len=streams.length; i<len; i++) {
            Stream stream = streams.elementAt(i);

            subscriptions[i] = stream.listen(controller.add,
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

}