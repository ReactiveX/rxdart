import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/futures/wrapped_future.dart';

/// A future that can be converted directly to an Observable using
/// the `asObservable` method.
///
/// This class simply wraps a normal Future, providing one additional method
/// for more fluent interoperability with the Observable class.
///
/// Example:
///
///     new Observable.fromIterable(["hello", "friends"])
///         .join(" ") // Returns an AsObservableFuture
///         .asObservable() // Fluently convert the Future back to an Observable
///         .flatMap((message) => new Observable.just(message.length)); // Use the operators you need
class AsObservableFuture<T> extends WrappedFuture<T> {
  /// Wraps a [Future] so that it can be exposed again as an [Observable].
  AsObservableFuture(Future<T> wrapped) : super(wrapped);

  /// Returns an [Observable] containing the value from the wrapped [Future].
  Observable<T> asObservable() => Observable<T>.fromFuture(wrapped);
}
