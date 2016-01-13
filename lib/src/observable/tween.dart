library rx.observable.tween;

import 'package:rxdart/src/observable/stream.dart';

StreamObservable<double> tweenLinear(double startValue, double changeInTime, Duration duration, {int intervalMs: 20}) {
  final StreamController<double> controller = new StreamController<double>();
  final Duration intervalDuration = new Duration(milliseconds: intervalMs);
  int currentTimeMs = 0;

  controller.add(startValue);

  new Timer.periodic(intervalDuration, (Timer timer) {
    currentTimeMs += intervalMs;

    controller.add(changeInTime * currentTimeMs / duration.inMilliseconds + startValue);

    if (currentTimeMs >= duration.inMilliseconds) {
      timer.cancel();

      controller.close();
    }
  });

  return new StreamObservable<double>()..setStream(controller.stream);
}

StreamObservable<double> tweenQuadraticEaseIn(double startValue, double changeInTime, Duration duration, {int intervalMs: 20}) {
  final StreamController<double> controller = new StreamController<double>();
  const int interval = 20;
  const Duration intervalDuration = const Duration(milliseconds: interval);
  int currentTimeMs = 0;

  controller.add(startValue);

  new Timer.periodic(intervalDuration, (Timer timer) {
    currentTimeMs += interval;

    final double t = currentTimeMs / duration.inMilliseconds;

    controller.add(changeInTime * t * t + startValue);

    if (currentTimeMs >= duration.inMilliseconds) {
      timer.cancel();

      controller.close();
    }
  });

  return new StreamObservable<double>()..setStream(controller.stream);
}

StreamObservable<double> tweenQuadraticEaseOut(double startValue, double changeInTime, Duration duration, {int intervalMs: 20}) {
  final StreamController<double> controller = new StreamController<double>();
  const int interval = 20;
  const Duration intervalDuration = const Duration(milliseconds: interval);
  int currentTimeMs = 0;

  controller.add(startValue);

  new Timer.periodic(intervalDuration, (Timer timer) {
    currentTimeMs += interval;

    final double t = currentTimeMs / duration.inMilliseconds;

    controller.add(-changeInTime * t * (t - 2) + startValue);

    if (currentTimeMs >= duration.inMilliseconds) {
      timer.cancel();

      controller.close();
    }
  });

  return new StreamObservable<double>()..setStream(controller.stream);
}

StreamObservable<double> tweenQuadraticEaseInOut(double startValue, double changeInTime, Duration duration, {int intervalMs: 20}) {
  final StreamController<double> controller = new StreamController<double>();
  const int interval = 20;
  const Duration intervalDuration = const Duration(milliseconds: interval);
  int currentTimeMs = 0;

  controller.add(startValue);

  new Timer.periodic(intervalDuration, (Timer timer) {
    currentTimeMs += interval;

    double t = currentTimeMs / (duration.inMilliseconds / 2);

    if (t < 1.0) controller.add(changeInTime / 2 * t * t + startValue);
    else {
      t--;

      controller.add(-changeInTime / 2 * (t * (t - 2) - 1) + startValue);
    }

    if (currentTimeMs >= duration.inMilliseconds) {
      timer.cancel();

      controller.close();
    }
  });

  return new StreamObservable<double>()..setStream(controller.stream);
}