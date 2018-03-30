import 'dart:async';

import 'package:rxdart/src/schedulers/async_scheduler.dart';

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferTime(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class WindowStreamTransformer<T> extends StreamTransformerBase<T, Stream<T>> {
  final StreamSamplerType<T, Stream<T>> scheduler;

  WindowStreamTransformer(this.scheduler);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(scheduler).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      StreamSamplerType<T, Stream<T>> scheduler) {
    assertScheduler(scheduler);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;
      List<T> buffer = <T>[];

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = scheduler(input, (data, sink, [int skip]) {
              buffer.add(data);
              sink.add(new Stream<T>.fromIterable(buffer));
            }, (data, sink, [int skip]) {
              sink.add(data);
              buffer = buffer.sublist(buffer.length - (skip ?? 0));
            }).onSample.listen(controller.add, onError: controller.addError,
                onDone: () {
              if (buffer.isNotEmpty)
                controller.add(new Stream<T>.fromIterable(buffer));
              controller.close();
            }, cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }

  static void assertScheduler<T>(StreamSamplerType<T, Stream<T>> scheduler) {
    if (scheduler == null) {
      throw new ArgumentError('scheduler cannot be null');
    }
  }
}
