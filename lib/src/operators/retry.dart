library rx.operators.retry;

import 'package:rxdart/src/observable/stream.dart';

class RetryObservable<T> extends StreamObservable<T> {

  RetryObservable(Stream<T> stream, int count) {
    setStream(stream.transform(new StreamTransformer<T, T>(
      (Stream<T> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<T> subscription;
        int retryStep = 0;

        controller = new StreamController<T>(sync: true,
          onListen: () {
            subscription = input.listen((T data) {
              controller.add(data);
            },
                onError: (dynamic e, dynamic s) {
                  if (count > 0 && count == retryStep) controller.addError(new RetryError(count));

                  retryStep++;
                },
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
            onPause: ([Future<dynamic> resumeSignal]) => subscription.pause(resumeSignal),
            onResume: () => subscription.resume(),
            onCancel: () => subscription.cancel());

        return controller.stream.listen(null);
      }
    )));
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