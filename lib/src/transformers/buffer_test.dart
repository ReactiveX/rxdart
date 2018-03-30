import 'dart:async';

import 'package:rxdart/src/schedulers/async_scheduler.dart';

import 'package:rxdart/src/transformers/buffer.dart';

typedef bool _OnTest<T>(T event);

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferTime(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class BufferTestStreamTransformer<T> extends StreamTransformerBase<T, List<T>> {
  final _OnTest<T> onTestFunction;

  BufferTestStreamTransformer(this.onTestFunction);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(onTestFunction).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(
      _OnTest<T> onTestFunction) {
    assertTest(onTestFunction);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(
                    new BufferStreamTransformer<T>(onTest(onTestFunction)))
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

  static void assertTest<T>(_OnTest<T> onTestFunction) {
    if (onTestFunction == null) {
      throw new ArgumentError('onTestFunction cannot be null');
    }
  }
}
