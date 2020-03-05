import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Applies an accumulator function over an stream sequence and returns
/// each intermediate result. The optional seed value is used as the initial
/// accumulator value.
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3])
///        .transform(ScanStreamTransformer((acc, curr, i) => acc + curr, 0))
///        .listen(print); // prints 1, 3, 6
class ScanStreamTransformer<T, S> extends StreamTransformerBase<T, S> {
  /// Method which accumulates incoming event into a single, accumulated object
  final S Function(S accumulated, T value, int index) accumulator;
  /// The initial value for the accumulated value in the [accumulator]
  final S seed;

  /// Constructs a [ScanStreamTransformer] which applies an accumulator Function
  /// over the source [Stream] and returns each intermediate result.
  /// The optional seed value is used as the initial accumulator value.
  ScanStreamTransformer(this.accumulator, [this.seed]);

  @override
  Stream<S> bind(Stream<T> stream) {
    var index = 0;
    var acc = seed;
    StreamController<S> controller;
    StreamSubscription<T> subscription;

    controller = createController(stream,
        onListen: () {
          subscription = stream.listen((value) {
            try {
              acc = accumulator(acc, value, index++);

              controller.add(acc);
            } catch (e, s) {
              controller.addError(e, s);
            }
          }, onError: controller.addError, onDone: controller.close);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream;
  }
}

/// Extends
extension ScanExtension<T> on Stream<T> {
  /// Applies an accumulator function over a Stream sequence and returns each
  /// intermediate result. The optional seed value is used as the initial
  /// accumulator value.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///        .scan((acc, curr, i) => acc + curr, 0)
  ///        .listen(print); // prints 1, 3, 6
  Stream<S> scan<S>(
    S Function(S accumulated, T value, int index) accumulator, [
    S seed,
  ]) =>
      transform(ScanStreamTransformer<T, S>(accumulator, seed));
}
