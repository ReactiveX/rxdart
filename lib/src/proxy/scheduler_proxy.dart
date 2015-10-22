@JS('Rx')
library rx.scheduler_proxy;

import 'package:js/js.dart';

import 'notification_proxy.dart';

@JS()
class Scheduler {
  
  @JS()
  external Scheduler();
  
  @JS('default')
  external static Scheduler get asDefault;
  
  @JS('immediate')
  external static Scheduler get immediate;
  
  @JS('currentThread')
  external static Scheduler get currentThread;
  
  @JS('schedule')
  external schedule(dynamic state, void action(Scheduler, state));
  
  @JS('scheduleFuture')
  external scheduleFuture(dynamic state, dueTime, void action(Scheduler scheduler, dynamic state));
  
  @JS('scheduleRecursive')
  external scheduleRecursive(dynamic state, void action(dynamic state, Function recurse));
  
  @JS('scheduleRecursiveFuture')
  external scheduleRecursiveFuture(dynamic state, dueTime, void action(dynamic state, Function recurse));
  
  @JS('schedulePeriodic')
  external schedulePeriodic(dynamic state, dueTime, void action(dynamic state));
  
}