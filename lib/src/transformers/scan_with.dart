import 'dart:async';

import 'package:rxdart/src/utils/forwarding_stream.dart';

import '../utils/forwarding_sink.dart';

class _ScanWithStreamSink<S, T> extends ForwardingSink<S, T> {
  final T Function(T accumulated, S value, int index) _accumulator;
  final T Function() _seedSupplier;

  late T _acc;
  late int _index;

  _ScanWithStreamSink(this._accumulator, this._seedSupplier);

  @override
  void onData(S data) => sink.add(_acc = _accumulator(_acc, data, _index++));

  @override
  void onDone() => sink.close();

  @override
  void onError(Object error, StackTrace st) => sink.addError(error, st);

  @override
  FutureOr<void> onListen() {
    _acc = _seedSupplier();
    _index = 0;
  }

  @override
  void onPause() {}

  @override
  void onResume() {}

  @override
  FutureOr<void> onCancel() {}
}

/// Applies an accumulator function over an stream sequence and returns
/// each intermediate result. The seed value is used as the initial
/// accumulator value.
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3])
///        .transform(ScanWithStreamTransformer(() => 0, (acc, curr, i) => acc + curr))
///        .listen(print); // prints 1, 3, 6
class ScanWithStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  /// Method which accumulates incoming event into a single, accumulated object
  final T Function(T accumulated, S value, int index) accumulator;

  /// The initial value for the accumulated value in the [accumulator]
  final T Function() seedSupplier;

  /// Constructs a [ScanWithStreamTransformer] which applies an accumulator Function
  /// over the source [Stream] and returns each intermediate result.
  /// The seed value is used as the initial accumulator value.
  ScanWithStreamTransformer(this.seedSupplier, this.accumulator);

  @override
  Stream<T> bind(Stream<S> stream) => forwardStream(
      stream, () => _ScanWithStreamSink<S, T>(accumulator, seedSupplier));
}

/// Extends
extension ScanWithExtension<T> on Stream<T> {
  /// Applies an accumulator function over a Stream sequence and returns each
  /// intermediate result. The seed value is used as the initial
  /// accumulator value.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///        .scanWith(() => 0, (acc, curr, i) => acc + curr)
  ///        .listen(print); // prints 1, 3, 6
  Stream<S> scanWith<S>(
    S Function() seedSupplier,
    S Function(S accumulated, T value, int index) accumulator,
  ) =>
      ScanWithStreamTransformer<T, S>(seedSupplier, accumulator).bind(this);
}
