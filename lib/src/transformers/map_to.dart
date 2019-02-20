import 'dart:async';

/// Emits the given constant value on the output Observable every time the source Observable emits a value.
///
/// ### Example
///
///     Observable.fromIterable([1, 2, 3, 4])
///       .mapTo(true)
///       .listen(print); // prints true, true, true, true
class MapToStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> transformer;

  MapToStreamTransformer(T value) : transformer = _buildTransformer(value);

  @override
  Stream<T> bind(Stream<S> stream) => transformer.bind(stream);

  static StreamTransformer<S, T> _buildTransformer<S, T>(T value) =>
      StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<S> subscription;

        controller = StreamController<T>(
            sync: true,
            onListen: () {
              subscription = input.listen((_) => controller.add(value),
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
