part of rx.core;

class Notification<T> {
  
  static const String NEXT = 'N';
  static const String ERROR = 'E';
  static const String COMPLETED = 'C';
  
  final Rx.Notification _proxy;
    
  Notification._internal(this._proxy);
  
  factory Notification.createOnNext(T value) => new Notification<T>._internal(Rx.Notification.createOnNext(value));
  
  factory Notification.createOnError(error) => new Notification<T>._internal(Rx.Notification.createOnError(error));
  
  factory Notification.createOnCompleted() => new Notification<T>._internal(Rx.Notification.createOnCompleted());
  
  String get kind => _proxy.kind;
  
  dynamic get error => _proxy.error;
  
  T get value => _proxy.value;
  
}