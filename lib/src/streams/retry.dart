import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

/// Creates a Stream that will recreate and re-listen to the source
/// Stream the specified number of times until the Stream terminates
/// successfully.
///
/// If the retry count is not specified, it retries indefinitely. If the retry
/// count is met, but the Stream has not terminated successfully, a
/// `RetryError` will be thrown.
///
/// ### Example
///
///     new RetryStream(() { new Stream.fromIterable([1]); })
///         .listen((i) => print(i)); // Prints 1
///
///     new RetryStream(() {
///          new Stream.fromIterable([1])
///             .concatWith([new ErrorStream(new Error())]);
///        }, 1)
///        .listen(print, onError: (e, s) => print(e)); // Prints 1, 1, RetryError
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
    subscription = streamFactory().listen((T data) {
      controller.add(data);
    }, onError: (dynamic e, dynamic s) {
      subscription.cancel();

      if (count == retryStep) {
        controller.addError(new RetryError(count));
        controller.close();
      } else {
        retryStep++;
        retry();
      }
    }, onDone: controller.close, cancelOnError: false);
  }
}

class RetryError extends Error {
  final String message;

  RetryError(int count)
      : message = 'Received an error after attempting $count retries';

  @override
  String toString() => message;
}
