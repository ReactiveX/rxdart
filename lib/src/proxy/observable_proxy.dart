@JS('Rx')
library rx.observable_proxy;

import 'dart:html';

import 'promise_proxy.dart';

import 'package:js/js.dart';

import 'scheduler_proxy.dart';

@JS()
class Observable {
  
  @JS()
  external Observable();
  
  @JS('just')
  external static Observable just(dynamic value);
  
  @JS('from')
  external static Observable from(List values);
  
  @JS('fromEvent')
  external static Observable fromEvent(Element element, String event);
  
  @JS('fromPromise')
  external static Observable fromPromise(Promise promise);
  
  @JS('interval')
  external static Observable interval(dynamic value, [Scheduler scheduler]);
  
  @JS('range')
  external static Observable range(int start, int count);
  
  @JS('timer')
  external static Observable timer(int interval);
  
  @JS('repeat')
  external static Observable repeat(dynamic value, [int repeatCount, Scheduler scheduler]);
  
  @JS('throw')
  external static Observable throwError(Error error, [Scheduler scheduler]);
  
  @JS("iterable")
  external List get iterable;
  
  /*@JS("mapper")
  external Mapper get mapper;*/
  
  @JS("scheduler")
  external Scheduler get scheduler;
  
  @JS('bufferWithCount')
  external bufferWithCount(int count, int skip);
  
  @JS('debounce')
  external debounce(dynamic value, [Scheduler scheduler]);
  
  @JS('delay')
  external delay(a, [b]);
  
  @JS('tap')
  external tap(dynamic handlerOrObserver, [void onError(error), void onCompleted()]);
  
  @JS('filter')
  external filter(dynamic predicate(dynamic value, int index, Observable target));
  
  @JS('flatMap')
  external flatMap(dynamic selector(dynamic value, int index, Observable target));
  
  @JS('flatMapLatest')
  external flatMapLatest(dynamic selector(dynamic value, int index, Observable target));
  
  @JS('map')
  external map(dynamic selector(dynamic value, int index, Observable target));
  
  @JS('partition')
  external partition(dynamic predicate(dynamic value, int index, Observable target));
  
  @JS('retry')
  external retry(int retryCount);
  
  @JS('retryWhen')
  external retryWhen(void onErrors(errors));
  
  @JS('take')
  external take(int amount, Scheduler scheduler);
  
  @JS('throttle')
  external throttle(dynamic value, [Scheduler scheduler]);
  
  @JS('timeInterval')
  external timeInterval(Scheduler scheduler);
  
  @JS('toArray')
  external toArray();
  
  @JS('windowWithCount')
  external windowWithCount(int count, int skip);
  
  @JS('subscribe')
  external subscribe(dynamic handlerOrObserver, [void onError(error), void onCompleted()]);
  
}