import 'dart:async';

import 'package:rxdart/src/utils/on_listen_stream.dart';

class _TakeUntilStreamSink<S, T> implements EventSink<OnListenStreamEvent<S>> {
  final Stream<T> _otherStream;
  final EventSink<S> _outputSink;
  StreamSubscription<T> _otherSubscription;

  _TakeUntilStreamSink(this._outputSink, this._otherStream);

  @override
  void add(OnListenStreamEvent<S> data) {
    if (data.isOnListenEvent) {
      _otherSubscription = _otherStream.take(1).listen(null,
          onError: _outputSink.addError, onDone: _outputSink.close);
    } else {
      _outputSink.add(data.event);
    }
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    _otherSubscription?.cancel();
    _outputSink.close();
  }
}

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
class TakeUntilStreamTransformer<S, T> extends StreamTransformerBase<S, S> {
  /// The [Stream] which closes this [Stream] as soon as it emits an event.
  final Stream<T> otherStream;

  /// Constructs a [StreamTransformer] which emits events from the source [Stream],
  /// until [otherStream] fires.
  TakeUntilStreamTransformer(this.otherStream) {
    if (otherStream == null) {
      throw ArgumentError('otherStream cannot be null');
    }
  }

  @override
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      toOnListenEnabledStream(stream),
      (sink) => _TakeUntilStreamSink<S, T>(sink, otherStream));
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
