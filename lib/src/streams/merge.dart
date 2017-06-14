import 'dart:async';

/// Flattens the items emitted by the given streams into a single Observable
/// sequence.
///
/// [Interactive marble diagram](http://rxmarbles.com/#merge)
///
/// ### Example
///
///     new MergeStream([
///       new TimerStream(1, new Duration(days: 10)),
///       new Stream.fromIterable([2])
///     ])
///     .listen(print); // prints 2, 1
class MergeStream<T> extends Stream<T> {
  final StreamController<T> controller;

  MergeStream(Iterable<Stream<T>> streams)
      : controller = _buildController(streams);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  static StreamController<T> _buildController<T>(Iterable<Stream<T>> streams) {
    final List<StreamSubscription<T>> subscriptions = streams != null
        ? new List<StreamSubscription<T>>(streams.length)
        : null;
    StreamController<T> controller;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          if (streams == null) {
            controller.addError(new ArgumentError('streams cannot be null'));
          } else if (streams.isEmpty) {
            controller.addError(
                new ArgumentError('at least 1 stream needs to be provided'));
          } else {
            final List<bool> completedStatus =
                new List<bool>.generate(streams.length, (_) => false);

            for (int i = 0, len = streams.length; i < len; i++) {
              Stream<T> stream = streams.elementAt(i);

              if (stream == null) {
                controller.addError(
                    new ArgumentError('stream at position $i is Null'));
              } else {
                subscriptions[i] = stream.listen(controller.add,
                    onError: controller.addError, onDone: () {
                  completedStatus[i] = true;

                  if (completedStatus.reduce((bool a, bool b) => a && b))
                    controller.close();
                });
              }
            }
          }
        },
        onCancel: () => Future.wait(subscriptions
            .map((StreamSubscription<T> subscription) => subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    return controller;
  }
}
