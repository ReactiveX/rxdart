import 'dart:async';

/// Applies an accumulator function over an observable sequence and returns
/// each intermediate result. The optional seed value is used as the initial
/// accumulator value.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///        .transform(new ScanStreamTransformer((acc, curr, i) => acc + curr, 0))
///        .listen(print); // prints 1, 3, 6
class ScanStreamTransformer<T, S> extends StreamTransformerBase<T, S> {
  final _ScanStreamTransformerAccumulator<T, S> accumulator;
  final S seed;

  ScanStreamTransformer(this.accumulator, [this.seed]);

  @override
  Stream<S> bind(Stream<T> stream) =>
      _buildTransformer<T, S>(accumulator, seed).bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      S accumulator(S accumulated, T value, int index),
      [S seed]) {
    return StreamTransformer<T, S>((input, bool cancelOnError) {
      var index = 0;
      var acc = seed;
      StreamController<S> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<S>(
          sync: true,
          onListen: () {
            subscription = input.listen((value) {
              try {
                acc = accumulator(acc, value, index++);

                controller.add(acc);
              } catch (e, s) {
                controller.addError(e, s);
              }
            },
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

typedef _ScanStreamTransformerAccumulator<T, S> = S Function(
    S accumulated, T value, int index);
