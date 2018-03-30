import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';

import 'package:rxdart/src/transformers/buffer.dart';

typedef Future<dynamic> _OnFuture();

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferTime(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class BufferFutureStreamTransformer<T>
    extends StreamTransformerBase<T, List<T>> {
  final _OnFuture onFutureFunction;

  BufferFutureStreamTransformer(this.onFutureFunction);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(onFutureFunction).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(
      _OnFuture onFutureFunction) {
    assertFuture(onFutureFunction);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(
                    new BufferStreamTransformer<T>(onFuture(onFutureFunction)))
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

  static void assertFuture(_OnFuture onFuture) {
    if (onFuture == null) {
      throw new ArgumentError('onFuture cannot be null');
    }
  }
}
