import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _TakeUntilStreamSink<S, T> implements ForwardingSink<S> {
  final Stream<T> _otherStream;
  final EventSink<S> _outputSink;
  StreamSubscription<T> _otherSubscription;

  _TakeUntilStreamSink(this._outputSink, this._otherStream);

  @override
  void add(S data) => _outputSink.add(data);

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    _otherSubscription?.cancel();
    _outputSink.close();
  }

  @override
  FutureOr onCancel() {}

  @override
  void onListen() => _otherSubscription = _otherStream
      .take(1)
      .listen(null, onError: addError, onDone: _outputSink.close);

  @override
  void onPause() {}

  @override
  void onResume() {}
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
  Stream<S> bind(Stream<S> stream) {
    final forwardedStream = forwardStream<S>(stream);

    return Stream.eventTransformed(
        forwardedStream.stream,
        (sink) => forwardedStream
            .connect(_TakeUntilStreamSink<S, T>(sink, otherStream)));
  }
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
