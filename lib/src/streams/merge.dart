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
    if (streams == null) {
      throw ArgumentError('streams cannot be null');
    } else if (streams.isEmpty) {
      throw ArgumentError('at least 1 stream needs to be provided');
    } else if (streams.any((Stream<T> stream) => stream == null)) {
      throw ArgumentError('One of the provided streams is null');
    }

    final subscriptions = List<StreamSubscription<T>>(streams.length);
    StreamController<T> controller;

    controller = StreamController<T>(
        sync: true,
        onListen: () {
          final completedStatus = List.generate(streams.length, (_) => false);

          for (var i = 0, len = streams.length; i < len; i++) {
            var stream = streams.elementAt(i);

            subscriptions[i] = stream.listen(controller.add,
                onError: controller.addError, onDone: () {
              completedStatus[i] = true;

              if (completedStatus.reduce((a, b) => a && b)) controller.close();
            });
          }
        },
        onPause: ([Future<dynamic> resumeSignal]) => subscriptions.forEach(
            (StreamSubscription<T> subscription) =>
                subscription.pause(resumeSignal)),
        onResume: () => subscriptions.forEach(
            (StreamSubscription<T> subscription) => subscription.resume()),
        onCancel: () => Future.wait<dynamic>(subscriptions
            .map((StreamSubscription<T> subscription) => subscription.cancel())
            .where((Future<dynamic> cancelFuture) => cancelFuture != null)));

    return controller;
  }
}
