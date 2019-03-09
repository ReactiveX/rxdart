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

  Stream<T> _stream;

  TimerStream(this.value, this.duration) {
    assert(duration != null, 'duration cannot be null');
  }

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    _stream ??= forwardingStream();

    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Stream<T> forwardingStream() async* {
    yield await Future<void>.delayed(duration).then((_) => value);
  }
}
