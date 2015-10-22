@JS('Rx')
library rx.subject_proxy;

import 'package:js/js.dart';

import 'observer_proxy.dart';
import 'observable_proxy.dart';

@JS()
class Subject extends Observer {
  
  @JS()
  external Subject();
  
  @JS('create')
  external static Subject create(Observer observer, Observable observable);
  
}