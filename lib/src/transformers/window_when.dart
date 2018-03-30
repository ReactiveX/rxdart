import 'dart:async';

import 'package:rxdart/src/schedulers/async_scheduler.dart';

import 'package:rxdart/src/transformers/window.dart';

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
class WindowWhenStreamTransformer<T>
    extends StreamTransformerBase<T, Stream<T>> {
  final Stream<dynamic> sampler;

  WindowWhenStreamTransformer(this.sampler);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(sampler).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      Stream<dynamic> sampler) {
    assertOnStream(sampler);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;

      assertBroadcastMode(input, sampler, controller);

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new WindowStreamTransformer<T>(onStream(sampler)))
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
      StreamController<Stream<T>> controller) {
    if (input.isBroadcast && !sampler.isBroadcast) {
      controller.addError(
          new StateError('sampler should also be a broadcast stream'));
    }
  }
}
