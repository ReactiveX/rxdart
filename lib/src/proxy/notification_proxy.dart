@JS('Rx')
library rx.notification_proxy;

import 'package:js/js.dart';

@JS()
class Notification {
  
  @JS()
  external Notification();
  
  @JS('createOnNext')
  external static Notification createOnNext(dynamic value);
  
  @JS('createOnError')
  external static Notification createOnError(error);
  
  @JS('createOnCompleted')
  external static Notification createOnCompleted();
  
  @JS('error')
  external get error;
  
  @JS('kind')
  external get kind;
  
  @JS('value')
  external get value;
  
}