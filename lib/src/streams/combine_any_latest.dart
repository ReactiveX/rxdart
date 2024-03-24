import 'dart:async';

import 'package:rxdart/src/utils/collection_extensions.dart';
import 'package:rxdart/src/utils/subscription.dart';

/// Merges a list of streams into a single stream.
/// The merged stream emits an event whenever any of the source streams emit an event.
/// The emitted value is the result of applying a combiner function to the
/// latest values from each of the source streams.

class CombineAnyLatestStream<T, R> extends StreamView<R> {
  /// Constructs a [Stream] that observes an [Iterable] of [Stream]
  /// and builds a [List] containing all latest events emitted by the provided [Iterable] of [Stream].
  /// The [combiner] maps this [List] into a new event of type [R]
  CombineAnyLatestStream(
    List<Stream<T>> streams,
    R Function(List<T?>) combiner,
  ) : super(_buildController(streams, combiner).stream);

  static StreamController<R> _buildController<T, R>(
    Iterable<Stream<T>> streams,
    R Function(List<T?> values) combiner,
  ) {
    /// The completed variable keeps track of how many source streamse have completed.
    int completed = 0;

    /// The subscriptions hold a list of subscriptions to the source streams.
    late List<StreamSubscription<T>> subscriptions;

    /// The values hold the latest values from each of the source streams.
    List<T?>? values;

    final controller = StreamController<R>(sync: true);

    controller.onListen = () {
      void onDone() {
        if (++completed == streams.length) {
          controller.close();
        }
      }

      subscriptions = streams.mapIndexed((index, stream) {
        return stream.listen((T event) {
          final R combined;

          if (values == null) return;

          values![index] = event;

          try {
            combined = combiner(List<T?>.unmodifiable(values!));
          } catch (e, s) {
            controller.addError(e, s);
            return;
          }

          controller.add(combined);
        }, onError: controller.addError, onDone: onDone);
      }).toList(growable: false);

      if (subscriptions.isEmpty) {
        controller.close();
      } else {
        values = List<T?>.filled(subscriptions.length, null);
      }
    };

    controller.onPause = () => subscriptions.pauseAll();
    controller.onResume = () => subscriptions.resumeAll();
    controller.onCancel = () {
      values = null;
      return subscriptions.cancelAll();
    };

    return controller;
  }
}
