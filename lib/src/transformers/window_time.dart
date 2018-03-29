import 'dart:async';

import 'package:rxdart/src/transformers/buffer_time.dart';

/// Creates an Observable where each item is a Stream containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (i) => i)
///       .windowTime(const Duration(milliseconds: 220))
///       .doOnData((_) => print('next window'))
///       .flatMap((bufferedStream) => bufferedStream)
///       .listen((i) => print(i)); // prints next window, 0, 1, next window, 2, 3, next window, 4, 5, ...
class WindowTimeStreamTransformer<T>
    extends StreamTransformerBase<T, Stream<T>> {
  final StreamTransformer<T, Stream<T>> transformer;

  WindowTimeStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      Duration duration) {
    BufferTimeStreamTransformer.assertTimeframe(duration);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Iterable<T>> subscription;

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .transform(new BufferTimeStreamTransformer<T>(duration))
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
