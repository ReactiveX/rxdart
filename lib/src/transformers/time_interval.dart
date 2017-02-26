import 'dart:async';

class TimeIntervalStreamTransformer<T, S extends TimeInterval<T>>
    implements StreamTransformer<T, S> {
  final StreamTransformer<T, S> transformer;

  TimeIntervalStreamTransformer() : transformer = _buildTransformer();

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S>
      _buildTransformer<T, S extends TimeInterval<T>>() {
    return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<TimeInterval<T>> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            Stopwatch stopwatch = new Stopwatch()..start();
            int ems;

            subscription = input.listen(
                (T value) {
                  ems = stopwatch.elapsedMicroseconds;

                  stopwatch.stop();

                  controller.add(new TimeInterval<T>(value, ems));

                  stopwatch = new Stopwatch()..start();
                },
                onError: controller.addError,
                onDone: () {
                  stopwatch.stop();
                  controller.close();
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

class TimeInterval<T> {
  final int interval;
  final T value;

  TimeInterval(this.value, this.interval);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TimeInterval &&
        this.interval == other.interval &&
        this.value == other.value;
  }

  @override
  int get hashCode {
    return interval.hashCode ^ value.hashCode;
  }

  @override
  String toString() {
    return 'TimeInterval{interval: $interval, value: $value}';
  }
}
