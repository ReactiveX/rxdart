import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';

/// Creates an Observable where each item is a [List] containing the items
/// from the source sequence, batched by the [sampler].
///
/// ### Example with [onCount]
///
///     Observable.range(1, 4)
///       .buffer(onCount(2))
///       .listen(print); // prints [1, 2], [3, 4]
///
/// ### Example with [onFuture]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onFuture(() => new Future.delayed(const Duration(milliseconds: 220))))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
///
/// ### Example with [onTest]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onTest((i) => i % 2 == 0))
///       .listen(print); // prints [0], [1, 2] [3, 4] [5, 6] ...
///
/// ### Example with [onTime]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onTime(const Duration(milliseconds: 220)))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
///
/// ### Example with [onStream]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onStream(new Stream.periodic(const Duration(milliseconds: 220), (int i) => i)))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
///
/// You can create your own sampler by extending [StreamView]
/// should the above samplers be insufficient for your use case.
class BufferStreamTransformer<T> extends StreamTransformerBase<T, List<T>> {
  final SamplerBuilder<T, List<T>> sampler;

  BufferStreamTransformer(this.sampler);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(sampler).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(
      SamplerBuilder<T, List<T>> scheduler) {
    assertSampler(scheduler);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;
      List<T> buffer = <T>[];

      void onDone() {
        if (controller.isClosed) return;

        if (buffer.isNotEmpty) controller.add(new List<T>.unmodifiable(buffer));

        controller.close();
      }

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            try {
              subscription = scheduler(input, (
                T data,
                EventSink<List<T>> sink, [
                int skip,
              ]) {
                buffer.add(data);
                sink.add(buffer);
              }, (_, EventSink<List<T>> sink, [int skip]) {
                sink.add(new List<T>.unmodifiable(buffer));
                buffer = buffer.sublist(buffer.length - (skip ?? 0));
              }).listen(controller.add,
                  onError: controller.addError,
                  onDone: onDone,
                  cancelOnError: cancelOnError);
            } catch (e, s) {
              controller.addError(e, s);
            }
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }

  static void assertSampler<T>(SamplerBuilder<T, List<T>> scheduler) {
    if (scheduler == null) {
      throw new ArgumentError('scheduler cannot be null');
    }
  }
}
