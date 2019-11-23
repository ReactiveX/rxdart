import 'dart:async';

/// The defer factory waits until a listener subscribes to it, and then it
/// creates a Stream with the given factory function.
///
/// In some circumstances, waiting until the last minute (that is, until
/// subscription time) to generate the Stream can ensure that listeners
/// receive the freshest data.
///
/// By default, DeferStreams are single-subscription. However, it's possible
/// to make them reusable.
///
/// ### Example
///
///     DeferStream(() => Stream.value(1)).listen(print); //prints 1
class DeferStream<T> extends Stream<T> {
  final Stream<T> Function() _factory;
  final bool _isReusable;

  @override
  bool get isBroadcast => _isReusable;

  /// Constructs a [Stream] lazily, at the moment of subscription, using
  /// the [streamFactory]
  DeferStream(Stream<T> streamFactory(), {bool reusable = false})
      : _isReusable = reusable,
        _factory = reusable
            ? streamFactory
            : (() {
                Stream<T> stream;
                return () => stream ??= streamFactory();
              }());

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _factory().listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
