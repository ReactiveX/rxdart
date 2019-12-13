import 'dart:async';

/// Creates a [Stream] where all emitted items are ignored, only the
/// error / completed notifications are passed
///
/// ### Example
///
///     MergeStream([
///       Stream.fromIterable([1]),
///       ErrorStream(Exception())
///     ])
///     .listen(print, onError: print); // prints Exception
@Deprecated('Use the drain method from the Stream class instead')
class IgnoreElementsStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which simply ignores all events from
  /// the source [Stream], except for error or completed events.
  IgnoreElementsStreamTransformer() : _transformer = _buildTransformer();

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

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

/// Extends the Stream class with the ability to skip, or ignore, data events.
extension IgnoreElementsExtension<T> on Stream<T> {
  /// Creates a Stream where all emitted items are ignored, only the error /
  /// completed notifications are passed
  ///
  /// ### Example
  ///
  ///    MergeStream([
  ///      Stream.fromIterable([1]),
  ///      Stream.error(Exception())
  ///    ])
  ///    .listen(print, onError: print); // prints Exception
  @Deprecated('Use the drain method from the Stream class instead')
  Stream<T> ignoreElements() => transform(IgnoreElementsStreamTransformer<T>());
}
