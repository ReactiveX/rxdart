import 'dart:async';

import 'package:rxdart/src/utils/notification.dart';

/// Converts the onData, on Done, and onError events into [Notification]
/// objects that are passed into the downstream onData listener.
///
/// The [Notification] object contains the [Kind] of event (OnData, onDone, or
/// OnError), and the item or error that was emitted. In the case of onDone,
/// no data is emitted as part of the [Notification].
///
/// ### Example
///
///     new Stream<int>.fromIterable([1])
///         .transform(materializeTransformer())
///         .listen((i) => print(i)); // Prints onData & onDone Notification
class MaterializeStreamTransformer<T>
    extends StreamTransformerBase<T, Notification<T>> {
  final StreamTransformer<T, Notification<T>> transformer;

  MaterializeStreamTransformer() : transformer = _buildTransformer();

  @override
  Stream<Notification<T>> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, Notification<T>> _buildTransformer<T>() {
    return StreamTransformer<T, Notification<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Notification<T>> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<Notification<T>>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              try {
                controller.add(Notification<T>.onData(value));
              } catch (e, s) {
                controller.addError(e, s);
              }
            }, onError: (dynamic e, StackTrace s) {
              controller.add(Notification<T>.onError(e, s));
            }, onDone: () {
              controller.add(Notification<T>.onDone());

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
}
