import 'dart:async';

/// Converts items from the source stream into a new Stream using a given
/// mapper. It ignores all items from the source stream until the new stream
/// completes.
///
/// Useful when you have a noisy source Stream and only want to respond once
/// the previous async operation is finished.
///
/// ### Example
///     // Emits 0, 1, 2
///     new Stream.periodic(new Duration(milliseconds: 200), (i) => i).take(3)
///       .transform(new ExhaustMapStreamTransformer(
///         // Emits the value it's given after 200ms
///         (i) => new Observable.timer(i, new Duration(milliseconds: 200)),
///       ))
///     .listen(print); // prints 0, 2
class ExhaustMapStreamTransformer<T, S> extends StreamTransformerBase<T, S> {
  final StreamTransformer<T, S> transformer;

  ExhaustMapStreamTransformer(Stream<S> mapper(T value))
      : transformer = _buildTransformer(mapper);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      Stream<S> mapper(T value)) {
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
