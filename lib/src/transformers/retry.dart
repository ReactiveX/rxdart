import 'dart:async';

StreamTransformer<T, T> retryTransformer<T>({int count: 0}) {
  return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;
    int retryStep = 0;

    // In Dart, you cannot resubscribe to a single-subscription [Stream]
    // however the Rx retry spec stipulates that we should resubscribe
    // onError to trigger any potential side effects
    // This assert warns the developer to not use retry when
    // the input [Stream] is a single-subscription
    assert(
        input.isBroadcast,
        '''The provided Stream
is not a broadcast Stream, making it impossible to
resubscribe to it.

In Rx retry, it is expected to resubscribe when an error occurs.

To resolve, please ensure that the provided Stream is a broadcast
Stream.

See: http://reactivex.io/documentation/operators/retry.html''');

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          void subscribeNext() {
            subscription?.cancel();

            subscription = input.listen((T data) {
              controller.add(data);
            }, onError: (dynamic e, dynamic s) {
              if (count > 0 && count == retryStep) {
                controller.addError(new RetryError(count));
              } else {
                subscribeNext();
              }

              retryStep++;
            }, onDone: controller.close, cancelOnError: cancelOnError);
          }

          subscribeNext();
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream.listen(null);
  });
}

class RetryError extends Error {
  final int count;
  String message;

  RetryError(this.count) {
    message = 'Received an error after attempting {$count} retries';
  }

  @override
  String toString() => message;
}
