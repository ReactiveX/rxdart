import 'dart:async';

/// The defer factory waits until an observer subscribes to it, and then it
/// creates an Observable with the given factory function.
///
/// In some circumstances, waiting until the last minute (that is, until
/// subscription time) to generate the Observable can ensure that this
/// Observable contains the freshest data.
///
/// By default, DeferStreams are single-subscription. However, it's possible
/// to make them reusable.
///
/// ### Example
///
///     new DeferStream(() => new Observable.just(1)).listen(print); //prints 1
class DeferStream<T> extends Stream<T> {
  final Stream<T> Function() _factory;
  final bool _isReusable;

  @override
  bool get isBroadcast => _isReusable;

  DeferStream(Stream<T> streamFactory(), {bool reusable = false})
      : _isReusable = reusable,
        _factory = reusable
            ? (() => streamFactory())
            : (() {
                final stream = streamFactory();

                return () => stream;
              }());

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _factory().listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
