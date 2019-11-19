import 'dart:async';

/// Prepends an error to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithErrorStreamTransformer('error'))
///       .listen(null, onError: (e) => print(e)); // prints 'error'
class StartWithErrorStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which starts with the provided [error]
  /// and then outputs all events from the source [Stream].
  StartWithErrorStreamTransformer(Object error, [StackTrace stackTrace])
      : _transformer = _buildTransformer(error, stackTrace);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      Object error, StackTrace stackTrace) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            try {
              controller.addError(error, stackTrace);
            } catch (e, s) {
              controller.addError(e, s);
            }

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
