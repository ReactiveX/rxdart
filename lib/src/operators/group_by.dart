import 'package:rxdart/src/observable/stream.dart';
import 'package:rxdart/src/observable.dart';

class GroupByObservable<T, S> extends StreamObservable<GroupByMap<S, T>> {
  GroupByObservable(Stream<T> stream, S keySelector(T value),
      {int compareKeys(S keyA, S keyB): null}) {
    setStream(stream.transform(new StreamTransformer<T, GroupByMap<S, T>>(
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
    })));
  }
}

class GroupByMap<T, S> {
  final T key;
  final StreamController<S> _controller = new StreamController<S>();

  Observable<S> get observable =>
      new StreamObservable<S>()..setStream(_controller.stream);

  GroupByMap(this.key);

  Future<dynamic> _close() => _controller.close();

  void _add(S event) => _controller.add(event);
}
