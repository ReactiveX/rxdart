import 'dart:async';

/// Emits incremental numbers periodically in time
///
/// [Interactive marble diagram](http://rxmarbles.com/#interval)
///
/// ### Example
///
///     IntervalStream(Duration(minutes: 1))
///         .listen((i) => print(i)); // print 1 after 1 minute,
///                                   // 2 after 2 minutes, 3 after 3 minutes, ...
class IntervalStream extends Stream<int> {
  final StreamController<int> _controller;

  /// Constructs a [Stream] which emits incremented integers
  /// after the specified [Duration].
  IntervalStream(Duration duration) : _controller = _buildController(duration);

  @override
  StreamSubscription<int> listen(void Function(int event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  static StreamController<int> _buildController<int>(Duration duration) {
    if (duration == null) {
      throw ArgumentError('duration cannot be null');
    }

    StreamSubscription<int> subscription;
    StreamController<int> controller;

    controller = StreamController<int>(
      sync: true,
      onListen: () {
        subscription = Stream<int>.periodic(duration, (i) => i as int).listen(
          controller.add,
          onError: controller.addError,
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );
      },
      onPause: ([Future<dynamic> resumeSignal]) =>
          subscription.pause(resumeSignal),
      onResume: () => subscription.resume(),
      onCancel: () => subscription.cancel(),
    );
    return controller;
  }
}
