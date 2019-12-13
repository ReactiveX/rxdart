import 'dart:async';

/// Converts events from the source stream into a new Stream using a given
/// mapper. It ignores all items from the source stream until the new stream
/// completes.
///
/// Useful when you have a noisy source Stream and only want to respond once
/// the previous async operation is finished.
///
/// ### Example
///     // Emits 0, 1, 2
///     Stream.periodic(Duration(milliseconds: 200), (i) => i).take(3)
///       .transform(ExhaustMapStreamTransformer(
///         // Emits the value it's given after 200ms
///         (i) => Rx.timer(i, Duration(milliseconds: 200)),
///       ))
///     .listen(print); // prints 0, 2
class ExhaustMapStreamTransformer<T, S> extends StreamTransformerBase<T, S> {
  final StreamTransformer<T, S> _transformer;

  /// Constructs a [StreamTransformer] which maps events from the source [Stream] using [mapper].
  ///
  /// It ignores all items from the source [Stream] until the mapped [Stream] completes.
  ExhaustMapStreamTransformer(Stream<S> Function(T value) mapper)
      : _transformer = _buildTransformer(mapper);

  @override
  Stream<S> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      Stream<S> Function(T value) mapper) {
    return StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<T> inputSubscription;
      StreamSubscription<S> outputSubscription;
      var inputClosed = false, outputIsEmitting = false;

      controller = StreamController<S>(
        sync: true,
        onListen: () {
          inputSubscription = input.listen(
            (T value) {
              try {
                if (!outputIsEmitting) {
                  outputIsEmitting = true;
                  outputSubscription = mapper(value).listen(
                    controller.add,
                    onError: controller.addError,
                    onDone: () {
                      outputIsEmitting = false;
                      if (inputClosed) controller.close();
                    },
                  );
                }
              } catch (e, s) {
                controller.addError(e, s);
              }
            },
            onError: controller.addError,
            onDone: () {
              inputClosed = true;
              if (!outputIsEmitting) controller.close();
            },
            cancelOnError: cancelOnError,
          );
        },
        onPause: ([Future<dynamic> resumeSignal]) {
          inputSubscription.pause(resumeSignal);
          outputSubscription?.pause(resumeSignal);
        },
        onResume: () {
          inputSubscription.resume();
          outputSubscription?.resume();
        },
        onCancel: () async {
          await inputSubscription.cancel();
          if (outputIsEmitting) await outputSubscription.cancel();
        },
      );

      return controller.stream.listen(null);
    });
  }
}

/// Extends the Stream class with the ability to transform the Stream into
/// a new Stream. The new Stream emits items and ignores events from the source
/// Stream until the new Stream completes.
extension ExhaustMapExtension<T> on Stream<T> {
  /// Converts items from the source stream into a Stream using a given
  /// mapper. It ignores all items from the source stream until the new stream
  /// completes.
  ///
  /// Useful when you have a noisy source Stream and only want to respond once
  /// the previous async operation is finished.
  ///
  /// ### Example
  ///
  ///     RangeStream(0, 2).interval(Duration(milliseconds: 50))
  ///       .exhaustMap((i) =>
  ///         TimerStream(i, Duration(milliseconds: 75)))
  ///       .listen(print); // prints 0, 2
  Stream<S> exhaustMap<S>(Stream<S> Function(T value) mapper) =>
      transform(ExhaustMapStreamTransformer<T, S>(mapper));
}
