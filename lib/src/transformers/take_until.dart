import 'dart:async';

/// Returns the values from the source stream sequence until the other
/// stream sequence produces a value.
///
/// ### Example
///
///     MergeStream([
///         Stream.fromIterable([1]),
///         TimerStream(2, Duration(minutes: 1))
///       ])
///       .transform(TakeUntilStreamTransformer(
///         TimerStream(3, Duration(seconds: 10))))
///       .listen(print); // prints 1
class TakeUntilStreamTransformer<T, S> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which emits events from the source [Stream],
  /// until [otherStream] fires.
  TakeUntilStreamTransformer(Stream<S> otherStream)
      : _transformer = _buildTransformer(otherStream);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T, S>(
      Stream<S> otherStream) {
    if (otherStream == null) {
      throw ArgumentError('take until stream cannot be null');
    }
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> otherSubscription;

      void onDone() {
        if (controller.isClosed) return;

        controller.close();
      }

      controller = StreamController<T>(
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

/// Extends the Stream class with the ability receive events from the source
/// Stream until another Stream produces a value.
extension TakeUntilExtension<T> on Stream<T> {
  /// Returns the values from the source Stream sequence until the other Stream
  /// sequence produces a value.
  ///
  /// ### Example
  ///
  ///     MergeStream([
  ///         Stream.fromIterable([1]),
  ///         TimerStream(2, Duration(minutes: 1))
  ///       ])
  ///       .takeUntil(TimerStream(3, Duration(seconds: 10)))
  ///       .listen(print); // prints 1
  Stream<T> takeUntil<S>(Stream<S> otherStream) =>
      transform(TakeUntilStreamTransformer<T, S>(otherStream));
}
