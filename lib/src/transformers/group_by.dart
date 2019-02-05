import 'dart:async';

import 'package:rxdart/src/observables/observable.dart' show Observable;

/// The GroupBy operator divides an [Observable] that emits items into
/// an [Observable] that emits [Observable],
/// each one of which emits some subset of the items
/// from the original source [Observable].
///
/// Which items end up on which Observable is decided by a
/// [grouper] that evaluates each item and assigns it a key.
/// All items with the same key are emitted by the same Observable.

class GroupByStreamTransformer<T, S>
    extends StreamTransformerBase<T, GroupByObservable<T, S>> {
  final S Function(T) grouper;

  GroupByStreamTransformer(this.grouper);

  @override
  Stream<GroupByObservable<T, S>> bind(Stream<T> stream) =>
      _buildTransformer<T, S>(grouper).bind(stream);

  static StreamTransformer<T, GroupByObservable<T, S>> _buildTransformer<T, S>(
      S Function(T) grouper) {
    return new StreamTransformer<T, GroupByObservable<T, S>>(
        (Stream<T> input, bool cancelOnError) {
      final mapper = <S, StreamController<T>>{};
      StreamController<GroupByObservable<T, S>> controller;
      StreamSubscription<T> subscription;

      final controllerBuilder = (S forKey) => () {
            final groupedController = new StreamController<T>();

            controller.add(
                new GroupByObservable<T, S>(forKey, groupedController.stream));

            return groupedController;
          };

      controller = new StreamController<GroupByObservable<T, S>>(
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

class GroupByObservable<T, S> extends Observable<T> {
  final S key;

  GroupByObservable(this.key, Stream<T> stream) : super(stream);
}
