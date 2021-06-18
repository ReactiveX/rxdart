import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
Stream<R> forwardStream<T, R>(Stream<T> stream, ForwardingSink<T, R> sink) =>
    stream.isBroadcast
        ? _forwardBroadcast(stream, sink)
        : _forwardSingleSubscription(stream, sink);

Stream<R> _forwardBroadcast<T, R>(Stream<T> stream, ForwardingSink<T, R> sink) {
  final compositeController = _CompositeMultiStreamController<R>();
  StreamSubscription<T>? subscription;
  var isCancelled = false;

  return Stream<R>.multi((controller) {
    final wasEmpty = compositeController.isEmpty;
    compositeController.addController(controller);

    var cancelledEach = false;

    if (wasEmpty) {
      void listenToUpstream([void _]) {
        if (cancelledEach || isCancelled) {
          return;
        }
        subscription = stream.listen(
          (data) => sink.add(compositeController, data),
          onError: (Object e, StackTrace st) =>
              sink.addError(compositeController, e, st),
          onDone: () => sink.close(compositeController),
        );
      }

      final futureOrVoid = sink.onListen(compositeController);
      if (futureOrVoid is Future<void>) {
        futureOrVoid.then(listenToUpstream);
      } else {
        listenToUpstream();
      }
    }

    controller.onCancel = () {
      cancelledEach = true;

      FutureOr<void>? onCancelUpstreamFuture;
      compositeController.removeController(controller);
      if (compositeController.isEmpty) {
        onCancelUpstreamFuture = subscription?.cancel();
        subscription = null;
        isCancelled = true;
      }

      final onCancelConnectedFuture = sink.onCancel(compositeController);

      return _waitFutures([
        if (onCancelUpstreamFuture is Future<void>) onCancelUpstreamFuture,
        if (onCancelConnectedFuture is Future<void>) onCancelConnectedFuture,
      ]);
    };
  }, isBroadcast: true);
}

Stream<R> _forwardSingleSubscription<T, R>(
  Stream<T> stream,
  ForwardingSink<T, R> sink,
) {
  final controller = StreamController<R>(sync: true);

  StreamSubscription<T>? subscription;
  var cancelled = false;

  controller.onListen = () {
    void listenToUpstream([void _]) {
      if (cancelled) {
        return;
      }
      subscription = stream.listen(
        (data) => sink.add(controller, data),
        onError: (Object e, StackTrace s) => sink.addError(controller, e, s),
        onDone: () => sink.close(controller),
      );

      controller.onPause = () {
        subscription!.pause();
        sink.onPause(controller);
      };
      controller.onResume = () {
        subscription!.resume();
        sink.onResume(controller);
      };
    }

    final futureOrVoid = sink.onListen(controller);
    if (futureOrVoid is Future<void>) {
      futureOrVoid.then(listenToUpstream);
    } else {
      listenToUpstream();
    }
  };
  controller.onCancel = () {
    cancelled = true;

    final onCancelUpstreamFuture = subscription?.cancel();
    subscription = null;
    final onCancelConnectedFuture = sink.onCancel(controller);

    return _waitFutures([
      if (onCancelUpstreamFuture is Future<void>) onCancelUpstreamFuture,
      if (onCancelConnectedFuture is Future<void>) onCancelConnectedFuture,
    ]);
  };
  return controller.stream;
}

FutureOr<void> _waitFutures(List<Future<void>> futures) {
  if (futures.isEmpty) {
    return null;
  }
  if (futures.length == 1) {
    return futures[0];
  }
  return Future.wait(futures);
}

class _CompositeMultiStreamController<T> implements EventSink<T> {
  final _controllers = <MultiStreamController<T>>[];

  bool get isEmpty => _controllers.isEmpty;

  @override
  void add(T event) => _controllers.forEach((c) => c.add(event));

  @override
  void close() {
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
