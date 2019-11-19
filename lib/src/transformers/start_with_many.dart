import 'dart:async';

/// Prepends a sequence of values to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([3])
///       .transform(StartWithManyStreamTransformer([1, 2]))
///       .listen(print); // prints 1, 2, 3
class StartWithManyStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with all values from [startValues].
  StartWithManyStreamTransformer(Iterable<T> startValues)
      : _transformer = _buildTransformer(startValues);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Iterable<T> startValues) {
    if (startValues == null) {
      throw ArgumentError('startValues cannot be null');
    }

    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            startValues.forEach(controller.add);

            subscription = input.listen(
              controller.add,
              onError: controller.addError,
              onDone: controller.close,
              cancelOnError: cancelOnError,
            );
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}

/// Extends the Stream class with the ability to emit the given values as the
/// first items.
extension StartWithManyExtension<T> on Stream<T> {
  /// Prepends a sequence of values to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([3]).startWithMany([1, 2])
  ///       .listen(print); // prints 1, 2, 3
  Stream<T> startWithMany(List<T> startValues) =>
      transform(StartWithManyStreamTransformer<T>(startValues));
}
