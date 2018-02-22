import 'dart:async';

/// Emit items from the source Stream, or a single default item if the source
/// Stream emits nothing.
///
/// ### Example
///
///     new Stream.empty()
///       .transform(new DefaultIfEmptyStreamTransformer(10))
///       .listen(print); // prints 10
class DefaultIfEmptyStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  DefaultIfEmptyStreamTransformer(T defaultValue)
      : transformer = _buildTransformer(defaultValue);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(T defaultValue) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      bool hasEvent = false;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  hasEvent = true;
                  try {
                    controller.add(value);
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                },
                onError: controller.addError,
                onDone: () {
                  if (!hasEvent) controller.add(defaultValue);
                  controller.close();
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
