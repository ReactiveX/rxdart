import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _StartWithManyStreamSink<S> implements ForwardingSink<S> {
  final Iterable<S> _startValues;
  final EventSink<S> _outputSink;
  EventSink<S> _sink;
  var _isFirstEventAdded = false;

  _StartWithManyStreamSink(this._outputSink, this._startValues);

  @override
  void add(S data) {
    _safeAddFirstEvent();
    _outputSink.add(data);
  }

  @override
  void addError(e, [st]) {
    _safeAddFirstEvent();
    _outputSink.addError(e, st);
  }

  @override
  Future safeClose() => null;

  @override
  void close() {
    _safeAddFirstEvent();
    _outputSink.close();
  }

  @override
  FutureOr onCancel(EventSink<S> sink) {}

  @override
  void onListen(EventSink<S> sink) {
    _sink = sink;

    scheduleMicrotask(_safeAddFirstEvent);
  }

  @override
  void onPause(EventSink<S> sink, [Future resumeSignal]) {}

  @override
  void onResume(EventSink<S> sink) {}

  // Immediately setting the starting value when onListen trigger can
  // result in an Exception (might be a bug in dart:async?)
  // Therefore, scheduleMicrotask is used after onListen.
  // Because events could be added before scheduleMicrotask completes,
  // this method is ran before any other events might be added.
  // Once the first event(s) is/are successfully added, this method
  // will not trigger again.
  void _safeAddFirstEvent() {
    if (!_isFirstEventAdded && _sink != null) {
      _isFirstEventAdded = true;

      for (var i = 0, len = _startValues.length; i < len; i++) {
        _sink.add(_startValues.elementAt(i));
      }
    }
  }
}

/// Prepends a sequence of values to the source [Stream].
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
  /// with [startValues].
  StartWithManyStreamTransformer(this.startValues) {
    if (startValues == null) {
      throw ArgumentError('startValues cannot be null');
    }
  }

  @override
  Stream<S> bind(Stream<S> stream) {
    final forwardedStream = forwardStream<S>(stream);

    return Stream.eventTransformed(
        forwardedStream.stream,
        (sink) => forwardedStream
            .connect(_StartWithManyStreamSink<S>(sink, startValues)));
  }
}

/// Extends the [Stream] class with the ability to emit the given values as the
/// first items.
extension StartWithManyExtension<T> on Stream<T> {
  /// Prepends a sequence of values to the source [Stream].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([3]).startWithMany([1, 2])
  ///       .listen(print); // prints 1, 2, 3
  Stream<T> startWithMany(List<T> startValues) =>
      transform(StartWithManyStreamTransformer<T>(startValues));
}
