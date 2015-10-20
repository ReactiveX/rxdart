library rx.observable;

import 'dart:html';

import 'package:js/js.dart';

import '../proxy/observable_proxy.dart' as Rx;

class Observable<T> {
  
  final Rx.Observable _proxy;
  
  Observable(this._proxy);
  
  static Observable from(List elements) => new Observable(Rx.Observable.from(elements));
  
  static Observable<Event> fromEvent(Element element, String event) => new Observable(Rx.Observable.fromEvent(element, event));
  
  static Observable range(int start, int count) => new Observable(Rx.Observable.range(start, count));
  
  Observable<List> bufferWithCount(int count, [int skip]) {
    return new Observable<List>(_proxy.bufferWithCount(count, skip));
  }
  
  Observable flatMap(Observable selector(T value, int index)) {
    return new Observable(_proxy.flatMap(allowInterop((T value, int index, Rx.Observable target) => selector(value, index)._proxy)));
  }
  
  Observable flatMapLatest(Observable selector(T value, int index)) {
    return new Observable(_proxy.flatMapLatest(allowInterop((T value, int index, Rx.Observable target) => selector(value, index)._proxy)));
  }
  
  Observable<T> debounce(Duration duration) {
    return new Observable(_proxy.debounce(duration.inMilliseconds));
  }
  
  Observable<T> debounceWithSelector(Observable selector(dynamic value)) {
    return new Observable(_proxy.debounce(selector));
  }
  
  dynamic subscribe(void onListen(T value), [void onError(error), void onCompleted()]) {
    if (onError != null && onCompleted != null)
      return _proxy.subscribe(allowInterop(onListen), allowInterop(onError), allowInterop(onCompleted));
    
    if (onError != null)
      return _proxy.subscribe(allowInterop(onListen), allowInterop(onError));
    
    return _proxy.subscribe(allowInterop(onListen));
  }
  
}