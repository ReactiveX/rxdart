import 'dart:async';

/// Returns an observable sequence that emits an [_error], then immediately
/// completes.
///
/// The error operator is one with very specific and limited behavior. It is
/// mostly useful for testing purposes.
///
/// ### Example
///
///     new ErrorStream(new ArgumentError());
class ErrorStream<T> extends Stream<T> {
  final Object _error;
  StreamController<T> _controller = StreamController<T>();

  /// Constructs a [Stream] which immediately throws an error and then
  /// subsequently closes.
  ErrorStream(this._error);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    _controller
      ..addError(_error)
      ..close();

    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
