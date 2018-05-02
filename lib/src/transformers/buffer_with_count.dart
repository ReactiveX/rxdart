import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';
import 'package:rxdart/src/transformers/buffer.dart';

/// Deprecated: Use BufferCountStreamTransformer
///
/// Creates an Observable where each item is a list containing the items
/// from the source sequence, in batches of count.
///
/// If skip is provided, each group will start where the previous group
/// ended minus the skip value.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3, 4])
///       .transform(new BufferWithCountStreamTransformer(2))
///       .listen(print); // prints [1, 2], [3, 4]
///
/// ### Example with skip
///
///     new Stream.fromIterable([1, 2, 3, 4])
///       .transform(new BufferWithCountStreamTransformer(2, 1))
///       .listen(print); // prints [1, 2], [2, 3], [3, 4], [4]
@deprecated
class BufferWithCountStreamTransformer<T>
    extends StreamTransformerBase<T, List<T>> {
  final int count, skip;

  BufferWithCountStreamTransformer(this.count, [this.skip]);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(count, skip).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(
      int count, int skip) {
    assertCountAndSkip(count, skip);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new BufferStreamTransformer<T>(onCount(count, skip)))
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
