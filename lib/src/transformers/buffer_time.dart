import 'dart:async';

import 'package:rxdart/src/schedulers/async_scheduler.dart';

import 'package:rxdart/src/transformers/buffer.dart';

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferTime(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class BufferTimeStreamTransformer<T> extends StreamTransformerBase<T, List<T>> {
  final Duration timeframe;

  BufferTimeStreamTransformer(this.timeframe);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(timeframe).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(Duration duration) {
    assertTimeframe(duration);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;
      Stream<dynamic> ticker;

      if (input.isBroadcast) {
        ticker = new Stream<Null>.periodic(duration).asBroadcastStream();
      } else {
        ticker = new Stream<Null>.periodic(duration);
      }

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new BufferStreamTransformer<T>(onStream(ticker)))
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
