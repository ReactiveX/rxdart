part of rx.core;

class Observer<T> extends Observable<T> {
  
  Rx.Observer get _proxy => super._proxy as Rx.Observer;
  
  Observer() : super._internal(new Rx.Observer());
  
  Observer._internal(Rx.Observer proxy) : super._internal(proxy);
  
  void onNext(T value) => _proxy.onNext(value);
  
  void onCompleted() => _proxy.onCompleted();
  
  void dispose() => _proxy.dispose();
  
}