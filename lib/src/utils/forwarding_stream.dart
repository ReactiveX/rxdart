import 'dart:async';
import 'dart:math';

import 'package:rxdart/src/utils/forwarding_sink.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
Stream<R> forwardStream<T, R>(
    Stream<T> stream, ForwardingSink<T, R> connectedSink) {
  final _compositeController = _CompositeMultiStreamController<R>();
  StreamSubscription<T>? subscription;
  var isDone = false;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void runCatching(void Function() block) {
    try {
      block();
    } catch (e, s) {
      connectedSink.addError(_compositeController, e, s);
    }
  }

  return Stream<R>.multi((controller) {
    if (isDone) {
      controller.close();

      return;
    }

    final totalListeners = _compositeController.totalListeners;

    _compositeController.addController(controller);

    final maybeListen = () {
      if (totalListeners >= 1) {
        return;
      }

      runCatching(() => connectedSink.onListen(_compositeController));

      subscription = stream.listen(
        (data) {
          runCatching(() => connectedSink.add(_compositeController, data));
        },
        onError: (Object e, StackTrace st) {
          runCatching(
              () => connectedSink.addError(_compositeController, e, st));
        },
        onDone: () {
          isDone = true;
          subscription?.cancel();

          runCatching(() => connectedSink.close(_compositeController));
        },
      );
    };

    if (controller.hasListener) {
      maybeListen();
    }

    controller.onListen = maybeListen;
    controller.onPause = () {
      subscription?.pause();
      runCatching(() => connectedSink.onPause(_compositeController));
    };
    controller.onResume = () {
      subscription?.resume();
      runCatching(() => connectedSink.onResume(_compositeController));
    };
    controller.onCancel = () {
      final onCancelConnectedFuture =
          connectedSink.onCancel(_compositeController);
      final onCancelSubscriptionFuture = subscription?.cancel();
      final futures = <Future>[
        if (onCancelConnectedFuture is Future) onCancelConnectedFuture,
        if (onCancelSubscriptionFuture is Future) onCancelSubscriptionFuture,
      ];
      _compositeController.removeController(controller);
      return Future.wait<dynamic>(futures);
    };
  }, isBroadcast: stream.isBroadcast);
}

class _CompositeMultiStreamController<T> implements EventSink<T> {
  final Set<MultiStreamController<T>> _currentListeners =
      <MultiStreamController<T>>{};

  int get totalListeners => _currentListeners.length;

  @override
  void add(T event) {
    for (var listener in [..._currentListeners]) {
      listener.addSync(event);
    }
  }

  @override
  void close() {
    for (var listener in _currentListeners) {
      listener.close();
    }

    _currentListeners.clear();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    for (var listener in [..._currentListeners]) {
      listener.addErrorSync(error, stackTrace);
    }
  }

  bool addController(MultiStreamController<T> controller) =>
      _currentListeners.add(controller);

  bool removeController(MultiStreamController<T> controller) =>
      _currentListeners.remove(controller);
}
