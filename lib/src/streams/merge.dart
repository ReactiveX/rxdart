import 'dart:async';

import 'package:rxdart/src/utils/subscription.dart';

/// Flattens the items emitted by the given streams into a single Stream
/// sequence.
///
/// If the provided streams is empty, the resulting sequence completes immediately
/// without emitting any items.
///
/// [Interactive marble diagram](http://rxmarbles.com/#merge)
///
/// ### Example
///
///     MergeStream([
///       TimerStream(1, Duration(days: 10)),
///       Stream.fromIterable([2])
///     ])
///     .listen(print); // prints 2, 1
class MergeStream<T> extends Stream<T> {
  final StreamController<T> _controller;

  /// Constructs a [Stream] which flattens all events in [streams] and emits
  /// them in a single sequence.
  MergeStream(Iterable<Stream<T>> streams)
      : _controller = _buildController(streams);

  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      _controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  static StreamController<T> _buildController<T>(Iterable<Stream<T>> streams) {
    if (streams.isEmpty) {
      return StreamController<T>()..close();
    }

    final len = streams.length;
    late List<StreamSubscription<T>> subscriptions;
    late StreamController<T> controller;

    controller = StreamController<T>(
        sync: true,
        onListen: () {
          var completed = 0;

          void onDone() {
            completed++;

            if (completed == len) controller.close();
          }

          subscriptions = streams
              .map((s) => s.listen(controller.add,
                  onError: controller.addError, onDone: onDone))
              .toList(growable: false);
        },
        onPause: () => subscriptions.pauseAll(),
        onResume: () => subscriptions.resumeAll(),
        onCancel: () => subscriptions.cancelAll());

    return controller;
  }
}

/// Extends the Stream class with the ability to merge one stream with another.
extension MergeExtension<T> on Stream<T> {
  /// Combines the items emitted by multiple streams into a single stream of
  /// items. The items are emitted in the order they are emitted by their
  /// sources.
  ///
  /// ### Example
  ///
  ///     TimerStream(1, Duration(seconds: 10))
  ///         .mergeWith([Stream.fromIterable([2])])
  ///         .listen(print); // prints 2, 1
  Stream<T> mergeWith(Iterable<Stream<T>> streams) {
    final stream = MergeStream<T>([this, ...streams]);

    return isBroadcast
        ? stream.asBroadcastStream(onCancel: (s) => s.cancel())
        : stream;
  }
}
