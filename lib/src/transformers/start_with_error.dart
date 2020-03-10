import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _StartWithErrorStreamSink<S> implements ForwardingSink<S> {
  final EventSink<S> _outputSink;
  final Object _e;
  final StackTrace _st;
  EventSink<S> _sink;
  var _isFirstEventAdded = false;

  _StartWithErrorStreamSink(this._outputSink, this._e, this._st);

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
      _sink.addError(_e, _st);
    }
  }
}

/// Prepends an error to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithErrorStreamTransformer('error'))
///       .listen(null, onError: (e) => print(e)); // prints 'error'
class StartWithErrorStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The starting error of this [Stream]
  final Object error;

  /// The starting stackTrace of this [Stream]
  final StackTrace stackTrace;

  /// Constructs a [StreamTransformer] which starts with the provided [error]
  /// and then outputs all events from the source [Stream].
  StartWithErrorStreamTransformer(this.error, [this.stackTrace]);

  @override
  Stream<S> bind(Stream<S> stream) {
    final forwardedStream = forwardStream<S>(stream);

    return Stream.eventTransformed(
        forwardedStream.stream,
        (sink) => forwardedStream
            .connect(_StartWithErrorStreamSink<S>(sink, error, stackTrace)));
  }
}
