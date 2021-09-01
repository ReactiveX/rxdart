import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _DelayWhenStreamSink<T> extends ForwardingSink<T, T> {
  final Stream<void> Function(T) itemDelaySelector;
  final Stream<void>? listenDelay;

  final subscriptions = <StreamSubscription<void>>[];
  StreamSubscription<void>? subscription;
  var closed = false;

  _DelayWhenStreamSink(this.itemDelaySelector, this.listenDelay);

  @override
  void onData(T data) {
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
  void onError(Object error, StackTrace st) => sink.addError(error, st);

  @override
  void onDone() {
    closed = true;
    if (subscriptions.isEmpty) {
      sink.close();
    }
  }

  @override
  FutureOr<void> onCancel() {
    final future = subscription?.cancel();
    subscription = null;

    if (subscriptions.isNotEmpty) {
      final futures = [
        ...subscriptions.map((s) => s.cancel()),
        if (future != null) future,
      ];
      subscriptions.clear();
      return Future.wait(futures);
    } else {
      return future;
    }
  }

  @override
  FutureOr<void> onListen() {
    if (listenDelay == null) {
      return null;
    }

    final completer = Completer<void>.sync();
    subscription = listenDelay!.take(1).listen(
      null,
      onError: (Object e, StackTrace s) {
        subscription?.cancel();
        subscription = null;
        completer.completeError(e, s);
      },
      onDone: () {
        subscription?.cancel();
        subscription = null;
        completer.complete(null);
      },
    );
    return completer.future;
  }

  @override
  void onPause() {
    subscription?.pause();
    subscriptions.forEach((s) => s.pause());
  }

  @override
  void onResume() {
    subscription?.resume();
    subscriptions.forEach((s) => s.resume());
  }
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

  /// When [listenDelay] emits its first data or done event, the source Stream is listen to.
  final Stream<void>? listenDelay;

  /// Constructs a [StreamTransformer] which delays the emission of items
  /// from the source [Stream] by a given time span determined by the emissions of another [Stream].
  DelayWhenStreamTransformer(this.itemDelaySelector, {this.listenDelay});

  @override
  Stream<T> bind(Stream<T> stream) => forwardStream(
      stream, () => _DelayWhenStreamSink(itemDelaySelector, listenDelay));
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
  Stream<T> delayWhen(
    Stream<void> Function(T) itemDelaySelector, {
    Stream<void>? listenDelay,
  }) =>
      transform(DelayWhenStreamTransformer(itemDelaySelector,
          listenDelay: listenDelay));
}
