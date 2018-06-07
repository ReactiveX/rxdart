import 'dart:async';

/// Merges the specified streams into one observable sequence using the given
/// combiner function whenever all of the observable sequences have produced
/// an element at a corresponding index.
///
/// It applies this function in strict sequence, so the first item emitted by
/// the new Observable will be the result of the function applied to the first
/// item emitted by Observable #1 and the first item emitted by Observable #2;
/// the second item emitted by the new zip-Observable will be the result of
/// the function applied to the second item emitted by Observable #1 and the
/// second item emitted by Observable #2; and so forth. It will only emit as
/// many items as the number of items emitted by the source Observable that
/// emits the fewest items.
///
/// [Interactive marble diagram](http://rxmarbles.com/#zip)
///
/// ### Example
///
///     new ZipStream([
///         new Stream.fromIterable([1]),
///         new Stream.fromIterable([2, 3])
///       ], (a, b) => a + b)
///       .listen(print); // prints 3
class ZipStream<T, A, B, C, D, E, F, G, H, I> extends Stream<T> {
  final StreamController<T> controller;

  ZipStream(Iterable<Stream<dynamic>> streams,
      T zipper(A a, B b, [C c, D d, E e, F f, G g, H h, I i]))
      : controller = _buildController(streams, zipper);

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  static StreamController<T> _buildController<T, A, B, C, D, E, F, G, H, I>(
      Iterable<Stream<dynamic>> streams,
      T zipper(A a, B b, [C c, D d, E e, F f, G g, H h, I i])) {
    if (streams == null) {
      throw new ArgumentError('streams cannot be null');
    } else if (streams.isEmpty) {
      throw new ArgumentError('at least 1 stream needs to be provided');
    } else if (streams.any((Stream<dynamic> stream) => stream == null)) {
      throw new ArgumentError('One of the provided streams is null');
    }

    StreamController<T> controller;
    final List<bool> pausedStates =
        new List<bool>.generate(streams.length, (_) => false, growable: false);
    final List<StreamSubscription<dynamic>> subscriptions =
        new List<StreamSubscription<dynamic>>(streams.length);

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          try {
            final List<dynamic> values = new List<dynamic>(streams.length);
            final List<bool> completedStatus =
                new List<bool>.generate(streams.length, (_) => false);

            void doUpdate(int index, dynamic value) {
              values[index] = value;
              pausedStates[index] = true;

              // subscriptions[i] might be null if doUpdate triggers
              // instantly (i.e. BehaviorSubject)
              if (subscriptions[index] != null) subscriptions[index].pause();

              if (_areAllPaused(pausedStates)) {
                updateWithValues(zipper, values, controller);

                _resumeAll(subscriptions, pausedStates);
              }
            }

            void markDone(int i) {
              completedStatus[i] = true;

              if (completedStatus.reduce((bool a, bool b) => a && b))
                controller.close();
            }

            for (int i = 0, len = streams.length; i < len; i++) {
              Stream<dynamic> stream = streams.elementAt(i);

              subscriptions[i] = stream.listen(
                  (dynamic value) => doUpdate(i, value),
                  onError: controller.addError,
                  onDone: () => markDone(i));

              // updating the above subscription if doUpdate triggered too soon
              if (pausedStates[i] && !subscriptions[i].isPaused)
                subscriptions[i].pause();
            }
          } catch (e, s) {
            controller.addError(e, s);
          }
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscriptions.where((StreamSubscription<dynamic> subscription) => subscription != null).forEach(
                (StreamSubscription<dynamic> subscription) =>
                    subscription.pause(resumeSignal)),
        onResume: () =>
            subscriptions.where((StreamSubscription<dynamic> subscription) => subscription != null).forEach(
                (StreamSubscription<dynamic> subscription) =>
                    subscription.resume()),
        onCancel: () => Future.wait<dynamic>(subscriptions
            .map((StreamSubscription<dynamic> subscription) => subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    return controller;
  }

  static void updateWithValues<T, A, B, C, D, E, F, G, H, I>(
      T zipper(A a, B b, [C c, D d, E e, F f, G g, H h, I i]),
      Iterable<dynamic> values,
      StreamController<T> controller) {
    try {
      final int len = values.length;
      final A a = values.elementAt(0);
      final B b = values.elementAt(1);
      T result;

      switch (len) {
        case 2:
          result = zipper(a, b);
          break;
        case 3:
          final C c = values.elementAt(2);

          result = zipper(a, b, c);
          break;
        case 4:
          final C c = values.elementAt(2);
          final D d = values.elementAt(3);

          result = zipper(a, b, c, d);
          break;
        case 5:
          final C c = values.elementAt(2);
          final D d = values.elementAt(3);
          final E e = values.elementAt(4);

          result = zipper(a, b, c, d, e);
          break;
        case 6:
          final C c = values.elementAt(2);
          final D d = values.elementAt(3);
          final E e = values.elementAt(4);
          final F f = values.elementAt(5);

          result = zipper(a, b, c, d, e, f);
          break;
        case 7:
          final C c = values.elementAt(2);
          final D d = values.elementAt(3);
          final E e = values.elementAt(4);
          final F f = values.elementAt(5);
          final G g = values.elementAt(6);

          result = zipper(a, b, c, d, e, f, g);
          break;
        case 8:
          final C c = values.elementAt(2);
          final D d = values.elementAt(3);
          final E e = values.elementAt(4);
          final F f = values.elementAt(5);
          final G g = values.elementAt(6);
          final H h = values.elementAt(7);

          result = zipper(a, b, c, d, e, f, g, h);
          break;
        case 9:
          final C c = values.elementAt(2);
          final D d = values.elementAt(3);
          final E e = values.elementAt(4);
          final F f = values.elementAt(5);
          final G g = values.elementAt(6);
          final H h = values.elementAt(7);
          final I i = values.elementAt(8);

          result = zipper(a, b, c, d, e, f, g, h, i);
          break;
      }

      controller.add(result);
    } catch (e, s) {
      controller.addError(e, s);
    }
  }

  static bool _areAllPaused(List<bool> pausedStates) {
    for (int i = 0, len = pausedStates.length; i < len; i++) {
      if (!pausedStates[i]) return false;
    }

    return true;
  }

  static void _resumeAll(List<StreamSubscription<dynamic>> subscriptions,
      List<bool> pausedStates) {
    for (int i = 0, len = subscriptions.length; i < len; i++) {
      pausedStates[i] = false;
      subscriptions[i].resume();
    }
  }
}
