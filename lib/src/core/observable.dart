library rx.observable;

import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';

import '../proxy/promise_proxy.dart' as Core;
import '../proxy/observable_proxy.dart' as Rx;

class Observable<T> {
  
  final Rx.Observable _proxy;
  
  Observable(this._proxy);
  
  factory Observable.combineLatest(Observable o1, Observable o2) => new Observable<T>(Rx.Observable.combineLatest(o1._proxy, o2._proxy));
  
  factory Observable.from(List elements) => new Observable<T>(Rx.Observable.from(elements));
  
  factory Observable.fromEvent(Element element, String event) => new Observable<T>(Rx.Observable.fromEvent(element, event));
  
  factory Observable.fromFuture(Future future) {
    final Core.Promise promise = new Core.Promise(allowInterop((resolve, reject) {
      future.then((T result) {
        resolve(result);
      }, 
      onError: (error) {
        reject(error);
      });
    }));
    
    return new Observable<T>(Rx.Observable.fromPromise(promise));
  }
  
  factory Observable.range(int start, int count) => new Observable<T>(Rx.Observable.range(start, count));
  
  Observable<List> bufferWithCount(int count, [int skip]) => new Observable<List<T>>(_proxy.bufferWithCount(count, skip));
  
  Observable flatMap(Observable selector(T value)) => new Observable(_proxy.flatMap(allowInterop((T value, int index, Rx.Observable target) => selector(value)._proxy)));
  
  Observable flatMapLatest(Observable selector(T value)) => new Observable(_proxy.flatMapLatest(allowInterop((T value, int index, Rx.Observable target) => selector(value)._proxy)));
  
  Observable<T> debounce(Duration duration) => new Observable(_proxy.debounce(duration.inMilliseconds));
  
  Observable<T> debounceWithSelector(Observable selector(dynamic value)) => new Observable(_proxy.debounce(selector));
  
  List<Observable<T>> partition(bool predicate(T value)) {
    final List<Rx.Observable> partitions = _proxy.partition(allowInterop((T value, int index, Rx.Observable target) => predicate(value)));
    
    return <Observable<T>>[
      new Observable<T>(partitions.first), 
      new Observable<T>(partitions.last)
    ];
  }
  
  dynamic subscribe(void onListen(T value), {void onError(error), void onCompleted()}) {
    if (onError != null && onCompleted != null)
      return _proxy.subscribe(allowInterop(onListen), allowInterop(onError), allowInterop(onCompleted));
    
    if (onError != null)
      return _proxy.subscribe(allowInterop(onListen), allowInterop(onError));
    
    return _proxy.subscribe(allowInterop(onListen));
  }
  
}