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
  final StreamSchedulerType<T> scheduler;

  BufferStreamTransformer(this.scheduler);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(scheduler).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(
      StreamSchedulerType<T> scheduler) {
    assertScheduler(scheduler);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            subscription = scheduler(input).onSchedule.listen(controller.add,
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

  static void assertScheduler<T>(StreamSchedulerType<T> scheduler) {
    if (scheduler == null) {print('TEST');
      throw new ArgumentError('scheduler cannot be null');
    }
  }
}
