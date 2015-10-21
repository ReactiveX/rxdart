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
  
  factory Observer.create(void onListen(T value), void onError(error), void onCompleted()) => new Observer._internal(Rx.Observer.create(allowInterop(onListen), allowInterop(onError), allowInterop(onCompleted)));
  
}