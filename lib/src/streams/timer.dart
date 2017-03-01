import 'dart:async';

/// Emits the given value after a specified amount of time.
///
/// ### Example
///
///     new TimerStream("hi", new Duration(minutes: 1))
///         .listen((i) => print(i)); // print "hi" after 1 minute
class TimerStream<T> extends Stream<T> {
  final T value;
  final Duration duration;
  final StreamController<T> controller = new StreamController<T>();

  TimerStream(this.value, this.duration);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    StreamSubscription<T> subscription = controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);

    new Timer(duration, () {
      controller.add(value);
      controller.close();
    });

    return subscription;
  }
}
