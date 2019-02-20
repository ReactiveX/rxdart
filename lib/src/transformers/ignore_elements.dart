import 'dart:async';

/// Creates an Observable where all emitted items are ignored, only the
/// error / completed notifications are passed
///
/// ### Example
///
///     new MergeStream([
///       new Stream.fromIterable([1]),
///       new ErrorStream(new Exception())
///     ])
///     .listen(print, onError: print); // prints Exception
class IgnoreElementsStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  IgnoreElementsStreamTransformer() : transformer = _buildTransformer();

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>() {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(null,
                onError: controller.addError,
                onDone: () => controller.close(),
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
