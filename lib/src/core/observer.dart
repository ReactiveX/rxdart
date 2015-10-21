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
  
}