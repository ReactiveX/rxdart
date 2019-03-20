import 'dart:async';

/// Emits the given value after a specified amount of time.
///
/// ### Example
///
///     new TimerStream("hi", new Duration(minutes: 1))
///         .listen((i) => print(i)); // print "hi" after 1 minute
class TimerStream<T> extends Stream<T> {
  final Stream<T> Function() _streamFactory;

  TimerStream(T value, Duration duration)
      : _streamFactory = (() {
          final stream =
              Stream.fromFuture(Future.delayed(duration, () => value));

          return () => stream;
        })();

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _streamFactory().listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
