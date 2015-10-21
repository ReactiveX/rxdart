import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:rxdart/rxdart.dart' as Rx;

import 'package:js/js.dart';

final Function _ = allowInterop;

void main() {
  new Rx.Observable<int>.range(0, 100)
    .bufferWithCount(2)
    .debounce(const Duration(seconds: 1))
    .flatMapLatest((List<int> value) => new Rx.Observable<List<Map<String, int>>>.from([{'first': value.first, 'last': value[0]}]))
    .subscribe((x) => print(x));
  
  new Rx.Observable<MouseEvent>.fromEvent(querySelector('#sample_text_id'), 'click')
    .debounce(const Duration(seconds: 1))
    .subscribe((MouseEvent x) => print(x.target));
  
  new Rx.Observable<int>.range(0, 100)
    .flatMapLatest((int x) => new Rx.Observable.from([x * 3]))
    .partition((int x) => x % 2 == 0)
      ..first
        .bufferWithCount(2)
        .subscribe((List<int> i) => print('even: $i'))
      ..last
        .bufferWithCount(3)
        .subscribe((List<int> i) => print('odd: $i'));
  
  Rx.Observable o1 = new Rx.Observable<int>.range(0, 100);
  Rx.Observable o2 = new Rx.Observable<int>.range(100, 200);
  
  new Rx.Observable.combineLatest(o1, o2)
    .subscribe((List<int> i) => print('comb: $i'));
  
  Future<int> F = new Future<int>.value(10);
  
  new Rx.Observable<int>.fromFuture(F)
    .subscribe((int i) => print(i));
  
  final Rx.Subject<int> S = new Rx.Subject<int>();
  final Rx.Observer<int> O = new Rx.Observer.create(
    (int x) => print('from Subject: $x'),
    (error) => print(error),
    () => print('Subject completed')    
  );
  
  final Rx.Observer<int> O2 = new Rx.Observer<int>.fromNotifier((Rx.Notification<int> n) {
    switch (n.kind) {
      case Rx.Notification.NEXT :       print('Next: ${n.value}'); break;
      case Rx.Notification.ERROR :      print('Error: ${n.error}'); break;
      case Rx.Notification.COMPLETED :  print('Completed'); break;
    }
  });
  
  S.subscribeWith(O);
  S.subscribeWith(O2);
  
  S.onNext(10);
  
  S.onCompleted();
  
  S.dispose();
  
}
