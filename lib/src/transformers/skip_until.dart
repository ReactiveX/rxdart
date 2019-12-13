import 'dart:async';

/// Starts emitting events only after the given stream emits an event.
///
/// ### Example
///
///     MergeStream([
///       Stream.value(1),
///       TimerStream(2, Duration(minutes: 2))
///     ])
///     .transform(skipUntilTransformer(TimerStream(1, Duration(minutes: 1))))
///     .listen(print); // prints 2;
class SkipUntilStreamTransformer<T, S> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which starts emitting events
  /// only after [otherStream] emits an event.
  SkipUntilStreamTransformer(Stream<S> otherStream)
      : _transformer = _buildTransformer(otherStream);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T, S>(
      Stream<S> otherStream) {
    if (otherStream == null) {
      throw ArgumentError('otherStream cannot be null');
    }

    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> otherSubscription;
      var goTime = false;

      void onDone() {
        if (controller.isClosed) return;

        controller.close();
      }

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen((T data) {
              if (goTime) {
                controller.add(data);
              }
            },
                onError: controller.addError,
                onDone: onDone,
                cancelOnError: cancelOnError);

            otherSubscription = otherStream.listen((_) {
              goTime = true;

              otherSubscription.cancel();
            },
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

/// Extends the Stream class with the ability to skip events until another
/// Stream emits an item.
extension SkipUntilExtension<T> on Stream<T> {
  /// Starts emitting items only after the given stream emits an item.
  ///
  /// ### Example
  ///
  ///     MergeStream([
  ///         Stream.fromIterable([1]),
  ///         TimerStream(2, Duration(minutes: 2))
  ///       ])
  ///       .skipUntil(TimerStream(true, Duration(minutes: 1)))
  ///       .listen(print); // prints 2;
  Stream<T> skipUntil<S>(Stream<S> otherStream) =>
      transform(SkipUntilStreamTransformer<T, S>(otherStream));
}
