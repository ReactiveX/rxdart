import 'dart:async';

/// The GroupBy operator divides a Stream that emits items into a Stream that
/// emits Stream, each one of which emits some subset of the items from the
/// original source Stream.
///
///  Which items end up on which Stream is typically decided by a
///  discriminating function that evaluates each item and assigns it a
///  key. All items with the same key are emitted by the same Observable.
class GroupByStreamTransformer<T, S>
    implements StreamTransformer<T, GroupByMap<S, T>> {
  final StreamTransformer<T, GroupByMap<S, T>> transformer;

  GroupByStreamTransformer(S keySelector(T value),
      {int compareKeys(S keyA, S keyB)})
      : transformer = _buildTransformer(keySelector, compareKeys: compareKeys);

  @override
  Stream<GroupByMap<S, T>> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, GroupByMap<S, T>> _buildTransformer<T, S>(
      S keySelector(T value),
      {int compareKeys(S keyA, S keyB)}) {
    return new StreamTransformer<T, GroupByMap<S, T>>(
        (Stream<T> input, bool cancelOnError) {
      final List<GroupByMap<S, T>> allMaps = <GroupByMap<S, T>>[];
      StreamController<GroupByMap<S, T>> controller;
      StreamSubscription<T> subscription;

      compareKeys ??= (S keyA, S keyB) => keyA == keyB ? 0 : -1;

      controller = new StreamController<GroupByMap<S, T>>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  bool doAdd = false;
                  S key = keySelector(value);
                  GroupByMap<S, T> map = allMaps.firstWhere(
                      (GroupByMap<S, T> existingMap) =>
                          compareKeys(existingMap.key, key) == 0, orElse: () {
                    GroupByMap<S, T> newMap = new GroupByMap<S, T>(key);

                    allMaps.add(newMap);
                    doAdd = true;

                    return newMap;
                  });

                  if (doAdd) controller.add(map);

                  map._add(value);
                },
                onError: controller.addError,
                onDone: () async {
                  await Future.wait(
                      allMaps.map((GroupByMap<S, T> map) => map._close()));

                  await controller.close();
                },
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

class GroupByMap<T, S> {
  final T key;
  final StreamController<S> _controller = new StreamController<S>();

  Stream<S> get stream => _controller.stream;

  GroupByMap(this.key);

  Future<dynamic> _close() => _controller.close();

  void _add(S event) => _controller.add(event);
}
