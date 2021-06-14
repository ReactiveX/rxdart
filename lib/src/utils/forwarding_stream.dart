import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
class ForwardedStream<T, R> extends Stream<R> {
  final Stream<T> _inner;
  Stream<R>? _outer;
  final ForwardingSink<T, R> _connectedSink;
  final _compositeController = _CompositeMultiStreamController<R>();
  StreamSubscription<T>? _subscription;
  var _isDone = false;

  /// Creates a new ForwardedStream
  ForwardedStream(
      {required Stream<T> inner, required ForwardingSink<T, R> connectedSink})
      : _inner = inner,
        _connectedSink = connectedSink;

  @override
  StreamSubscription<R> listen(void Function(R event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    if (_compositeController.totalListeners > 0 && !_inner.isBroadcast) {
      throw StateError('Stream has already been listened to');
    }

    _outer ??= _createOuterStream();

    return _outer!.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void _runCatching(void Function() block) {
    try {
      block();
    } catch (e, s) {
      _connectedSink.addError(_compositeController, e, s);
    }
  }

  Stream<R> _createOuterStream() => Stream<R>.multi((controller) {
        if (_isDone) {
          controller.close();

          return;
        }

        final totalListeners = _compositeController.totalListeners;

        _compositeController.addController(controller);

        final maybeListen = () {
          if (totalListeners >= 1) {
            return;
          }

          _runCatching(() => _connectedSink.onListen(_compositeController));

          _subscription = _inner.listen(
            (data) {
              _runCatching(
                  () => _connectedSink.add(_compositeController, data));
            },
            onError: (Object e, StackTrace st) {
              _runCatching(
                  () => _connectedSink.addError(_compositeController, e, st));
            },
            onDone: () {
              _isDone = true;
              _subscription?.cancel();

              _runCatching(() => _connectedSink.close(_compositeController));
            },
          );
        };

        if (controller.hasListener) {
          maybeListen();
        }

        controller.onListen = maybeListen;
        controller.onPause = () {
          _subscription?.pause();
          _runCatching(() => _connectedSink.onPause(_compositeController));
        };
        controller.onResume = () {
          _subscription?.resume();
          _runCatching(() => _connectedSink.onResume(_compositeController));
        };
        controller.onCancel = () {
          final onCancelConnectedFuture =
              _connectedSink.onCancel(_compositeController);
          final onCancelSubscriptionFuture = _subscription?.cancel();
          final futures = <Future>[
            if (onCancelConnectedFuture is Future) onCancelConnectedFuture,
            if (onCancelSubscriptionFuture is Future)
              onCancelSubscriptionFuture,
          ];
          _compositeController.removeController(controller);
          return Future.wait<dynamic>(futures);
        };
      }, isBroadcast: _inner.isBroadcast);
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
