import 'dart:async';

/// Wraps each item emitted by the source Observable in a [Timestamped] object
/// that includes the emitted item and the time when the item was emitted.
///
/// Example
///
///     new Stream.fromIterable([1])
///        .transform(new TimestampStreamTransformer())
///        .listen((i) => print(i)); // prints 'TimeStamp{timestamp: XXX, value: 1}';
class TimestampStreamTransformer<T>
    extends StreamTransformerBase<T, Timestamped<T>> {
  final StreamTransformer<T, Timestamped<T>> transformer;

  TimestampStreamTransformer() : transformer = _buildTransformer();

  @override
  Stream<Timestamped<T>> bind(Stream<T> stream) => transformer.bind(stream);

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

class Timestamped<T> {
  final T value;
  final DateTime timestamp;

  Timestamped(this.timestamp, this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Timestamped &&
        this.timestamp == other.timestamp &&
        this.value == other.value;
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
