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
    .partition((int x) => x % 2 == 0)
    ..first.subscribe((int i) => print('even: $i'))
    ..last.subscribe((int i) => print('odd: $i'));
  
  Future<int> F = new Future<int>.value(10);
  
  new Rx.Observable<int>.fromFuture(F)
    .subscribe((int i) => print(i));
  
}
