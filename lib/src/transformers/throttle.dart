import 'dart:async';

import 'package:rxdart/src/streams/timer.dart';
import 'package:rxdart/src/transformers/backpressure.dart';

/// A StreamTransformer that emits only the first item emitted by the source
/// Stream during sequential time windows of a specified duration.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new ThrottleStreamTransformer(new Duration(seconds: 1)))
///       .listen(print); // prints 1
class ThrottleStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  ThrottleStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) {
    assert(duration != null, 'duration cannot be null');

    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(BackpressureStreamTransformer(
                    (T event) => TimerStream<bool>(true, duration),
                    (T event) => event,
                    null))
                .listen(controller.add,
                    onError: controller.addError,
                    onDone: controller.close,
                    cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
