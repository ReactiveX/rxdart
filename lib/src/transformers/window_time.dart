import 'dart:async';

import 'package:rxdart/src/schedulers/async_scheduler.dart';

import 'package:rxdart/src/transformers/window.dart';

/// Creates an Observable where each item is a Stream containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (i) => i)
///       .windowTime(const Duration(milliseconds: 220))
///       .doOnData((_) => print('next window'))
///       .flatMap((bufferedStream) => bufferedStream)
///       .listen((i) => print(i)); // prints next window, 0, 1, next window, 2, 3, next window, 4, 5, ...
class WindowTimeStreamTransformer<T>
    extends StreamTransformerBase<T, Stream<T>> {
  final Duration timeframe;

  WindowTimeStreamTransformer(this.timeframe);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(timeframe).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      Duration duration) {
    assertTimeframe(duration);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new WindowStreamTransformer<T>(onTime(duration)))
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

  static void assertTimeframe(Duration timeframe) {
    if (timeframe == null) {
      throw new ArgumentError('timeframe cannot be null');
    }
  }
}
