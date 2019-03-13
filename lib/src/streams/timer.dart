import 'dart:async';

/// Emits the given value after a specified amount of time.
///
/// ### Example
///
///     new TimerStream("hi", new Duration(minutes: 1))
///         .listen((i) => print(i)); // print "hi" after 1 minute
class TimerStream<T> extends Stream<T> {
  final T _value;
  final Sink<T> _sink;
  final Stream<T> _stream;

  factory TimerStream(T value, Duration duration) {
    final sink = new StreamController<T>();

    return TimerStream._(
        value,
        sink,
        Stream.eventTransformed(sink.stream,
            (EventSink<T> sink) => _DelayedSink<T>(sink, duration)));
  }

  TimerStream._(this._value, this._sink, this._stream);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    final subscription = _stream.listen(onData, onError: onError, onDone: () {
      _sink.close();

      if (onDone != null) onDone();
    }, cancelOnError: cancelOnError);

    _sink.add(_value);

    return subscription;
  }
}

class _DelayedSink<T> implements EventSink<T> {
  final EventSink<T> _outputSink;
  final Duration _delay;

  _DelayedSink(this._outputSink, this._delay);

  void add(T data) {
    final dispatch = (T data) {
      _outputSink.add(data);
      close();
    };

    if (_delay == null) return dispatch(data);

    Future.delayed(_delay, () => data).then(dispatch);
  }

  void addError(e, [st]) => _outputSink.addError(e, st);

  void close() => _outputSink.close();
}
