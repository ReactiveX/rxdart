import 'dart:async';

class ZipStream<T> extends Stream<T> {
  final Iterable<Stream<dynamic>> streams;
  final Function predicate;

  ZipStream(this.streams, this.predicate);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    StreamController<T> controller;
    final List<bool> pausedStates =
        new List<bool>.generate(streams.length, (_) => false, growable: false);
    final List<StreamSubscription<dynamic>> subscriptions =
        new List<StreamSubscription<dynamic>>(streams.length);

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          final List<dynamic> values = new List<dynamic>(streams.length);
          final List<bool> completedStatus =
              new List<bool>.generate(streams.length, (_) => false);

          void doUpdate(int index, dynamic value) {
            values[index] = value;
            pausedStates[index] = true;

            // subscriptions[i] might be null if doUpdate triggers
            // instantly (i.e. BehaviourSubject)
            if (subscriptions[index] != null) subscriptions[index].pause();

            if (_areAllPaused(pausedStates)) {
              updateWithValues(predicate, values, controller);

              _resumeAll(subscriptions, pausedStates);
            }
          }

          void markDone(int i) {
            completedStatus[i] = true;

            if (completedStatus.reduce((bool a, bool b) => a && b))
              controller.close();
          }

          for (int i = 0, len = streams.length; i < len; i++) {
            subscriptions[i] = streams.elementAt(i).listen(
                (dynamic value) => doUpdate(i, value),
                onError: controller.addError,
                onDone: () => markDone(i));

            // updating the above subscription if doUpdate triggered too soon
            if (pausedStates[i] && !subscriptions[i].isPaused)
              subscriptions[i].pause();
          }
        },
        onCancel: () => Future.wait(subscriptions
            .map((StreamSubscription<dynamic> subscription) =>
                subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  static void updateWithValues<T>(Function predicate, Iterable<dynamic> values,
      StreamController<T> controller) {
    try {
      final int len = values.length;
      T result;

      switch (len) {
        case 2:
          result = predicate(values.elementAt(0), values.elementAt(1));
          break;
        case 3:
          result = predicate(
              values.elementAt(0), values.elementAt(1), values.elementAt(2));
          break;
        case 4:
          result = predicate(values.elementAt(0), values.elementAt(1),
              values.elementAt(2), values.elementAt(3));
          break;
        case 5:
          result = predicate(values.elementAt(0), values.elementAt(1),
              values.elementAt(2), values.elementAt(3), values.elementAt(4));
          break;
        case 6:
          result = predicate(
              values.elementAt(0),
              values.elementAt(1),
              values.elementAt(2),
              values.elementAt(3),
              values.elementAt(4),
              values.elementAt(5));
          break;
        case 7:
          result = predicate(
              values.elementAt(0),
              values.elementAt(1),
              values.elementAt(2),
              values.elementAt(3),
              values.elementAt(4),
              values.elementAt(5),
              values.elementAt(6));
          break;
        case 8:
          result = predicate(
              values.elementAt(0),
              values.elementAt(1),
              values.elementAt(2),
              values.elementAt(3),
              values.elementAt(4),
              values.elementAt(5),
              values.elementAt(6),
              values.elementAt(7));
          break;
        case 9:
          result = predicate(
              values.elementAt(0),
              values.elementAt(1),
              values.elementAt(2),
              values.elementAt(3),
              values.elementAt(4),
              values.elementAt(5),
              values.elementAt(6),
              values.elementAt(7),
              values.elementAt(8));
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
