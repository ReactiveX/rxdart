import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// Returns an [Observable] that, when subscribed upon,
/// invokes a function you specify and then emits the value returned from that function.
///
/// The callable expects a return type of [FutureOr]
/// - if you return a [Future], it will be auto-awaited, so there is no need
///   to do [Observable.asyncMap] immediately.
/// - if you return a non-future, then that value is simply returned.
///
/// A FromCallableStream is always a broadcast [Stream].
///
/// ### Example
///
///     new FromCallableStream(() => 1).listen(print); //prints 1
///     new FromCallableStream(() => Future.value(1)).listen(print); //prints 1
class FromCallableStream<T> extends Stream<T> {
  final Stream<T> Function() _factory;

  @override
  bool get isBroadcast => true;

  FromCallableStream(FutureOr<T> callable())
      : _factory = (() {
          FutureOr<T> result;

          try {
            result = callable();

            if (result is Future<T>) {
              return Stream.fromFuture(result);
            } else {
              return Stream.fromIterable([result as T]);
            }
          } catch (e) {
            return Observable.error(e);
          }
        });

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _factory().listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
