import 'dart:async';

/// A StreamTransformer that emits only the first item emitted by the source
/// Stream during sequential time windows of a specified duration.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new ThrottleStreamTransformer(new Duration(seconds: 1)))
///       .listen(print); // prints 1
class ThrottleStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  ThrottleStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) {
    if (duration == null) {
      throw new ArgumentError('duration cannot be null');
    }

    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      Timer _timer;
      bool _closeAfterNextEvent = false;

      bool _resetTimer() {
        if (_timer != null && _timer.isActive) return false;

        try {
          _timer = new Timer(duration, () {
            if (_closeAfterNextEvent && !controller.isClosed)
              controller.close();
          });
        } catch (e, s) {
          controller.addError(e, s);
        }

        return true;
      }

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input
                .where((_) => _resetTimer())
                .listen(controller.add, onError: controller.addError,
                    onDone: () {
              _closeAfterNextEvent = true;
            }, cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
