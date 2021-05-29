import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _DelayWhenStreamSink<T> implements ForwardingSink<T, T> {
  final Stream<void> Function(T) itemDelaySelector;
  final subscriptions = <StreamSubscription<void>>[];
  var closed = false;

  _DelayWhenStreamSink(this.itemDelaySelector);

  @override
  void add(EventSink<T> sink, T data) {
    final subscription =
        itemDelaySelector(data).take(1).listen(null, onError: sink.addError);

    subscription.onDone(() {
      subscriptions.remove(subscription);

      sink.add(data);
      if (subscriptions.isEmpty && closed) {
        sink.close();
      }
    });

    subscriptions.add(subscription);
  }

  @override
  void addError(EventSink<T> sink, Object error, StackTrace st) =>
      sink.addError(error, st);

  @override
  void close(EventSink<T> sink) {
    closed = true;
    if (subscriptions.isEmpty) {
      sink.close();
    }
  }

  @override
  FutureOr<void> onCancel(EventSink<T> sink) {
    if (subscriptions.isNotEmpty) {
      return Future.wait(subscriptions.map((s) => s.cancel()))
          .whenComplete(() => subscriptions.clear());
    }
  }

  @override
  void onListen(EventSink<T> sink) {}

  @override
  void onPause(EventSink<T> sink) => subscriptions.forEach((s) => s.pause());

  @override
  void onResume(EventSink<T> sink) => subscriptions.forEach((s) => s.resume());
}

/// Delays the emission of items from the source [Stream] by a given time span
/// determined by the emissions of another [Stream].
///
/// [Interactive marble diagram](http://rxmarbles.com/#delayWhen)
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3])
///       .delayWhen((i) => Rx.timer(null, Duration(seconds: i)))
///       .listen(print); // [after 1 second] prints 1 [after 1 second] prints 2 [after 1 second] prints 3
class DelayWhenStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// A function used to determine delay time span for each data event.
  final Stream<void> Function(T) itemDelaySelector;

  /// Constructs a [StreamTransformer] which delays the emission of items
  /// from the source [Stream] by a given time span determined by the emissions of another [Stream].
  DelayWhenStreamTransformer(this.itemDelaySelector);

  @override
  Stream<T> bind(Stream<T> stream) =>
      forwardStream(stream, _DelayWhenStreamSink(itemDelaySelector));
}

/// Extends the Stream class with the ability to delay events being emitted.
extension DelayWhenExtension<T> on Stream<T> {
  /// Delays the emission of items from the source [Stream] by a given time span
  /// determined by the emissions of another [Stream].
  ///
  /// When the source emits a data element, the `itemDelaySelector` function is called
  /// with the data element as argument, and return a "duration" Stream.
  /// The source element is emitted on the output Stream only when the "duration" Stream
  /// emits a data or done event.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#delayWhen)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .delayWhen((i) => Rx.timer(null, Duration(seconds: i)))
  ///       .listen(print); // [after 1 second] prints 1 [after 1 second] prints 2 [after 1 second] prints 3
  Stream<T> delayWhen(Stream<void> Function(T) itemDelaySelector) =>
      transform(DelayWhenStreamTransformer(itemDelaySelector));
}
