import 'dart:async';

/// Creates a Stream that emits each item in the Stream after a given
/// duration.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new IntervalStreamTransformer(seconds: 1))
///       .listen((i) => print("$i sec"); // prints 1 sec, 2 sec, 3 sec
class IntervalStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  IntervalStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              try {
                final Completer<T> completer = new Completer<T>();

                new Timer(duration, () => completer.complete(value));

                subscription.pause(completer.future.then(controller.add));
              } catch (e, s) {
                controller.addError(e, s);
              }
            },
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: () => subscription.pause(),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
