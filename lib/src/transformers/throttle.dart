import 'dart:async';

class ThrottleStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  ThrottleStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      Timer _timer;
      bool _closeAfterNextEvent = false;

      bool _resetTimer() {
        if (_timer != null && _timer.isActive) return false;

        _timer = new Timer(duration, () {
          if (_closeAfterNextEvent && !controller.isClosed) controller.close();
        });

        return true;
      }

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  if (_resetTimer()) controller.add(value);
                },
                onError: controller.addError,
                onDone: () {
                  _closeAfterNextEvent = true;
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
