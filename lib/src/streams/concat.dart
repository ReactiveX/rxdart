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
          if (streams == null) {
            controller.addError(new ArgumentError('streams cannot be null'));
          } else if (streams.isEmpty) {
            controller.addError(
                new ArgumentError('at least 1 stream needs to be provided'));
          } else {
            final int len = streams.length;
            int index = 0;

            Future<Null> moveNext() async {
              Stream<T> stream = streams.elementAt(index);
              Future<dynamic> cancelFuture = subscription?.cancel();

              if (cancelFuture != null) await cancelFuture;

              if (stream == null) {
                controller.addError(new ArgumentError('stream at position $index is Null'));
              } else {
                subscription = stream.listen(controller.add,
                    onError: controller.addError, onDone: () {
                      index++;

                      if (index == len)
                        controller.close();
                      else
                        moveNext();
                    });
              }
            }

            moveNext();
          }
        },
        onCancel: () => subscription.cancel());

    return controller;
  }
}
