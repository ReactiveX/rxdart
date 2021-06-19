import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
Stream<R> forwardStream<T, R>(
  Stream<T> stream,
  ForwardingSink<T, R> sink, [
  bool listenOnlyOnce = false,
]) {
  return stream.isBroadcast
      ? listenOnlyOnce
          ? _forward(stream, sink)
          : _forwardMulti(stream, sink)
      : _forward(stream, sink);
}

Stream<R> _forwardMulti<T, R>(Stream<T> stream, ForwardingSink<T, R> sink) {
  final compositeController = _CompositeMultiStreamController<R>();

  return Stream<R>.multi((controller) {
    if (compositeController.done) {
      controller.close();
      return;
    }

    compositeController.addController(controller);

    StreamSubscription<T>? subscription;
    var cancelled = false;

    void listenToUpstream([void _]) {
      if (cancelled) {
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

    controller.onCancel = () {
      cancelled = true;
      compositeController.removeController(controller);

      final future = subscription?.cancel();
      subscription = null;
      return _waitFutures(future, sink.onCancel(compositeController));
    };
  }, isBroadcast: true);
}

Stream<R> _forward<T, R>(
  Stream<T> stream,
  ForwardingSink<T, R> sink,
) {
  final controller = stream.isBroadcast
      ? StreamController<R>.broadcast(sync: true)
      : StreamController<R>(sync: true);

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

      if (!stream.isBroadcast) {
        controller.onPause = () {
          subscription!.pause();
          sink.onPause(controller);
        };
        controller.onResume = () {
          subscription!.resume();
          sink.onResume(controller);
        };
      }
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

    final future = subscription?.cancel();
    subscription = null;

    return _waitFutures(future, sink.onCancel(controller));
  };
  return controller.stream;
}

FutureOr<void> _waitFutures(Future<void>? future1, FutureOr<void> future2) {
  if (future1 == null) {
    return future2;
  }
  if (future2 == null) {
    return future1;
  }
  if (future2 is Future<void>) {
    return Future.wait([future1, future2]);
  } else {
    return future1;
  }
}

class _CompositeMultiStreamController<T> implements EventSink<T> {
  final _controllers = <MultiStreamController<T>>[];

  var done = false;

  bool get isEmpty => _controllers.isEmpty;

  @override
  void add(T event) => [..._controllers].forEach((c) => c.addSync(event));

  @override
  void close() {
    _controllers.forEach((c) {
      c.onCancel = null;
      c.closeSync();
    });
    _controllers.clear();
    done = true;
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      [..._controllers].forEach((c) => c.addErrorSync(error, stackTrace));

  void addController(MultiStreamController<T> controller) =>
      _controllers.add(controller);

  bool removeController(MultiStreamController<T> controller) =>
      _controllers.remove(controller);
}
