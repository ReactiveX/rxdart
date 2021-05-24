import 'dart:async';

class OnSubscriptionTriggerableStream<T> extends Stream<T> {
  final Stream<T> inner;
  final void Function() onSubscribe;

  OnSubscriptionTriggerableStream(this.inner, this.onSubscribe);

  @override
  bool get isBroadcast => inner.isBroadcast;

  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    onSubscribe();
    return inner.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
