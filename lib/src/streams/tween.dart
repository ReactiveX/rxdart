import 'dart:async';

/// Creates a Stream that emits values starting from startValue and
/// incrementing according to the ease type over the duration.
///
/// This function is generally useful for transitions, such as animating
/// items across a screen or muting the volume of a sound gracefully.
///
/// ### Example
///
///     new TweenStream(0.0, 100.0, const Duration(seconds: 1), ease: Ease.IN)
///       .listen((i) => view.setLeft(i)); // Imaginary API as an example
class TweenStream extends Stream<double> {
  final StreamController<double> controller;

  TweenStream(double startValue, double changeInTime, Duration duration,
      int intervalMs, Ease ease)
      : controller = _buildController(
            startValue, changeInTime, duration, intervalMs, ease);

  @override
  StreamSubscription<double> listen(void onData(double event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  static StreamController<double> _buildController(double startValue,
      double changeInTime, Duration duration, int intervalMs, Ease ease) {
    StreamController<double> _controller;
    StreamSubscription<double> subscription;

    _controller = new StreamController<double>(
        sync: true,
        onListen: () {
          Sampler sampler;

          switch (ease) {
            case Ease.LINEAR:
              sampler = linear;
              break;
            case Ease.IN:
              sampler = easeIn;
              break;
            case Ease.OUT:
              sampler = easeOut;
              break;
            case Ease.IN_OUT:
              sampler = easeInOut;
              break;
          }

          final Stream<double> stream = sampleFromValues<double>(sampler,
              startValue, changeInTime, duration.inMilliseconds, intervalMs);

          subscription = stream.listen(_controller.add,
              onError: _controller.addError, onDone: _controller.close);
        },
        onCancel: () => subscription.cancel());

    return _controller;
  }

  static Stream<double> sampleFromValues<T>(Sampler sampler, double startValue,
      double changeInTime, int durationMs, int intervalMs) async* {
    int currentTimeMs = 0;
    double result;

    yield startValue;

    while (currentTimeMs < durationMs) {
      currentTimeMs += intervalMs;

      result = sampler(startValue, changeInTime, currentTimeMs, durationMs);

      yield result;

      await new Future<int>.delayed(new Duration(milliseconds: intervalMs));
    }

    result = startValue + changeInTime;

    yield result;
  }
}

enum Ease { LINEAR, IN, OUT, IN_OUT }

typedef double Sampler(
    double startValue, double changeInTime, int currentTimeMs, int durationMs);

Sampler get linear => (double startValue, double changeInTime,
        int currentTimeMs, int durationMs) =>
    changeInTime * currentTimeMs / durationMs + startValue;

Sampler get easeIn => (double startValue, double changeInTime,
        int currentTimeMs, int durationMs) {
      final double t = currentTimeMs / durationMs;

      return changeInTime * t * t + startValue;
    };

Sampler get easeOut => (double startValue, double changeInTime,
        int currentTimeMs, int durationMs) {
      final double t = currentTimeMs / durationMs;

      return -changeInTime * t * (t - 2) + startValue;
    };

Sampler get easeInOut => (double startValue, double changeInTime,
        int currentTimeMs, int durationMs) {
      double t = currentTimeMs / (durationMs / 2);

      if (t < 1.0) return changeInTime / 2 * t * t + startValue;

      t--;

      return -changeInTime / 2 * (t * (t - 2) - 1) + startValue;
    };
