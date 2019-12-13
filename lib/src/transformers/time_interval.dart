import 'dart:async';

/// Records the time interval between consecutive values in an stream
/// sequence.
///
/// ### Example
///
///     Stream.fromIterable([1])
///       .transform(IntervalStreamTransformer(Duration(seconds: 1)))
///       .transform(TimeIntervalStreamTransformer())
///       .listen(print); // prints TimeInterval{interval: 0:00:01, value: 1}
class TimeIntervalStreamTransformer<T>
    extends StreamTransformerBase<T, TimeInterval<T>> {
  final StreamTransformer<T, TimeInterval<T>> _transformer;

  /// Constructs a [StreamTransformer] which emits events from the
  /// source [Stream] as snapshots in the form of [TimeInterval].
  TimeIntervalStreamTransformer() : _transformer = _buildTransformer();

  @override
  Stream<TimeInterval<T>> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, TimeInterval<T>> _buildTransformer<T>() {
    return StreamTransformer<T, TimeInterval<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<TimeInterval<T>> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<TimeInterval<T>>(
          sync: true,
          onListen: () {
            var stopwatch = Stopwatch()..start();
            int ems;

            subscription = input.listen(
                (T value) {
                  ems = stopwatch.elapsedMicroseconds;

                  stopwatch.stop();

                  try {
                    controller.add(
                        TimeInterval<T>(value, Duration(microseconds: ems)));
                  } catch (e, s) {
                    controller.addError(e, s);
                  }

                  stopwatch = Stopwatch()..start();
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

/// A class that represents a snapshot of the current value emitted by a
/// [Stream], at a specified interval.
class TimeInterval<T> {
  /// The interval at which this snapshot was taken
  final Duration interval;

  /// The value at the moment of [interval]
  final T value;

  /// Constructs a snapshot of a [Stream], containing the [Stream]'s event
  /// at the specified [interval] as [value].
  TimeInterval(this.value, this.interval);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TimeInterval &&
        interval == other.interval &&
        value == other.value;
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

/// Extends the Stream class with the ability to record the time interval
/// between consecutive values in an stream
extension TimeIntervalExtension<T> on Stream<T> {
  /// Records the time interval between consecutive values in a Stream sequence.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///       .interval(Duration(seconds: 1))
  ///       .timeInterval()
  ///       .listen(print); // prints TimeInterval{interval: 0:00:01, value: 1}
  Stream<TimeInterval<T>> timeInterval() =>
      transform(TimeIntervalStreamTransformer<T>());
}
