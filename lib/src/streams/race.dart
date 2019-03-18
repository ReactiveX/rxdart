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
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  static StreamController<T> _buildController<T>(Iterable<Stream<T>> streams) {
    if (streams == null) {
      throw ArgumentError('streams cannot be null');
    } else if (streams.isEmpty) {
      throw ArgumentError('provide at least 1 stream');
    }

    List<StreamSubscription<T>> subscriptions;
    StreamController<T> controller;

    controller = StreamController<T>(
        sync: true,
        onListen: () {
          var index = 0;

          final reduceToWinner = (int winnerIndex) {
            //ignore: cancel_subscriptions
            final winner = subscriptions.removeAt(winnerIndex);

            subscriptions.forEach((subscription) => subscription.cancel());

            subscriptions = [winner];
          };

          final doUpdate = (int index) => (T value) {
                try {
                  if (subscriptions.length > 1) reduceToWinner(index);

                  controller.add(value);
                } catch (e, s) {
                  controller.addError(e, s);
                }
              };

          subscriptions = streams
              .map((stream) => stream.listen(doUpdate(index++),
                  onError: controller.addError, onDone: controller.close))
              .toList();
        },
        onPause: ([Future<dynamic> resumeSignal]) => subscriptions
            .forEach((subscription) => subscription.pause(resumeSignal)),
        onResume: () =>
            subscriptions.forEach((subscription) => subscription.resume()),
        onCancel: () => Future.wait<dynamic>(subscriptions
            .where((subscription) => subscription != null)
            .map((subscription) => subscription.cancel())
            .where((cancelFuture) => cancelFuture != null)));

    return controller;
  }
}
