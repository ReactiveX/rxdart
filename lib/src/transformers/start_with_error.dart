import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _StartWithErrorStreamSink<S> implements ForwardingSink<S> {
  final EventSink<S> _outputSink;
  final Object _e;
  final StackTrace _st;
  var _isFirstEventAdded = false;

  _StartWithErrorStreamSink(this._outputSink, this._e, this._st);

  @override
  void add(S data) {
    _addFirstEvent();
    _outputSink.add(data);
  }

  @override
  void addError(e, [st]) {
    _addFirstEvent();
    _outputSink.addError(e, st);
  }

  @override
  void close() {
    _addFirstEvent();
    _outputSink.close();
  }

  @override
  void onCancel() {}

  @override
  void onListen() => scheduleMicrotask(_addFirstEvent);

  @override
  void onPause() {}

  @override
  void onResume() {}

  void _addFirstEvent() {
    if (!_isFirstEventAdded) {
      _isFirstEventAdded = true;
      _outputSink.addError(_e, _st);
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
