import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _MergeWithStreamSink<S> implements ForwardingSink<S> {
  final Stream<S> _other;
  final EventSink<S> _outputSink;
  bool isSelfDone = false, isOtherDone = false;
  StreamSubscription<S> _otherSubscription;

  _MergeWithStreamSink(this._outputSink, this._other);

  @override
  void add(S data) => _outputSink.add(data);

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    isSelfDone = true;

    _maybeClose();
  }

  @override
  FutureOr onCancel(EventSink<S> sink) => _otherSubscription?.cancel();

  @override
  void onListen(EventSink<S> sink) {
    _otherSubscription = _other.listen(add, onError: addError, onDone: () {
      isOtherDone = true;

      _maybeClose();
    });
  }

  @override
  void onPause(EventSink<S> sink, [Future resumeSignal]) =>
      _otherSubscription?.pause(resumeSignal);

  @override
  void onResume(EventSink<S> sink) => _otherSubscription?.resume();

  void _maybeClose() {
    if (isSelfDone && isOtherDone) {
      _outputSink.close();
    }
  }
}

/// Returns a [StreamTransformer] that emits all items from the current [Stream],
/// merged with all items from the other [stream].
///
/// ### Example
///
///     TimerStream(1, Duration(seconds: 10))
///         .transform(MergeWithStreamTransformer(Stream.fromIterable([2])))
///         .listen(print); // prints 2, 1
class MergeWithStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The [Stream] that will be merged into this [Stream].
  final Stream<S> other;

  /// Constructs a [StreamTransformer] which plays all events from the source [Stream],
  /// merged with the events from [other].
  MergeWithStreamTransformer(this.other);

  @override
  Stream<S> bind(Stream<S> stream) {
    final forwardedStream = forwardStream<S>(stream);

    return Stream.eventTransformed(
        forwardedStream.stream,
        (sink) =>
            forwardedStream.connect(_MergeWithStreamSink<S>(sink, other)));
  }
}

/// Extends the [Stream] class with the ability to merge one [Stream] with another.
extension MergeWithExtension<T> on Stream<T> {
  /// Combines the items emitted by multiple streams into a single stream of
  /// items. The items are emitted in the order they are emitted by their
  /// sources.
  ///
  /// ### Example
  ///
  ///     TimerStream(1, Duration(seconds: 10))
  ///         .mergeWith(Stream.fromIterable([2]))
  ///         .listen(print); // prints 2, 1
  Stream<T> mergeWith(Stream<T> other) =>
      transform(MergeWithStreamTransformer<T>(other));
}
