import 'dart:async';

class _EndWithErrorStreamSink<S> implements EventSink<S> {
  final Object _e;
  final StackTrace _st;
  final EventSink<S> _outputSink;

  _EndWithErrorStreamSink(this._outputSink, this._e, this._st);

  @override
  void add(S data) => _outputSink.add(data);

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    _outputSink.addError(_e, _st);
    _outputSink.close();
  }
}

/// Appends an error to the source [Stream] before closing.
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(EndWithErrorStreamTransformer('error'))
///       .listen(null, onError: (e) => print(e)); // prints 'error'
class EndWithErrorStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The ending error of this [Stream]
  final Object error;

  /// The ending stackTrace of this [Stream]
  final StackTrace stackTrace;

  /// Constructs a [StreamTransformer] which outputs all events from the source [Stream]
  /// and then ends with the provided [error].
  EndWithErrorStreamTransformer(this.error, this.stackTrace);

  @override
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      stream, (sink) => _EndWithErrorStreamSink<S>(sink, error, stackTrace));
}
