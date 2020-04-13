import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/utils/forwarding_sink.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
_ForwardStream<T> forwardStream<T>(Stream<T> stream) {
  StreamController<T> controller;
  ForwardingSink<T> connectedSink;
  StreamSubscription<T> subscription;

  final onListen = () {
    try {
      connectedSink?.onListen(controller.sink);
    } catch (e, s) {
      connectedSink.addError(e, s);
    }

    subscription = stream.listen(controller.add,
        onError: controller.addError, onDone: connectedSink.close);

    if (connectedSink is ForwardingWithSubscriptionSink<T>) {
      final sinkCast = connectedSink as ForwardingWithSubscriptionSink<T>;

      sinkCast.sourceSubscription = subscription;
    }
  };

  final onCancel = () {
    if (connectedSink?.onCancel != null) {
      final onCancelSelfFuture = subscription.cancel();
      final onCancelConnectedFuture = connectedSink.onCancel(controller.sink);
      final futures = <Future>[];

      if (onCancelSelfFuture is Future) {
        futures.add(onCancelSelfFuture);
      }

      if (onCancelConnectedFuture is Future) {
        futures.add(onCancelConnectedFuture);
      }

      if (futures.isNotEmpty) {
        return Future.wait<dynamic>(futures);
      }
    }

    return subscription.cancel();
  };

  final onPause = ([Future resumeSignal]) {
    subscription.pause(resumeSignal);

    try {
      connectedSink?.onPause(controller.sink, resumeSignal);
    } catch (e, s) {
      connectedSink.addError(e, s);
    }
  };

  final onResume = () {
    subscription.resume();

    try {
      connectedSink?.onResume(controller.sink);
    } catch (e, s) {
      connectedSink.addError(e, s);
    }
  };

  // Create a new Controller, which will serve as a trampoline for
  // forwarded events.
  if (stream is Subject<T>) {
    controller = stream.createForwardingController(
        onListen: onListen, onCancel: onCancel, sync: true);
  } else if (stream.isBroadcast) {
    controller = StreamController<T>.broadcast(
        onListen: onListen, onCancel: onCancel, sync: true);
  } else {
    controller = StreamController<T>(
        onListen: onListen,
        onPause: onPause,
        onResume: onResume,
        onCancel: onCancel,
        sync: true);
  }

  return _ForwardStream<T>(
      controller.stream, (ForwardingSink<T> sink) => connectedSink = sink);
}

class _ForwardStream<T> {
  final Stream<T> stream;
  final ForwardingSink<T> Function(ForwardingSink<T> sink) connect;

  _ForwardStream(this.stream, this.connect);
}
