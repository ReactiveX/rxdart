import 'dart:async';

import 'package:rxdart/src/utils/on_listen_stream.dart';

class _StartWithStreamSink<S> implements EventSink<OnListenStreamEvent<S>> {
  final S _startValue;
  final EventSink<S> _outputSink;

  _StartWithStreamSink(this._outputSink, this._startValue);

  @override
  void add(OnListenStreamEvent<S> data) {
    if (data.isOnListenEvent) {
      _outputSink.add(_startValue);
    } else {
      _outputSink.add(data.event);
    }
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() => _outputSink.close();
}

/// Prepends a value to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithStreamTransformer(1))
///       .listen(print); // prints 1, 2
class StartWithStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The starting event of this [Stream]
  final S startValue;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with [startValue].
  StartWithStreamTransformer(this.startValue);

  @override
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      toOnListenEnabledStream(stream),
      (sink) => _StartWithStreamSink<S>(sink, startValue));
}

/// Extends the Stream class with the ability to emit the given value as the
/// first item.
extension StartWithExtension<T> on Stream<T> {
  /// Prepends a value to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([2]).startWith(1).listen(print); // prints 1, 2
  Stream<T> startWith(T startValue) =>
      transform(StartWithStreamTransformer<T>(startValue));
}
