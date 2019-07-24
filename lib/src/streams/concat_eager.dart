import 'dart:async';

/// Concatenates all of the specified stream sequences, as long as the
/// previous stream sequence terminated successfully.
///
/// In the case of concatEager, rather than subscribing to one stream after
/// the next, all streams are immediately subscribed to. The events are then
/// captured and emitted at the correct time, after the previous stream has
/// finished emitting items.
///
/// [Interactive marble diagram](http://rxmarbles.com/#concat)
///
/// ### Example
///
///     new ConcatEagerStream([
///       new Stream.fromIterable([1]),
///       new TimerStream(2, new Duration(days: 1)),
///       new Stream.fromIterable([3])
///     ])
///     .listen(print); // prints 1, 2, 3
class ConcatEagerStream<T> extends Stream<T> {
  final StreamController<T> controller;

  ConcatEagerStream(Iterable<Stream<T>> streams)
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

    final len = streams.length;
    final completeEvents = List.generate(len, (_) => Completer<dynamic>());
    List<StreamSubscription<T>> subscriptions;
    StreamController<T> controller;
    //ignore: cancel_subscriptions
    StreamSubscription<T> activeSubscription;

    controller = StreamController<T>(
        sync: true,
        onListen: () {
          var index = -1, completed = 0;

          final onDone = (int index) {
            final completer = completeEvents[index];

            return () {
              completer.complete();

              if (++completed == len) {
                controller.close();
              } else {
                activeSubscription = subscriptions[index + 1];
              }
            };
          };

          final createSubscription = (Stream<T> stream) {
            index++;
            //ignore: cancel_subscriptions
            final subscription = stream.listen(controller.add,
                onError: controller.addError, onDone: onDone(index));

            // pause all subscriptions, except the first, initially
            if (index > 0) subscription.pause(completeEvents[index - 1].future);

            return subscription;
          };

          subscriptions =
              streams.map(createSubscription).toList(growable: false);

          // initially, the very first subscription is the active one
          activeSubscription = subscriptions.first;
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            activeSubscription.pause(resumeSignal),
        onResume: () => activeSubscription.resume(),
        onCancel: () => Future.wait<dynamic>(subscriptions
            .map((subscription) => subscription.cancel())
            .where((cancelFuture) => cancelFuture != null)));

    return controller;
  }
}
