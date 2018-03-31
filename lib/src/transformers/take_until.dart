import 'dart:async';

/// Returns the values from the source observable sequence until the other
/// stream sequence produces a value.
///
/// ### Example
///
///     new MergeStream([
///         new Stream.fromIterable([1]),
///         new TimerStream(2, new Duration(minutes: 1))
///       ])
///       .transform(new TakeUntilStreamTransformer(
///         new TimerStream(3, new Duration(seconds: 10))))
///       .listen(print); // prints 1
class TakeUntilStreamTransformer<T, S> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  TakeUntilStreamTransformer(Stream<S> otherStream)
      : transformer = _buildTransformer(otherStream);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T, S>(
      Stream<S> otherStream) {
    if (otherStream == null) {
      throw new ArgumentError("take until stream cannot be null");
    }
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> otherSubscription;

      void onDone() {
        if (controller.isClosed) return;

        controller.close();
      }

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(controller.add,
                onError: controller.addError,
                onDone: onDone,
                cancelOnError: cancelOnError);

            otherSubscription = otherStream.listen((_) => onDone(),
                onError: controller.addError,
                cancelOnError: cancelOnError,
                onDone: onDone);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () async {
            await otherSubscription?.cancel();
            await subscription?.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}
