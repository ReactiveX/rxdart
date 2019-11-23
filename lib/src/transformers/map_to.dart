import 'dart:async';

/// Emits the given constant value on the output Stream every time the source
/// Stream emits a value.
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3, 4])
///       .mapTo(true)
///       .listen(print); // prints true, true, true, true
class MapToStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> _transformer;

  /// Constructs a [StreamTransformer] which always maps every event from
  /// the source [Stream] to a constant [value].
  MapToStreamTransformer(T value) : _transformer = _buildTransformer(value);

  @override
  Stream<T> bind(Stream<S> stream) => _transformer.bind(stream);

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

/// Extends the Stream class with the ability to convert each item to the same
/// value.
extension MapToExtension<T> on Stream<T> {
  /// Emits the given constant value on the output Stream every time the source
  /// Stream emits a value.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4])
  ///       .mapTo(true)
  ///       .listen(print); // prints true, true, true, true
  Stream<S> mapTo<S>(S value) => transform(MapToStreamTransformer<T, S>(value));
}
