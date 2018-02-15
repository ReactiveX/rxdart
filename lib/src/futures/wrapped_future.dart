import 'dart:async';

/// A future that simply wraps another Future.
///
/// This Future provides no additional functionality to the passed in Future
/// by default. This is meant as a base implementation that allows you to extend
/// Futures you can't directly create.
///
/// For example, the AsObservableFuture adds one method to the Futures returned
/// by some Stream methods.
class WrappedFuture<T> implements Future<T> {
  final Future<T> wrapped;

  WrappedFuture(this.wrapped);

  @override
  Stream<T> asStream() => wrapped.asStream();

  @override
  Future<T> catchError(Function onError, {bool test(Object error)}) =>
      wrapped.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> onValue(T value), {Function onError}) =>
      wrapped.then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> onTimeout()}) =>
      wrapped.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(void action()) => wrapped.whenComplete(action);
}
