import 'dart:async';

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
      connectedSink?.onListen();
    } catch (e, s) {
      connectedSink.addError(e, s);
    }

    subscription = stream.listen(controller.add,
        onError: controller.addError, onDone: controller.close);
  };

  final onCancel = () {
    if (connectedSink?.onCancel != null) {
      final onCancelFuture = connectedSink.onCancel();

      if (onCancelFuture is Future) {
        return Future.wait<dynamic>([subscription.cancel(), onCancelFuture]);
      }
    }

    return subscription.cancel();
  };

  final onPause = () {
    subscription.pause();

    try {
      connectedSink?.onPause();
    } catch (e, s) {
      connectedSink.addError(e, s);
    }
  };

  final onResume = () {
    subscription.resume();

    try {
      connectedSink?.onResume();
    } catch (e, s) {
      connectedSink.addError(e, s);
    }
  };

  if (stream.isBroadcast) {
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
