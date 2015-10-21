@Js('Rx')
library rx.observer_proxy;

import 'package:js/js.dart';

import 'observable_proxy.dart';

@Js()
class Observer extends Observable {
  
  @Js()
  external Observer();
  
  @Js('onNext')
  external onNext(dynamic value);
  
  @Js('onCompleted')
  external onCompleted();
  
  @Js('dispose')
  external dispose();
  
}