import 'dart:async';

/// Records the time interval between consecutive values in an observable
/// sequence.
///
/// ### Example
///
///     new Stream.fromIterable([1])
///       .transform(new IntervalStreamTransformer(new Duration(seconds: 1)))
///       .transform(new TimeIntervalStreamTransformer())
///       .listen(print); // prints TimeInterval{interval: 0:00:01, value: 1}
class TimeIntervalStreamTransformer<T>
    extends StreamTransformerBase<T, TimeInterval<T>> {
  final StreamTransformer<T, TimeInterval<T>> transformer;

  TimeIntervalStreamTransformer() : transformer = _buildTransformer();

  @override
  Stream<TimeInterval<T>> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, TimeInterval<T>> _buildTransformer<T>() {
    return new StreamTransformer<T, TimeInterval<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<TimeInterval<T>> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<TimeInterval<T>>(
          sync: true,
          onListen: () {
            Stopwatch stopwatch = new Stopwatch()..start();
            int ems;

            subscription = input.listen(
                (T value) {
                  ems = stopwatch.elapsedMicroseconds;

                  stopwatch.stop();

                  try {
                    controller.add(new TimeInterval<T>(
                        value, new Duration(microseconds: ems)));
                  } catch (e, s) {
                    controller.addError(e, s);
                  }

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
  final Duration interval;
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
