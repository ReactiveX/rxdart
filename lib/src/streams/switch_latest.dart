import 'dart:async';

/// Convert a Stream that emits Streams (aka a "Higher Order Stream") into a
/// single Stream that emits the items emitted by the most-recently-emitted of
/// those Streams.
///
/// This stream will unsubscribe from the previously-emitted Stream when a new
/// Stream is emitted from the source Stream.
///
/// ### Example
///
/// ```dart
/// final switchLatestStream = new SwitchLatestStream<String>(
///   new Stream.fromIterable(<Stream<String>>[
///     new Observable.timer('A', new Duration(seconds: 2)),
///     new Observable.timer('B', new Duration(seconds: 1)),
///     new Observable.just('C'),
///   ]),
/// );
///
/// // Since the first two Streams do not emit data for 1-2 seconds, and the 3rd
/// // Stream will be emitted before that time, only data from the 3rd Stream
/// // will be emitted to the listener.
/// switchLatestStream.listen(print); // prints 'C'
/// ```
class SwitchLatestStream<T> extends Stream<T> {
  final Stream<Stream<T>> streams;

  // ignore: close_sinks
  StreamController<T> _controller;

  SwitchLatestStream(this.streams);

  @override
  StreamSubscription<T> listen(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    _controller ??= _buildController(streams, cancelOnError);

    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  static StreamController<T> _buildController<T>(
    Stream<Stream<T>> streams,
    bool cancelOnError,
  ) {
    StreamController<T> controller;
    StreamSubscription<Stream<T>> subscription;
    StreamSubscription<T> otherSubscription;
    var leftClosed = false, rightClosed = false, hasMainEvent = false;

    controller = StreamController<T>(
        sync: true,
        onListen: () {
          final closeLeft = () {
            leftClosed = true;

            if (rightClosed || !hasMainEvent) controller.close();
          };

          final closeRight = () {
            rightClosed = true;

            if (leftClosed) controller.close();
          };

          subscription = streams.listen(
            (stream) {
              try {
                otherSubscription?.cancel();

                hasMainEvent = true;

                otherSubscription = stream.listen(
                  controller.add,
                  onError: controller.addError,
                  onDone: closeRight,
                );
              } catch (e, s) {
                controller.addError(e, s);
              }
            },
            onError: controller.addError,
            onDone: closeLeft,
            cancelOnError: cancelOnError,
          );
        },
        onPause: ([Future<dynamic> resumeSignal]) {
          subscription.pause(resumeSignal);
          otherSubscription?.pause(resumeSignal);
        },
        onResume: () {
          subscription.resume();
          otherSubscription?.resume();
        },
        onCancel: () async {
          await subscription.cancel();

          if (hasMainEvent) await otherSubscription.cancel();
        });

    return controller;
  }
}
