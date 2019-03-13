import 'dart:async';

/// Emits the given value after a specified amount of time.
///
/// ### Example
///
///     new TimerStream("hi", new Duration(minutes: 1))
///         .listen((i) => print(i)); // print "hi" after 1 minute
class TimerStream<T> extends Stream<T> {
  final Stream<T> stream;

  TimerStream(T value, Duration duration)
      : stream = Stream.fromFuture(duration != null
            ? Future.delayed(duration, () => value)
            : Future.value(value));

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
