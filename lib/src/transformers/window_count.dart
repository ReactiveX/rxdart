import 'dart:async';

import 'package:rxdart/transformers.dart';

/// Creates an Observable where each item is a Stream containing the items
/// from the source sequence, in batches of count.
///
/// If skip is provided, each group will start where the previous group
/// ended minus the skip value.
///
/// ### Example
///
///     new RangeStream(1, 4)
///      .transform(new WindowCountStreamTransformer(3))
///      .transform(new FlatMapStreamTransformer((i) => i))
///      .listen(expectAsync1(print, count: 4)); // prints 1, 2, 3, 4
class WindowCountStreamTransformer<T>
    extends StreamTransformerBase<T, Stream<T>> {
  final StreamTransformer<T, Stream<T>> transformer;

  WindowCountStreamTransformer(int count, [int skip])
      : transformer = _buildTransformer(count, skip);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(int count,
      [int skip]) {
    BufferCountStreamTransformer.assertCountAndSkip(count, skip);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Iterable<T>> subscription;

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new BufferCountStreamTransformer<T>(count, skip))
                .listen((Iterable<T> value) {
              controller.add(new Stream<T>.fromIterable(value));
            },
                    cancelOnError: cancelOnError,
                    onError: controller.addError,
                    onDone: controller.close);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
