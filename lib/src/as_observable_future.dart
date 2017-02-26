import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// A future that can be converted directly to an Observable using
/// the `asObservable` method.
///
/// This class simply wraps a normal Future, providing one additional method
/// for more fluent interoperability with the Observable class.
///
/// Example:
///
///   new Observable.fromIterable([1, 2, 3]).last.asObservable(); // .flatMap...
class AsObservableFuture<T> implements Future<T> {
  final Future<T> wrapped;

  AsObservableFuture(this.wrapped);

  Observable<T> asObservable() => new Observable<T>.fromFuture(wrapped);

  @override
  Stream<T> asStream() => wrapped.asStream();

  @override
  Future<T> catchError(Function onError, {bool test(Object error)}) =>
      wrapped.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> onValue(T value), {Function onError}) => wrapped
      .then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {onTimeout()}) =>
      wrapped.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(action()) => wrapped.whenComplete(action);
}
