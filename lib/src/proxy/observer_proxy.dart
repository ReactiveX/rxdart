@Js('Rx')
library rx.observer_proxy;

import 'package:js/js.dart';

import 'notification_proxy.dart';
import 'observable_proxy.dart';

@Js()
class Observer extends Observable {
  
  @Js()
  external Observer();
  
  @Js('create')
  external static Observer create(void onListen(dynamic value), void onError(error), void onCompleted());
  
  @Js('fromNotifier')
  external static Observer fromNotifier(void handler(Notification kind));
  
  @Js('onNext')
  external onNext(dynamic value);
  
  @Js('onCompleted')
  external onCompleted();
  
  @Js('dispose')
  external dispose();
  
}