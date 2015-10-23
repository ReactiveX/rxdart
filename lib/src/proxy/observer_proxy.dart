@JS('Rx')
library rx.observer_proxy;

import 'package:js/js.dart';

import 'notification_proxy.dart';
import 'observable_proxy.dart';

@JS()
class Observer extends Observable {
  
  @JS()
  external Observer();
  
  @JS('create')
  external static Observer create(void onListen(dynamic value), void onError(error), void onCompleted());
  
  @JS('fromNotifier')
  external static Observer fromNotifier(void handler(Notification kind));
  
  @JS('onNext')
  external onNext(dynamic value);
  
  @JS('onError')
  external onError(error);
  
  @JS('onCompleted')
  external onCompleted();
  
  @JS('dispose')
  external dispose();
  
  @JS('asObserver')
  external asObserver();
  
}