import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Creates a Stream that emits each item in the Stream after a given
/// duration.
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3])
///       .transform(IntervalStreamTransformer(Duration(seconds: 1)))
///       .listen((i) => print('$i sec'); // prints 1 sec, 2 sec, 3 sec
class IntervalStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// The interval after which incoming events need to be emitted.
  final Duration duration;

  /// Constructs a [StreamTransformer] which emits each item from the source [Stream],
  /// after a given duration.
  IntervalStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;
    Future<T> onInterval;

    final combinedWait = (Future<dynamic> resumeSignal) =>
        (resumeSignal != null && onInterval != null)
            ? Future.wait<dynamic>([onInterval, resumeSignal])
            : resumeSignal;

    controller = createController(stream,
        onListen: () {
          subscription = stream.listen((value) {
            try {
              onInterval = Future.delayed(duration, () => value);

              // no need to call combinedWait here,
              // if the main subscription is paused, then
              // there can never be an event in that pause time frame
              subscription.pause(onInterval
                  .then(controller.add)
                  .whenComplete(() => onInterval = null));
            } catch (e, s) {
              controller.addError(e, s);
            }
          }, onError: controller.addError, onDone: controller.close);
        },
        // await also onInterval, if it is active
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(combinedWait(resumeSignal)),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream;
  }
}

/// Extends the Stream class with the ability to emit each item after a given
/// duration.
extension IntervalExtension<T> on Stream<T> {
  /// Creates a Stream that emits each item in the Stream after a given
  /// duration.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .interval(Duration(seconds: 1))
  ///       .listen((i) => print('$i sec'); // prints 1 sec, 2 sec, 3 sec
  Stream<T> interval(Duration duration) =>
      transform(IntervalStreamTransformer<T>(duration));
}
