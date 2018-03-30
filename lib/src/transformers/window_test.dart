import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';

import 'package:rxdart/src/transformers/window.dart';

typedef bool _OnTest<T>(T event);

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferTime(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class WindowTestStreamTransformer<T>
    extends StreamTransformerBase<T, Stream<T>> {
  final _OnTest<T> onTestFunction;

  WindowTestStreamTransformer(this.onTestFunction);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(onTestFunction).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      _OnTest<T> onTestFunction) {
    assertTest(onTestFunction);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(
                    new WindowStreamTransformer<T>(onTest(onTestFunction)))
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
