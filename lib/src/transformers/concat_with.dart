import 'dart:async';

class _ConcatWithStreamSink<S> implements EventSink<S> {
  final Stream<S> _other;
  final EventSink<S> _outputSink;

  _ConcatWithStreamSink(this._outputSink, this._other);

  @override
  void add(S data) => _outputSink.add(data);

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() =>
      _other.listen(add, onError: addError, onDone: _outputSink.close);
}

/// Returns a [StreamTransformer] that emits all items from the current [Stream],
/// then emits all items from the other [stream].
///
/// ### Example
///
///     TimerStream(1, Duration(seconds: 10))
///         .transform(ConcatWithStreamTransformer(Stream.fromIterable([2])))
///         .listen(print); // prints 1, 2
class ConcatWithStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The [Stream] which will be appended on done.
  final Stream<S> other;

  /// Constructs a [StreamTransformer] which plays all events from the source [Stream],
  /// when done, it will continue with the events from [other].
  ConcatWithStreamTransformer(this.other);

  @override
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      stream, (sink) => _ConcatWithStreamSink<S>(sink, other));
}

/// Extends the [Stream] class with the ability to concatenate one stream with
/// another.
extension ConcatExtensions<T> on Stream<T> {
  /// Returns a [Stream] that emits all items from the current [Stream],
  /// then emits all items from the other [Stream].
  ///
  /// ### Example
  ///
  ///     TimerStream(1, Duration(seconds: 10))
  ///         .concatWith(Stream.fromIterable([2]))
  ///         .listen(print); // prints 1, 2
  Stream<T> concatWith(Stream<T> other) =>
      transform(ConcatWithStreamTransformer<T>(other));
}
