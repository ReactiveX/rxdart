library rx.observable.stream_subscription;

import 'dart:async';

import 'package:rxdart/src/observable/stream.dart' show StreamObservable;

class ForwardingStreamSubscription<T> implements StreamSubscription<T> {

  final StreamObservable _parent;
  final StreamSubscription<T> _selfSubscription;

  ForwardingStreamSubscription(this._parent, this._selfSubscription);

  Future asFuture([var futureValue]) => _selfSubscription.asFuture(futureValue);

  Future cancel() {
    _parent?.subscription?.cancel();

    return _selfSubscription.cancel();
  }

  void onData(void handleData(T data)) => _selfSubscription.onData(handleData);

  void onDone(void handleDone()) => _selfSubscription.onDone(handleDone);

  void onError(Function handleError) => _selfSubscription.onError(handleError);

  void pause([Future resumeSignal]) => _selfSubscription.pause(resumeSignal);

  void resume() => _selfSubscription.resume();

  bool get isPaused => _selfSubscription.isPaused;
}