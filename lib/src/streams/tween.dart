import 'dart:async';

import 'package:rxdart/src/transformers/interval.dart';

enum Ease { LINEAR, IN, OUT, IN_OUT }

typedef double Sampler(
    double startValue, double changeInTime, int currentTimeMs, int durationMs);

class TweenStream extends Stream<double> {
  final double startValue;
  final double changeInTime;
  final Duration duration;
  final int intervalMs;
  final Ease ease;

  TweenStream(this.startValue, this.changeInTime, this.duration,
      this.intervalMs, this.ease);

  @override
  StreamSubscription<double> listen(void onData(double event),
      {Function onError, void onDone(), bool cancelOnError}) {
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

    return _controller.stream
        .transform(new IntervalStreamTransformer<double>(
            new Duration(milliseconds: intervalMs)))
        .listen(onData,
            onError: onError, onDone: onDone, cancelOnError: cancelOnError);
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
