import 'dart:async';

/// Wraps each item emitted by the source Stream in a [Timestamped] object
/// that includes the emitted item and the time when the item was emitted.
///
/// Example
///
///     Stream.fromIterable([1])
///        .transform(TimestampStreamTransformer())
///        .listen((i) => print(i)); // prints 'TimeStamp{timestamp: XXX, value: 1}';
class TimestampStreamTransformer<T>
    extends StreamTransformerBase<T, Timestamped<T>> {
  final StreamTransformer<T, Timestamped<T>> _transformer;

  /// Constructs a [StreamTransformer] which emits events from the
  /// source [Stream] as snapshots in the form of [Timestamped].
  TimestampStreamTransformer() : _transformer = _buildTransformer();

  @override
  Stream<Timestamped<T>> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, Timestamped<T>> _buildTransformer<T>() {
    return StreamTransformer<T, Timestamped<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Timestamped<T>> controller;
      StreamSubscription<Timestamped<T>> subscription;

      controller = StreamController<Timestamped<T>>(
          sync: true,
          onListen: () {
            subscription = input
                .map((T value) => Timestamped<T>(DateTime.now(), value))
                .listen(controller.add,
                    onError: controller.addError,
                    onDone: controller.close,
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
/// [Stream], at a specified timestamp.
class Timestamped<T> {
  /// The value at the moment of the [timestamp]
  final T value;

  /// The time at which this snapshot was taken
  final DateTime timestamp;

  /// Constructs a snapshot of a [Stream], containing the [Stream]'s event
  /// at the specified [timestamp] as [value].
  Timestamped(this.timestamp, this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Timestamped &&
        timestamp == other.timestamp &&
        value == other.value;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^ value.hashCode;
  }

  @override
  String toString() {
    return 'TimeStamp{timestamp: $timestamp, value: $value}';
  }
}

/// Extends the Stream class with the ability to wrap each item emitted by the
/// source Stream in a [Timestamped] object that includes the emitted item and
/// the time when the item was emitted.
extension TimeStampExtension<T> on Stream<T> {
  /// Wraps each item emitted by the source Stream in a [Timestamped] object
  /// that includes the emitted item and the time when the item was emitted.
  ///
  /// Example
  ///
  ///     Stream.fromIterable([1])
  ///        .timestamp()
  ///        .listen((i) => print(i)); // prints 'TimeStamp{timestamp: XXX, value: 1}';
  Stream<Timestamped<T>> timestamp() =>
      transform(TimestampStreamTransformer<T>());
}
