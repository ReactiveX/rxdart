import 'dart:async';

/// A StreamTransformer that repeats the source's elements the specified
/// number of times.
///
/// ### Example
///
///     new Stream.fromIterable([1])
///       .transform(new RepeatStreamTransformer(3))
///       .listen(print); // prints 1, 1, 1
class RepeatStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  RepeatStreamTransformer({int count = 1, bool indefinitely = false})
      : transformer = _buildTransformer(count, indefinitely);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      int count, bool indefinitely) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      final List<T> pastEvents = <T>[];
      int currentLoopCount = 0;
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  pastEvents.add(value);
                },
                onError: controller.addError,
                onDone: () {
                  /// start repeating now
                  while (indefinitely || currentLoopCount++ < count) {
                    pastEvents.forEach(controller.add);
                  }

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
