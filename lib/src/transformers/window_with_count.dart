import 'dart:async';

import 'package:rxdart/src/transformers/buffer_with_count.dart';

/// Creates an Observable where each item is a Stream containing the items
/// from the source sequence, in batches of count.
///
/// If skip is provided, each group will start where the previous group
/// ended minus the skip value.
///
/// ### Example
///
///     new RangeStream(1, 4)
///      .transform(new WindowWithCountStreamTransformer(3))
///      .transform(new FlatMapStreamTransformer((i) => i))
///      .listen(expectAsync1(print, count: 4)); // prints 1, 2, 3, 4
class WindowWithCountStreamTransformer<T, S extends Stream<T>>
    implements StreamTransformer<T, S> {
  final StreamTransformer<T, S> transformer;

  WindowWithCountStreamTransformer(int count, [int skip])
      : transformer = _buildTransformer(count, skip);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S extends Stream<T>>(
      int count,
      [int skip]) {
    BufferWithCountStreamTransformer.assertCountAndSkip(count, skip);

    return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<Iterable<T>> subscription;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new BufferWithCountStreamTransformer<T, List<T>>(
                    count, skip))
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
