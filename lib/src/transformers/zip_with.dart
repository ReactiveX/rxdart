import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _ZipWithStreamSink<R, S, T> implements ForwardingWithSubscriptionSink<S> {
  final Stream<T> _other;
  final R Function(S, T) _mapper;
  final EventSink<R> _outputSink;
  StreamSubscription<T> _otherSubscription;
  StreamSubscription<S> _sourceSubscription;
  bool _selfClosed = false, _otherClosed = false;
  S _selfEvent;
  T _otherEvent;

  _ZipWithStreamSink(this._outputSink, this._other, this._mapper);

  @override
  set sourceSubscription(StreamSubscription<S> subscription) =>
      _sourceSubscription = subscription;

  @override
  void add(S data) {
    _selfEvent = data;
    _sourceSubscription.pause();

    _maybeAddEvent();
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    _selfClosed = true;
    _maybeClose();
  }

  @override
  FutureOr onCancel(EventSink<S> sink) {
    return _otherSubscription?.cancel();
  }

  @override
  void onListen(EventSink<S> sink) {
    _otherSubscription = _other.listen(
        (data) {
          _otherEvent = data;
          _otherSubscription.pause();

          _maybeAddEvent();
        },
        onError: addError,
        onDone: () {
          _otherClosed = true;
          _maybeClose();
        });
  }

  @override
  void onPause(EventSink<S> sink, [Future resumeSignal]) =>
      _otherSubscription?.pause(resumeSignal);

  @override
  void onResume(EventSink<S> sink) => _otherSubscription?.resume();

  void _maybeAddEvent() {
    if (_sourceSubscription.isPaused && _otherSubscription.isPaused) {
      final event = _mapper(_selfEvent, _otherEvent);

      _outputSink.add(event);

      _sourceSubscription.resume();
      _otherSubscription.resume();
    }
  }

  void _maybeClose() {
    if (_selfClosed && _otherClosed) {
      _outputSink.close();
    }
  }
}

/// Creates a [StreamTransformer] which zips the source [Stream] with the
/// events from the other [Stream].
///
/// ### Example
///
///     Stream.fromIterable([1])
///         .transform(ZipWithStreamTransformer(Stream.fromIterable([2]), (one, two) => one + two))
///         .listen(print); // prints 3
class ZipWithStreamTransformer<R, S, T> extends StreamTransformerBase<S, R> {
  /// The [Stream] which will be zipped with the source [Stream].
  final Stream<T> other;

  /// The zipper function.
  final R Function(S, T) mapper;

  /// Creates a [StreamTransformer] which zips the source [Stream] with the
  /// events from the other [Stream] using a [mapper] method.
  ZipWithStreamTransformer(this.other, this.mapper);

  @override
  Stream<R> bind(Stream<S> stream) {
    final forwardedStream = forwardStream<S>(stream);

    return Stream.eventTransformed(
        forwardedStream.stream,
        (sink) =>
            forwardedStream.connect(_ZipWithStreamSink(sink, other, mapper)));
  }
}

/// Extends the [Stream] class with the ability to zip one [Stream] with another.
extension ZipWithExtensions<T> on Stream<T> {
  /// Returns a [Stream] that combines the current stream together with another
  /// stream using a given mapper function.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///         .zipWith(Stream.fromIterable([2]), (one, two) => one + two)
  ///         .listen(print); // prints 3
  Stream<R> zipWith<R, S>(Stream<S> other, R Function(T, S) mapper) =>
      transform(ZipWithStreamTransformer(other, mapper));
}
