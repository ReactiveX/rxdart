import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

class RetryStream<T> extends Stream<T> {
  final StreamFactory<T> streamFactory;
  int count;
  int retryStep = 0;
  bool shouldClose = false;
  StreamController<T> controller;
  StreamSubscription<T> subscription;

  RetryStream(this.streamFactory, [this.count]);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    controller = new StreamController<T>(
        sync: true,
        onListen: retry,
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void retry() {
    bool errorOccurred = false;

    subscription = streamFactory().listen((T data) {
      controller.add(data);
    }, onError: (dynamic e, dynamic s) {
      errorOccurred = true;

      if (count == retryStep) {
        controller.addError(new RetryError(count));
      } else {
        subscription.cancel();
        retryStep++;
        retry();
      }
    }, onDone: () {
      if (!errorOccurred) {
        controller.close();
      }
    }, cancelOnError: false);
  }
}

class RetryError extends Error {
  final String message;

  RetryError(int count)
      : message = 'Received an error after attempting $count retries';

  @override
  String toString() => message;
}
