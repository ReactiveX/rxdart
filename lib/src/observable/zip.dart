library rx.observable.zip;

import 'dart:collection';

import 'package:rxdart/src/observable/stream.dart';

class ZipObservable<T extends List> extends StreamObservable<T> with ControllerMixin<T> {

  ZipObservable(Iterable<Stream> streams, bool asBroadcastStream) {
    final List<StreamSubscription> subscriptions = new List<StreamSubscription>(streams.length);

    controller = new StreamController<T>(sync: true,
        onListen: () {
          final List<Queue> values = new List<Queue>.generate(streams.length, (_) => new Queue());
          final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

          void doUpdate(int index, dynamic value) {
            final Queue queue = values[index];
            Queue otherQueue;

            queue.add(value);

            for (int i=0, len=queue.length; i<len; i++) {
              List list = [];

              for (int j=0, len2=values.length; j<len2; j++) {
                otherQueue = values[j];

                if (otherQueue.length >= len) {
                  list.add(otherQueue.elementAt(i));
                }
              }

              if (list.length == values.length) {
                values.forEach((Queue q) => q.removeFirst());

                controller.add(list);

                break;
              }
            }
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

}