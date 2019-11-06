import 'dart:async';

import 'package:rxdart/src/observables/observable.dart' show Observable;

/// The GroupBy operator divides an [Observable] that emits items into
/// an [Observable] that emits [GroupByObservable],
/// each one of which emits some subset of the items
/// from the original source [Observable].
///
/// [GroupByObservable] acts like a regular [Observable], yet
/// adding a 'key' property, which receives its [Type] and value from
/// the [_grouper] Function.
///
/// All items with the same key are emitted by the same [GroupByObservable].

class GroupByStreamTransformer<T, S>
    extends StreamTransformerBase<T, GroupByObservable<T, S>> {
  final StreamTransformer<T, GroupByObservable<T, S>> _transformer;

  /// Constructs a [StreamTransformer] which groups events from the source
  /// [Stream] and emits them as [GroupByObservable].
  GroupByStreamTransformer(S grouper(T event))
      : _transformer = _buildTransformer<T, S>(grouper);

  @override
  Stream<GroupByObservable<T, S>> bind(Stream<T> stream) =>
      _transformer.bind(stream);

  static StreamTransformer<T, GroupByObservable<T, S>> _buildTransformer<T, S>(
      S grouper(T event)) {
    return StreamTransformer<T, GroupByObservable<T, S>>(
        (Stream<T> input, bool cancelOnError) {
      final mapper = <S, StreamController<T>>{};
      StreamController<GroupByObservable<T, S>> controller;
      StreamSubscription<T> subscription;

      final controllerBuilder = (S forKey) => () {
            final groupedController = StreamController<T>();

            controller
                .add(GroupByObservable<T, S>(forKey, groupedController.stream));

            return groupedController;
          };

      controller = StreamController<GroupByObservable<T, S>>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  try {
                    final key = grouper(value);
                    // ignore: close_sinks
                    final groupedController =
                        mapper.putIfAbsent(key, controllerBuilder(key));

                    groupedController.add(value);
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                },
                onError: controller.addError,
                onDone: () {
                  mapper.values.forEach((controller) => controller.close());
                  mapper.clear();

                  controller.close();
                });
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}

/// The [Observable] used by [GroupByStreamTransformer], it contains events
/// that are groupd by a key value.
class GroupByObservable<T, S> extends Observable<T> {
  /// The key is the category to which all events in this group belong to.
  final S key;

  /// Constructs an [Observable] which only emits events that can be
  /// categorized under [key].
  GroupByObservable(this.key, Stream<T> stream) : super(stream);
}
