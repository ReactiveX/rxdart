import 'dart:async';

import 'package:rxdart/src/utils/on_listen_stream.dart';

class _StartWithErrorStreamSink<S>
    implements EventSink<OnListenStreamEvent<S>> {
  final EventSink<S> _outputSink;
  final Object _e;
  final StackTrace _st;

  _StartWithErrorStreamSink(this._outputSink, this._e, this._st);

  @override
  void add(OnListenStreamEvent<S> data) {
    if (data.isOnListenEvent) {
      _outputSink.addError(_e, _st);
    } else {
      _outputSink.add(data.event);
    }
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() => _outputSink.close();
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
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      toOnListenEnabledStream(stream),
      (sink) => _StartWithErrorStreamSink<S>(sink, error, stackTrace));

  Stream<S> _startWithStream(Stream<S> stream) async* {
    yield null;
    yield* stream;
  }
}
