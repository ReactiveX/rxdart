import 'dart:async';

/// Creates a [Stream] that will recreate and re-listen to the source
/// Stream the specified number of times until the [Stream] terminates
/// successfully.
///
/// If [count] is not specified, it repeats indefinitely.
///
/// ### Example
///
///     new RepeatStream((int repeatCount) =>
///       Observable.just('repeat index: $repeatCount'), 3)
///         .listen((i) => print(i)); // Prints 'repeat index: 0, repeat index: 1, repeat index: 2'
class RepeatStream<T> extends Stream<T> {
  final Stream<T> Function(int) streamFactory;
  final int count;
  int repeatStep = 0;
  StreamController<T> controller;
  StreamSubscription<T> subscription;
  bool _isUsed = false;

  RepeatStream(this.streamFactory, [this.count]);

  @override
  StreamSubscription<T> listen(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    if (_isUsed) throw StateError("Stream has already been listened to.");
    _isUsed = true;

    controller = StreamController<T>(
        sync: true,
        onListen: maybeRepeatNext,
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription?.cancel());

    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void repeatNext() {
    void onDone() {
      subscription?.cancel();

      maybeRepeatNext();
    }

    try {
      subscription = streamFactory(repeatStep++).listen(controller.add,
          onError: controller.addError, onDone: onDone, cancelOnError: false);
    } catch (e, s) {
      controller.addError(e, s);
    }
  }

  void maybeRepeatNext() {
    if (repeatStep == count) {
      controller.close();
    } else {
      repeatNext();
    }
  }
}
