import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';

import 'package:rxdart/src/transformers/buffer.dart';

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
class BufferWhenStreamTransformer<T> extends StreamTransformerBase<T, List<T>> {
  final Stream<dynamic> sampler;

  BufferWhenStreamTransformer(this.sampler);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(sampler).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(
      Stream<dynamic> sampler) {
    assertOnStream(sampler);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;

      assertBroadcastMode(input, sampler, controller);

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new BufferStreamTransformer<T>(onStream(sampler)))
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

  static void assertOnStream(Stream<dynamic> sampler) {
    if (sampler == null) {
      throw new ArgumentError('sampler cannot be null');
    }
  }

  static void assertBroadcastMode<T>(Stream<T> input, Stream<dynamic> sampler,
      StreamController<List<T>> controller) {
    if (input.isBroadcast && !sampler.isBroadcast) {
      controller.addError(
          new StateError('sampler should also be a broadcast stream'));
    }
  }
}
