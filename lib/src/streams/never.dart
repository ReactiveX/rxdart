import 'dart:async';

/// Returns a non-terminating observable sequence, which can be used to denote
/// an infinite duration.
///
/// The never operator is one with very specific and limited behavior. These
/// are useful for testing purposes, and sometimes also for combining with
/// other Observables or as parameters to operators that expect other
/// Observables as parameters.
///
/// ### Example
///
///     new NeverStream().listen(print); // Neither prints nor terminates
class NeverStream<T> extends Stream<T> {
  // ignore: close_sinks
  StreamController<T> _controller = StreamController<T>();

  /// Constructs a [Stream] which never emits an event and simply remains
  /// open until implicitly closed by the developer.
  NeverStream();

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
