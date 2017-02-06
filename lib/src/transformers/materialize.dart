import 'dart:async';

import 'package:rxdart/src/transformers/call.dart';

/// Converts the onData, on Done, and onError events into [Notification]
/// objects that are passed into the downstream onData listener.
///
/// The [Notification] object contains the [Kind] of event (OnData, onDone, or
/// OnError), and the item or error that was emitted. In the case of onDone,
/// no data is emitted as part of the [Notification].
///
/// Example:
///     new Stream<int>.fromIterable([1])
///         .transform(materializeTransformer())
///         .listen((i) => print(i)); // Prints onData & onDone Notification
StreamTransformer<T, Notification<T>> materializeTransformer<T>() {
  return new StreamTransformer<T, Notification<T>>(
      (Stream<T> input, bool cancelOnError) {
    StreamController<Notification<T>> controller;
    StreamSubscription<T> subscription;

    controller = new StreamController<Notification<T>>(
        sync: true,
        onListen: () {
          subscription = input.listen((T value) {
            controller.add(new Notification<T>.onData(value));
          }, onError: (dynamic e, dynamic s) {
            controller.add(new Notification<T>.onError(e, s));
          }, onDone: () {
            controller.add(new Notification<T>.onDone());

            controller.close();
          }, cancelOnError: cancelOnError);
        },
        onPause: ([Future<dynamic> resumeSignal]) {
          subscription.pause(resumeSignal);
        },
        onResume: () {
          subscription.resume();
        },
        onCancel: () {
          return subscription.cancel();
        });

    return controller.stream.listen(null);
  });
}
