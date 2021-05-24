import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/rx.dart';
import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

import 'ignore_elements.dart';

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

class _DelayListenStreamSink<T> implements ForwardingSink<T, T> {
  final Stream<void> subscriptionDelay;

  _DelayListenStreamSink(this.subscriptionDelay);
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
  final Stream<void> Function(T) itemDelaySelector;
  final Stream<void>? subscriptionDelay;

  /// Constructs a [StreamTransformer] which delays the emission of items
  /// from the source [Stream] by a given time span determined by the emissions of another [Stream].
  DelayWhenStreamTransformer(this.itemDelaySelector, this.subscriptionDelay);

  @override
  Stream<T> bind(Stream<T> stream) {
    if (subscriptionDelay != null) {
      stream = forwardStream(stream, _DelayListenStreamSink(subscriptionDelay));
    }
    print('>>' +stream.toString());
    print('>>' +stream.isBroadcast.toString());
    return forwardStream(stream, _DelayWhenStreamSink(itemDelaySelector));
  }
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
  /// Optionally, `delayWhen` takes a second argument `listenDelay`. When `listenDelay`
  /// emits its first data or done event, the source Stream is listen to.
  /// If `listenDelay` is not provided, `delayWhen` will listen to the source Stream
  /// as soon as the output Stream is listen.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#delayWhen)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .delayWhen((i) => Rx.timer(null, Duration(seconds: i)))
  ///       .listen(print); // [after 1 second] prints 1 [after 1 second] prints 2 [after 1 second] prints 3
  Stream<T> delayWhen(Stream<void> Function(T) itemDelaySelector,
          [Stream<void>? listenDelay]) =>
      transform(DelayWhenStreamTransformer(itemDelaySelector, listenDelay));
}

void main() {
  var delayWhen = PublishSubject<int>().delayWhen((p0) => Stream.value(p0), Rx.timer(0, Duration.zero));
  print('<< $delayWhen');
  delayWhen.listen(print);
  delayWhen.listen(print);
  print(delayWhen.isBroadcast);
}