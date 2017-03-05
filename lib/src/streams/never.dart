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
  StreamController<T> controller = new StreamController<T>();

  NeverStream();

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
