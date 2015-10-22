part of rx.core;

class Scheduler {
  
  final Rx.Scheduler _proxy;
  
  Scheduler._internal(this._proxy);
  
  static Scheduler get asDefault => new Scheduler._internal(Rx.Scheduler.asDefault);
  
  static Scheduler get currentThread => new Scheduler._internal(Rx.Scheduler.currentThread);
  
  static Scheduler get immediate => new Scheduler._internal(Rx.Scheduler.immediate);
  
  Scheduler schedule(dynamic state, void action(Scheduler scheduler, dynamic state)) => new Scheduler._internal(_proxy.schedule(state, allowInterop((Rx.Scheduler scheduler, dynamic state) => action(new Scheduler._internal(scheduler), state))));
  
  Scheduler scheduleFuture(dynamic state, Duration duration, void action(Scheduler scheduler, dynamic state)) => new Scheduler._internal(_proxy.scheduleFuture(state, duration.inMilliseconds, allowInterop((Rx.Scheduler scheduler, dynamic state) => action(new Scheduler._internal(scheduler), state))));
  
  Scheduler scheduleFutureUntil(dynamic state, DateTime dateTime, void action(Scheduler scheduler, dynamic state)) => new Scheduler._internal(_proxy.scheduleFuture(state, dateTime, allowInterop((Rx.Scheduler scheduler, dynamic state) => action(new Scheduler._internal(scheduler), state))));
  
  Scheduler scheduleRecursive(dynamic state, void action(dynamic state, Function recurse)) => new Scheduler._internal(_proxy.scheduleRecursive(state, allowInterop(action)));
  
  Scheduler scheduleRecursiveFuture(dynamic state, Duration duration, void action(dynamic state, Function recurse)) => new Scheduler._internal(_proxy.scheduleRecursiveFuture(state, duration.inMilliseconds, allowInterop(action)));
    
  Scheduler scheduleRecursiveFutureUntil(dynamic state, DateTime dateTime, void action(dynamic state, Function recurse)) => new Scheduler._internal(_proxy.scheduleRecursiveFuture(state, dateTime, allowInterop(action)));
  
  Scheduler schedulePeriodic(dynamic state, Duration period, void action(dynamic state)) => new Scheduler._internal(_proxy.schedulePeriodic(state, period.inMilliseconds, allowInterop(action)));
}