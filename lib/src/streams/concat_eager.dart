import 'dart:async';

import 'package:rxdart/src/streams/concat.dart';
import 'package:rxdart/src/utils/collection_extensions.dart';
import 'package:rxdart/src/utils/subscription.dart';

/// Concatenates all of the specified stream sequences, as long as the
/// previous stream sequence terminated successfully.
///
/// In the case of concatEager, rather than subscribing to one stream after
/// the next, all streams are immediately subscribed to. The events are then
/// captured and emitted at the correct time, after the previous stream has
/// finished emitting items.
///
/// If the provided streams is empty, the resulting sequence completes immediately
/// without emitting any items.
///
/// [Interactive marble diagram](http://rxmarbles.com/#concat)
///
/// ### Example
///
///     ConcatEagerStream([
///       Stream.fromIterable([1]),
///       TimerStream(2, Duration(days: 1)),
///       Stream.fromIterable([3])
///     ])
///     .listen(print); // prints 1, 2, 3
class ConcatEagerStream<T> extends StreamView<T> {
  /// Constructs a [Stream] which emits all events from [streams].
  /// Unlike [ConcatStream], all [Stream]s inside [streams] are
  /// immediately subscribed to and events captured at the correct time,
  /// but emitted only after the previous [Stream] in [streams] is
  /// successfully closed.
  ConcatEagerStream(Iterable<Stream<T>> streams)
      : super(_buildController(streams).stream);

  static StreamController<T> _buildController<T>(
      Iterable<Stream<T>> streamsIterable) {
    final controller = StreamController<T>(sync: true);

    List<StreamSubscription<T>>? subscriptions;
    List<Completer>? completeEvents;
    StreamSubscription<T>? activeSubscription;

    controller.onListen = () {
      final streams = streamsIterable.evaluated;
      if (streams.isEmpty) {
        controller.close();
        return;
      }

      final length = streams.length;
      var completed = 0;

      void Function() onDone(int index) {
        return () {
          if (index < length - 1) {
            completeEvents![index].complete();
          }

          if (++completed == length) {
            controller.close();
          } else {
            activeSubscription = subscriptions?[index + 1];
          }
        };
      }

      StreamSubscription<T> createSubscription(int index, Stream<T> stream) {
        final subscription = stream.listen(controller.add,
            onError: controller.addError, onDone: onDone(index));

        // pause all subscriptions, except the first, initially
        if (index > 0) {
          subscription.pause(completeEvents![index - 1].future);
        }

        return subscription;
      }

      completeEvents = List.generate(length - 1, (_) => Completer<void>());
      subscriptions =
          streams.mapIndexed(createSubscription).toList(growable: false);

      // initially, the very first subscription is the active one
      activeSubscription = subscriptions?.first;
    };
    controller.onPause = () => activeSubscription?.pause();
    controller.onResume = () => activeSubscription?.resume();
    controller.onCancel = () {
      final future = subscriptions?.cancelAll();
      activeSubscription = null;
      completeEvents = null;
      subscriptions = null;
      return future;
    };

    return controller;
  }
}
