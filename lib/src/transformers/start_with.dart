import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _StartWithStreamSink<S> implements ForwardingSink<S> {
  final S _startValue;
  final bool _sync;
  final EventSink<S> _outputSink;
  EventSink<S> _sink;
  var _isFirstEventAdded = false;

  _StartWithStreamSink(this._outputSink, this._sync, this._startValue);

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
  void close() {
    _safeAddFirstEvent();
    _outputSink.close();
  }

  @override
  FutureOr onCancel(EventSink<S> sink) {}

  @override
  void onListen(EventSink<S> sink) {
    _sink = sink;

    _sync ? _safeAddFirstEvent() : scheduleMicrotask(_safeAddFirstEvent);
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
      _sink.add(_startValue);
    }
  }
}

/// Prepends a value to the source [Stream].
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithStreamTransformer(1))
///       .listen(print); // prints 1, 2
class StartWithStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The starting event of this [Stream]
  final S startValue;

  /// @internal
  /// Forces startWith to happen either sync or async
  final bool sync;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with [startValue].
  StartWithStreamTransformer(this.startValue, {this.sync = false});

  @override
  Stream<S> bind(Stream<S> stream) {
    final forwardedStream = forwardStream<S>(stream);

    return Stream.eventTransformed(
        forwardedStream.stream,
        (sink) => forwardedStream
            .connect(_StartWithStreamSink<S>(sink, sync, startValue)));
  }
}

/// Extends the [Stream] class with the ability to emit the given value as the
/// first item.
extension StartWithExtension<T> on Stream<T> {
  /// Prepends a value to the source [Stream].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([2]).startWith(1).listen(print); // prints 1, 2
  Stream<T> startWith(T startValue) =>
      transform(StartWithStreamTransformer<T>(startValue));
}
