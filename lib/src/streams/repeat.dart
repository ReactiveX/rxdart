import 'dart:async';

/// Creates a [Stream] that will recreate and re-listen to the source
/// Stream the specified number of times until the [Stream] terminates
/// successfully.
///
/// If [_count] is not specified, it repeats indefinitely.
///
/// ### Example
///
///     new RepeatStream((int repeatCount) =>
///       Observable.just('repeat index: $repeatCount'), 3)
///         .listen((i) => print(i)); // Prints 'repeat index: 0, repeat index: 1, repeat index: 2'
class RepeatStream<T> extends Stream<T> {
  final Stream<T> Function(int) _streamFactory;
  final int _count;
  int _repeatStep = 0;
  StreamController<T> _controller;
  StreamSubscription<T> _subscription;

  /// Constructs a [Stream] that will recreate and re-listen to the source
  /// [Stream] (created with the provided factory method).
  /// The count parameter specifies number of times the repeat will take place,
  /// until this [Stream] terminates successfully.
  /// If the count parameter is not specified, then this [Stream] will repeat
  /// indefinitely.
  RepeatStream(this._streamFactory, [this._count]);

  @override
  StreamSubscription<T> listen(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    _controller ??= StreamController<T>(
        sync: true,
        onListen: _maybeRepeatNext,
        onPause: ([Future<dynamic> resumeSignal]) =>
            _subscription.pause(resumeSignal),
        onResume: () => _subscription.resume(),
        onCancel: () => _subscription?.cancel());

    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void _repeatNext() {
    void onDone() {
      _subscription?.cancel();

      _maybeRepeatNext();
    }

    try {
      _subscription = _streamFactory(_repeatStep++).listen(_controller.add,
          onError: _controller.addError, onDone: onDone, cancelOnError: false);
    } catch (e, s) {
      _controller.addError(e, s);
    }
  }

  void _maybeRepeatNext() {
    if (_repeatStep == _count) {
      _controller.close();
    } else {
      _repeatNext();
    }
  }
}
