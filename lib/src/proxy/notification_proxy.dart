@Js('Rx')
library rx.notification_proxy;

import 'package:js/js.dart';

@Js()
class Notification {
  
  @Js()
  external Notification();
  
  @Js('createOnNext')
  external static Notification createOnNext(dynamic value);
  
  @Js('createOnError')
  external static Notification createOnError(error);
  
  @Js('createOnCompleted')
  external static Notification createOnCompleted();
  
  @Js('error')
  external get error;
  
  @Js('kind')
  external get kind;
  
  @Js('value')
  external get value;
  
}