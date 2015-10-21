part of rx.core;

class Subject<T> extends Observer<T> {
  
  Rx.Subject get _proxy => super._proxy as Rx.Subject;
  
  Subject() : super._internal(new Rx.Subject());
  
  Subject._internal(Rx.Subject proxy) : super._internal(proxy);
  
  factory Subject.create(Observer observer, Observable observable) => new Subject<T>._internal(Rx.Subject.create(observer._proxy, observable._proxy));
  
}