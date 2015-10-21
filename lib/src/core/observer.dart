part of rx.core;

abstract class _ObserverMixin<T> {
  
  Rx.Observer get _proxy;
  
  void onNext(T value) => _proxy.onNext(value);
    
  void onCompleted() => _proxy.onCompleted();
  
  void dispose() => _proxy.dispose();
  
}

class Observer<T> extends Object with _ObserverMixin<T> {
  
  final Rx.Observer _proxy;
    
  Observer._internal(this._proxy);
  
  factory Observer.create(void onListen(T value), void onError(error), void onCompleted()) => new Observer<T>._internal(Rx.Observer.create(allowInterop(onListen), allowInterop(onError), allowInterop(onCompleted)));
  
  factory Observer.fromNotifier(handler(Notification<T> kind)) => new Observer<T>._internal(Rx.Observer.fromNotifier(allowInterop((v) {
    switch (v['kind']) {
      case Notification.NEXT: handler(new Notification.createOnNext(v['value'])); return;
      case Notification.ERROR: handler(new Notification.createOnError(v['error'])); return;
      case Notification.COMPLETED: handler(new Notification.createOnCompleted()); return;
    }
  })));
  
}