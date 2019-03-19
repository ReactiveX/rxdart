import 'dart:async';

/// Emits the given value after a specified amount of time.
///
/// ### Example
///
///     new TimerStream("hi", new Duration(minutes: 1))
///         .listen((i) => print(i)); // print "hi" after 1 minute
class TimerStream<T> extends Stream<T> {
  final T _value;
  final Duration _duration;
  final Stream<T> Function() _streamFactory;

  TimerStream(this._value, this._duration)
      : _streamFactory = (() {
          final stream =
              Stream.fromFuture(Future.delayed(_duration, () => _value));

          return () => stream;
        })();

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _streamFactory().listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
