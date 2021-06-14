import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
Stream<R> forwardStream<T, R>(Stream<T> stream, ForwardingSink<T, R> sink) {
  StreamSubscription<T>? subscription;

  if (!stream.isBroadcast) {

  }

  final controllers = _CompositeMultiStreamController<R>();
  return Stream<R>.multi((controller) {
    if (controllers._isDone) {
      controller.close();
      return;
    }

    final wasEmpty = controllers.isEmpty;
    controllers.addController(controller);

    var cancelledEach = false;

    final onListen = () {
      if (wasEmpty) {
        void listenToUpstream([void _]) {
          if (cancelledEach) {
            return;
          }
          subscription = stream.listen(
            (data) => sink.add(controllers, data),
            onError: (Object e, StackTrace st) =>
                sink.addError(controllers, e, st),
            onDone: () => sink.close(controllers),
          );
        }

        final futureOrVoid = sink.onListen(controllers);
        if (futureOrVoid is Future<void>) {
          futureOrVoid.then(listenToUpstream);
        } else {
          listenToUpstream();
        }
      }
    };

    FutureOr<void> onCancel() {
      cancelledEach = true;

      FutureOr<void>? onCancelUpstreamFuture;

      controllers.removeController(controller);
      if (controllers.isEmpty) {
        onCancelUpstreamFuture = subscription?.cancel();
        subscription = null;
      }

      final onCancelConnectedFuture = sink.onCancel(controllers);
      final futures = <Future<void>>[
        if (onCancelUpstreamFuture is Future<void>) onCancelUpstreamFuture,
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

    final onPause = () {
      subscription!.pause();
      sink.onPause(controllers);
    };

    final onResume = () {
      subscription!.resume();
      sink.onResume(controllers);
    };

    // Setup handlers
    onListen();

    if (!stream.isBroadcast) {
      controller.onPause = onPause;
      controller.onResume = onResume;
    }
    controller.onCancel = onCancel;
  }, isBroadcast: true);
}

class _CompositeMultiStreamController<T> implements EventSink<T> {
  final _controllers = <MultiStreamController<T>>[];
  var _isDone = false;

  bool get isEmpty => _controllers.isEmpty;

  bool get isDone => _isDone;

  @override
  void add(T event) => _controllers.forEach((c) => c.add(event));

  @override
  void close() {
    _isDone = true;
    _controllers.forEach((c) {
      c.onCancel = null;
      c.closeSync();
    });
    _controllers.clear();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _controllers.forEach((c) => c.addErrorSync(error, stackTrace));

  void addController(MultiStreamController<T> controller) =>
      _controllers.add(controller);

  bool removeController(MultiStreamController<T> controller) =>
      _controllers.remove(controller);
}
