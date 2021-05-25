import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/subjects.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
class ForwardingStream<T, R> extends Stream<R> {
  final Stream<T> _inner;
  final ForwardingSink<T, R> _connectedSink;
  late StreamController<R> _controller;
  late StreamSubscription<T> _subscription;
  bool _didListenOnce = false;

  /// Constructs a ForwardingStream using an underlying "inner" [Stream],
  /// and a [ForwardingSink], which will connect to events.
  ForwardingStream(this._inner, this._connectedSink) {
    final inner = _inner;
    // Create a new Controller, which will serve as a trampoline for
    // forwarded events.
    if (inner is Subject<T>) {
      _controller = inner.createForwardingSubject<R>(
        onListen: _onListen,
        onCancel: _onCancel,
        sync: true,
      );
    } else if (inner.isBroadcast) {
      _controller = StreamController<R>.broadcast(
        onListen: _onListen,
        onCancel: _onCancel,
        sync: true,
      );
    } else {
      _controller = StreamController<R>(
        onListen: _onListen,
        onPause: _onPause,
        onResume: _onResume,
        onCancel: _onCancel,
        sync: true,
      );
    }
  }

  @override
  StreamSubscription<R> listen(void Function(R event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    if (!_didListenOnce) {
      _subscription = _inner.listen(
        (data) => _runCatching(() => _connectedSink.add(_controller, data)),
        onError: (Object e, StackTrace st) =>
            _runCatching(() => _connectedSink.addError(_controller, e, st)),
        onDone: () => _runCatching(() => _connectedSink.close(_controller)),
      );
    }

    final subscription = _CombinedStreamSubscription(
        _didListenOnce ? _inner.listen(null) : null,
        _controller.stream.listen(onData,
            onDone: onDone, onError: onError, cancelOnError: cancelOnError));

    _didListenOnce = true;

    return subscription;
  }

  void _onListen() => _runCatching(() => _connectedSink.onListen(_controller));

  Future<List> _onCancel() {
    final onCancelSelfFuture = _subscription.cancel();
    final onCancelConnectedFuture = _connectedSink.onCancel(_controller);
    final futures = <Future>[
      if (onCancelSelfFuture is Future) onCancelSelfFuture,
      if (onCancelConnectedFuture is Future) onCancelConnectedFuture,
    ];
    return Future.wait<dynamic>(futures);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void _runCatching(void Function() block) {
    try {
      block();
    } catch (e, s) {
      _connectedSink.addError(_controller, e, s);
    }
  }

  void _onPause() {
    _subscription.pause();
    _runCatching(() => _connectedSink.onPause(_controller));
  }

  void _onResume() {
    _subscription.resume();
    _runCatching(() => _connectedSink.onResume(_controller));
  }
}

class _CombinedStreamSubscription<T, R> extends StreamSubscription<R> {
  final StreamSubscription<T>? _innerSubscription;
  final StreamSubscription<R> _outerSubscription;

  _CombinedStreamSubscription(this._innerSubscription, this._outerSubscription);

  @override
  Future<E> asFuture<E>([E? futureValue]) => _outerSubscription.asFuture();

  @override
  Future<void> cancel() {
    final innerCancel = _innerSubscription?.cancel(),
        outerCancel = _outerSubscription.cancel();

    return Future.wait<void>([
      if (innerCancel is Future) innerCancel,
      if (outerCancel is Future) outerCancel,
    ]);
  }

  @override
  bool get isPaused => _outerSubscription.isPaused;

  @override
  void onData(void Function(R data)? handleData) =>
      _outerSubscription.onData(handleData);

  @override
  void onDone(void Function()? handleDone) =>
      _outerSubscription.onDone(handleDone);

  @override
  void onError(Function? handleError) =>
      _outerSubscription.onError(handleError);

  @override
  void pause([Future<void>? resumeSignal]) {
    _innerSubscription?.pause(resumeSignal);
    _outerSubscription.pause(resumeSignal);
  }

  @override
  void resume() {
    _innerSubscription?.resume();
    _outerSubscription.resume();
  }
}
