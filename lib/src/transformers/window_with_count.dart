import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';
import 'package:rxdart/transformers.dart';

/// Deprecated: Please use WindowCountStreamTransformer.
///
/// Creates an Observable where each item is a Stream containing the items
/// from the source sequence, in batches of count.
///
/// If skip is provided, each group will start where the previous group
/// ended minus the skip value.
///
/// ### Example
///
///     new RangeStream(1, 4)
///      .transform(new WindowWithCountStreamTransformer(3))
///      .transform(new FlatMapStreamTransformer((i) => i))
///      .listen(expectAsync1(print, count: 4)); // prints 1, 2, 3, 4
@deprecated
class WindowWithCountStreamTransformer<T>
    extends StreamTransformerBase<T, Stream<T>> {
  final int count, skip;

  WindowWithCountStreamTransformer(this.count, [this.skip]);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(count, skip).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      int count, int skip) {
    assertCountAndSkip(count, skip);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new WindowStreamTransformer<T>(onCount(count, skip)))
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

  static void assertCountAndSkip(int count, [int skip]) {
    final int skipAmount = skip == null ? count : skip;

    if (count == null) {
      throw new ArgumentError('count cannot be null');
    } else if (skipAmount <= 0 || skipAmount > count) {
      throw new ArgumentError(
          'skip has to be greater than zero and smaller than count');
    }
  }
}
