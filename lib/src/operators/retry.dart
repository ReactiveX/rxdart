library rx.operators.retry;

import 'package:rxdart/src/observable/stream.dart';

class RetryObservable<T> extends StreamObservable<T> {

  RetryObservable(StreamObservable parent, Stream<T> stream, int count) {
    this.parent = parent;

    int retryStep = 0;

    controller = new StreamController<T>(sync: true,
        onListen: () {
          subscription = stream.listen((T data) {
            controller.add(data);
          },
              onError: (e, s) {
                if (count > 0 && count == retryStep) {
                  final Error error = new RetryError(count);

                  throwError(error, error.stackTrace);
                }
                retryStep++;
              },
              onDone: () => controller.close());
        },
        onCancel: () => subscription.cancel());

    setStream(stream.isBroadcast ? controller.stream.asBroadcastStream() : controller.stream);
  }

}

class RetryError extends Error {

  final int count;
  String message;

  RetryError(this.count) {
    message = 'Received an error after attempting {$count} retries';
  }

  String toString() => message;

}