import 'package:rxdart/src/observable.dart';

enum Ease { LINEAR, IN, OUT, IN_OUT }

typedef double Sampler(
    double startValue, double changeInTime, int currentTimeMs, int durationMs);

class TweenObservable extends Observable<double> {
  TweenObservable(double startValue, double changeInTime, Duration duration,
      int intervalMs, Ease ease, bool asBroadcastStream)
      : super(buildStream(startValue, changeInTime, duration, intervalMs, ease,
            asBroadcastStream));

  static Stream<double> buildStream(double startValue, double changeInTime,
      Duration duration, int intervalMs, Ease ease, bool asBroadcastStream) {
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

          final Stream<double> stream = sampleFromValues(sampler, startValue,
              changeInTime, duration.inMilliseconds, intervalMs);

          subscription = stream.listen(_controller.add,
              onError: _controller.addError, onDone: _controller.close);
        },
        onCancel: () => subscription.cancel());

    final Observable<double> observable = new Observable<double>(
        asBroadcastStream
            ? _controller.stream.asBroadcastStream()
            : _controller.stream);

    return observable.interval(new Duration(milliseconds: intervalMs));
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
    }

    result = startValue + changeInTime;

    yield result;
  }
}

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
