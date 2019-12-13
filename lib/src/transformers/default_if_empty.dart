import 'dart:async';

/// Emit items from the source [Stream], or a single default item if the source
/// Stream emits nothing.
///
/// ### Example
///
///     Stream.empty()
///       .transform(DefaultIfEmptyStreamTransformer(10))
///       .listen(print); // prints 10
class DefaultIfEmptyStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which either emits from the source [Stream],
  /// or just a [defaultValue] if the source [Stream] emits nothing.
  DefaultIfEmptyStreamTransformer(T defaultValue)
      : _transformer = _buildTransformer(defaultValue);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(T defaultValue) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      var hasEvent = false;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (value) {
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

///
extension DefaultIfEmptyExtension<T> on Stream<T> {
  /// Emit items from the source Stream, or a single default item if the source
  /// Stream emits nothing.
  ///
  /// ### Example
  ///
  ///     Stream.empty().defaultIfEmpty(10).listen(print); // prints 10
  Stream<T> defaultIfEmpty(T defaultValue) =>
      transform(DefaultIfEmptyStreamTransformer<T>(defaultValue));
}
