library rx.observable.stream_subscription;

import 'dart:async';

import 'package:rxdart/src/observable/stream.dart' show StreamObservable;

class ForwardingStreamSubscription<T> implements StreamSubscription<T> {

  final StreamSubscription<T> _subscription;
  final StreamObservable<T> _stream;

  ForwardingStreamSubscription(this._subscription, this._stream);

  Future asFuture([var futureValue]) => _subscription.asFuture(futureValue);

  Future cancel() {
    _stream.cancelSubscription(_subscription);

    return _subscription.cancel();
  }

  void onData(void handleData(T data)) => _subscription.onData(handleData);

  void onDone(void handleDone()) => _subscription.onDone(handleDone);

  void onError(Function handleError) => _subscription.onError(handleError);

  void pause([Future resumeSignal]) => _subscription.pause(resumeSignal);

  void resume() => _subscription.resume();

  bool get isPaused => _subscription.isPaused;
}