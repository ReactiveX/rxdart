import 'dart:async';

import 'package:rxdart/src/schedulers/async_scheduler.dart';

import 'package:rxdart/src/transformers/window.dart';

typedef Future<dynamic> _OnFuture();

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferTime(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class WindowFutureStreamTransformer<T>
    extends StreamTransformerBase<T, Stream<T>> {
  final _OnFuture onFutureFunction;

  WindowFutureStreamTransformer(this.onFutureFunction);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(onFutureFunction).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      _OnFuture onFutureFunction) {
    assertFuture(onFutureFunction);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(
                    new WindowStreamTransformer<T>(onFuture(onFutureFunction)))
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
