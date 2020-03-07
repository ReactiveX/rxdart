import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _StartWithStreamSink<S> implements ForwardingSink<S> {
  final S _startValue;
  final EventSink<S> _outputSink;
  var _isFirstEventAdded = false;

  _StartWithStreamSink(this._outputSink, this._startValue);

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
  FutureOr onCancel() {}

  @override
  void onListen() => scheduleMicrotask(_addFirstEvent);

  @override
  void onPause() {}

  @override
  void onResume() {}

  void _addFirstEvent() {
    if (!_isFirstEventAdded) {
      _isFirstEventAdded = true;
      _outputSink.add(_startValue);
    }
  }
}

/// Prepends a value to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithStreamTransformer(1))
///       .listen(print); // prints 1, 2
class StartWithStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The starting event of this [Stream]
  final S startValue;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with [startValue].
  StartWithStreamTransformer(this.startValue);

  @override
  Stream<S> bind(Stream<S> stream) {
    final forwardedStream = forwardStream<S>(stream);

    return Stream.eventTransformed(
        forwardedStream.stream,
        (sink) =>
            forwardedStream.connect(_StartWithStreamSink<S>(sink, startValue)));
  }
}

/// Extends the Stream class with the ability to emit the given value as the
/// first item.
extension StartWithExtension<T> on Stream<T> {
  /// Prepends a value to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([2]).startWith(1).listen(print); // prints 1, 2
  Stream<T> startWith(T startValue) =>
      transform(StartWithStreamTransformer<T>(startValue));
}
