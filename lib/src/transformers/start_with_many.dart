import 'dart:async';

import 'package:rxdart/src/utils/on_listen_stream.dart';

class _StartWithManyStreamSink<S> implements EventSink<OnListenStreamEvent<S>> {
  final Iterable<S> _startValues;
  final EventSink<S> _outputSink;

  _StartWithManyStreamSink(this._outputSink, this._startValues);

  @override
  void add(OnListenStreamEvent<S> data) {
    if (data.isOnListenEvent) {
      for (var i = 0, len = _startValues.length; i < len; i++) {
        _outputSink.add(_startValues.elementAt(i));
      }
    } else {
      _outputSink.add(data.event);
    }
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() => _outputSink.close();
}

/// Prepends a sequence of values to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([3])
///       .transform(StartWithManyStreamTransformer([1, 2]))
///       .listen(print); // prints 1, 2, 3
class StartWithManyStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The starting events of this [Stream]
  final Iterable<S> startValues;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with [startValue].
  StartWithManyStreamTransformer(this.startValues) {
    if (startValues == null) {
      throw ArgumentError('startValues cannot be null');
    }
  }

  @override
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      toOnListenEnabledStream(stream),
      (sink) => _StartWithManyStreamSink<S>(sink, startValues));
}

/// Extends the Stream class with the ability to emit the given values as the
/// first items.
extension StartWithManyExtension<T> on Stream<T> {
  /// Prepends a sequence of values to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([3]).startWithMany([1, 2])
  ///       .listen(print); // prints 1, 2, 3
  Stream<T> startWithMany(List<T> startValues) =>
      transform(StartWithManyStreamTransformer<T>(startValues));
}
