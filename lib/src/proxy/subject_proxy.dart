@Js('Rx')
library rx.subject_proxy;

import 'package:js/js.dart';

import 'observer_proxy.dart';
import 'observable_proxy.dart';

@Js()
class Subject extends Observer {
  
  @Js()
  external Subject();
  
  @Js('create')
  external static Subject create(Observer observer, Observable observable);
  
}