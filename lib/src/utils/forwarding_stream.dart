import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/subjects.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
Stream<R> forwardStream<T, R>(
    Stream<T> stream, ForwardingSink<T, R> connectedSink) {
  late StreamController<R> controller;
  StreamSubscription<T>? subscription;
  var cancelled = false;

  final onListen = () {
    void listenToUpstream([void _]) {
      if (cancelled) {
        return;
      }
      subscription = stream.listen(
        (data) => connectedSink.add(controller, data),
        onError: (Object e, StackTrace st) =>
            connectedSink.addError(controller, e, st),
        onDone: () => connectedSink.close(controller),
      );
    }

    final futureOrVoid = connectedSink.onListen(controller);
    if (futureOrVoid is Future<void>) {
      futureOrVoid.then(listenToUpstream);
    } else {
      listenToUpstream();
    }
  };

  FutureOr<void> onCancel() {
    cancelled = true;

    final onCancelSelfFuture = subscription?.cancel();
    subscription = null;
    final onCancelConnectedFuture = connectedSink.onCancel(controller);
    final futures = <Future<void>>[
      if (onCancelSelfFuture is Future<void>) onCancelSelfFuture,
      if (onCancelConnectedFuture is Future<void>) onCancelConnectedFuture,
    ];

    if (futures.isEmpty) {
      return null;
    }
    if (futures.length == 1) {
      return futures[0];
    }
    return Future.wait(futures);
  }

  ;

  final onPause = () {
    subscription!.pause();
    connectedSink.onPause(controller);
  };

  final onResume = () {
    subscription!.resume();
    connectedSink.onResume(controller);
  };

  // Create a new Controller, which will serve as a trampoline for
  // forwarded events.
  if (stream is Subject<T>) {
    controller = stream.createForwardingSubject<R>(
      onListen: onListen,
      onCancel: onCancel,
      sync: true,
    );
  } else if (stream.isBroadcast) {
    controller = StreamController<R>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: true,
    );
  } else {
    controller = StreamController<R>(
      onListen: onListen,
      onPause: onPause,
      onResume: onResume,
      onCancel: onCancel,
      sync: true,
    );
  }

  return controller.stream;
}
