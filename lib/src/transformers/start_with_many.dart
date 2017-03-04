import 'dart:async';

/// Prepends a sequence of values to the source Stream.
///
/// ### Example
///
///     new Stream.fromIterable([3])
///       .transform(new StartWithManyStreamTransformer([1, 2]))
///       .listen(print); // prints 1, 2, 3
class StartWithManyStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  StartWithManyStreamTransformer(List<T> startValues)
      : transformer = _buildTransformer(startValues);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(List<T> startValues) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            startValues.forEach(controller.add);

            subscription = input.listen(controller.add,
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
}
