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
class BufferStreamTransformer<T> extends StreamTransformerBase<T, List<T>> {
  final StreamSchedulerType<T, List<T>> scheduler;

  BufferStreamTransformer(this.scheduler);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(scheduler).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(
      StreamSchedulerType<T, List<T>> scheduler) {
    assertScheduler(scheduler);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;
      List<T> buffer = <T>[];

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            subscription = scheduler(input, (data, sink, [int skip]) {
              buffer.add(data);
              sink.add(buffer);
            }, (data, sink, [int skip]) {
              skip ??= 0;
              sink.add(new List<T>.unmodifiable(data));
              buffer = data.sublist(data.length - skip);
            }).onSchedule.listen(controller.add, onError: controller.addError,
                onDone: () {
              if (buffer.isNotEmpty)
                controller.add(new List<T>.unmodifiable(buffer));
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

  static void assertScheduler<T>(StreamSchedulerType<T, List<T>> scheduler) {
    if (scheduler == null) {
      throw new ArgumentError('scheduler cannot be null');
    }
  }
}
