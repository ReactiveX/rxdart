import 'dart:async';

/// Concatenates all of the specified stream sequences, as long as the
/// previous stream sequence terminated successfully.
///
/// It does this by subscribing to each stream one by one, emitting all items
/// and completing before subscribing to the next stream.
///
/// [Interactive marble diagram](http://rxmarbles.com/#concat)
///
/// ### Example
///
///     new ConcatStream([
///       new Stream.fromIterable([1]),
///       new TimerStream(2, new Duration(days: 1)),
///       new Stream.fromIterable([3])
///     ])
///     .listen(print); // prints 1, 2, 3
class ConcatStream<T> extends Stream<T> {
  final StreamController<T> controller;

  ConcatStream(Iterable<Stream<T>> streams)
      : controller = _buildController(streams);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  static StreamController<T> _buildController<T>(Iterable<Stream<T>> streams) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          final int len = streams.length;
          int index = 0;

          void moveNext() {
            Stream<T> stream = streams.elementAt(index);
            subscription?.cancel();

            subscription = stream.listen(controller.add,
                onError: controller.addError, onDone: () {
              index++;

              if (index == len)
                controller.close();
              else
                moveNext();
            });
          }

          moveNext();
        },
        onCancel: () => subscription.cancel());

    return controller;
  }
}
