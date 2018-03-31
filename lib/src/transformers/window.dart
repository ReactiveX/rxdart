import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';

import 'package:rxdart/src/transformers/do.dart';

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferTime(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class WindowStreamTransformer<T> extends StreamTransformerBase<T, Stream<T>> {
  final BufferBlocBuilder<T, Stream<T>> scheduler;

  WindowStreamTransformer(this.scheduler);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(scheduler).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      BufferBlocBuilder<T, Stream<T>> scheduler) {
    assertScheduler(scheduler);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;
      List<T> buffer = <T>[];

      void onDone() {
        if (controller.isClosed) return;

        if (buffer.isNotEmpty)
          controller.add(new Stream<T>.fromIterable(buffer));

        controller.close();
      }

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            try {
              subscription = scheduler(
                  input.transform(new DoStreamTransformer(onDone: onDone)),
                  (data, sink, [int skip]) {
                buffer.add(data);
                sink.add(new Stream<T>.fromIterable(buffer));
              }, (data, sink, [int skip]) {
                sink.add(data);
                buffer = buffer.sublist(buffer.length - (skip ?? 0));
              }).state.listen(controller.add,
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

  static void assertScheduler<T>(BufferBlocBuilder<T, Stream<T>> scheduler) {
    if (scheduler == null) {
      throw new ArgumentError('scheduler cannot be null');
    }
  }
}
