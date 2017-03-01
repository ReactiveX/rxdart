import 'dart:async';

class CombineLatestStream<T> extends Stream<T> {
  final StreamController<T> controller;

  CombineLatestStream(Iterable<Stream<dynamic>> streams, Function predicate)
      : controller = _buildController(streams, predicate);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  static StreamController<T> _buildController<T>(
      Iterable<Stream<dynamic>> streams, Function predicate) {
    final List<StreamSubscription<dynamic>> subscriptions =
        new List<StreamSubscription<dynamic>>(streams.length);
    StreamController<T> controller;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          final List<dynamic> values = new List<dynamic>(streams.length);
          final List<bool> triggered =
              new List<bool>.generate(streams.length, (_) => false);
          final List<bool> completedStatus =
              new List<bool>.generate(streams.length, (_) => false);
          bool allStreamsHaveEvents = false;

          for (int i = 0, len = streams.length; i < len; i++) {
            Stream<dynamic> stream = streams.elementAt(i);

            subscriptions[i] = stream.listen(
                (dynamic value) {
                  values[i] = value;
                  triggered[i] = true;

                  if (!allStreamsHaveEvents)
                    allStreamsHaveEvents =
                        triggered.reduce((bool a, bool b) => a && b);

                  if (allStreamsHaveEvents)
                    updateWithValues(predicate, values, controller);
                },
                onError: controller.addError,
                onDone: () {
                  completedStatus[i] = true;

                  if (completedStatus.reduce((bool a, bool b) => a && b))
                    controller.close();
                });
          }
        },
        onCancel: () => Future.wait(subscriptions
            .map((StreamSubscription<dynamic> subscription) =>
                subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    return controller;
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
}
