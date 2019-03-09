import 'dart:async';

/// Given two or more source streams, emit all of the items from only
/// the first of these streams to emit an item or notification.
///
/// [Interactive marble diagram](http://rxmarbles.com/#amb)
///
/// ### Example
///
///     new RaceStream([
///       new TimerStream(1, new Duration(days: 1)),
///       new TimerStream(2, new Duration(days: 2)),
///       new TimerStream(3, new Duration(seconds: 3))
///     ]).listen(print); // prints 3
class RaceStream<T> extends Stream<T> {
  final StreamController<T> controller;

  RaceStream(Iterable<Stream<T>> streams)
      : controller = _buildController(streams);

  @override
  StreamSubscription<T> listen(void onData(T event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  static StreamController<T> _buildController<T>(Iterable<Stream<T>> streams) {
    if (streams == null) {
      throw ArgumentError('streams cannot be null');
    } else if (streams.isEmpty) {
      throw ArgumentError('provide at least 1 stream');
    }

    final len = streams.length;
    var subscriptions = List<StreamSubscription<T>>(len);
    var hasWinner = false;

    StreamController<T> controller;

    controller = StreamController<T>(
        sync: true,
        onListen: () {
          final onEvent = (int i) => (T value) {
                try {
                  if (!hasWinner) {
                    for (var k = len - 1; k >= 0; k--) {
                      if (k != i) {
                        subscriptions[k].cancel();
                      }
                    }

                    subscriptions = [subscriptions[i]];
                  }

                  hasWinner = true;

                  controller.add(value);
                } catch (e, s) {
                  controller.addError(e, s);
                }
              };

          final onDone = () => controller.close();

          for (var i = 0; i < len; i++) {
            var stream = streams.elementAt(i);

            subscriptions[i] = stream.listen(onEvent(i),
                onError: controller.addError, onDone: onDone);
          }
        },
        onPause: ([Future<dynamic> resumeSignal]) => subscriptions
            .forEach((subscription) => subscription.pause(resumeSignal)),
        onResume: () =>
            subscriptions.forEach((subscription) => subscription.resume()),
        onCancel: () => Future.wait<dynamic>(subscriptions.map((subscription) {
              if (subscription != null) return subscription.cancel();

              return Future<dynamic>.value();
            }).where((cancelFuture) => cancelFuture != null)));

    return controller;
  }
}
