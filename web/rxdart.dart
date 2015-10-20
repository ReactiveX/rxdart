import 'dart:html';
import 'dart:js';

import 'package:rxdart/rxdart.dart' as Rx;

import 'package:js/js.dart';

final Function _ = allowInterop;

void main() {
  Rx.Observable<int> O = Rx.Observable.range(0, 100);
  
      O
      .bufferWithCount(2)
      //.debounce(const Duration(seconds: 1))
      .flatMapLatest((value, index) => Rx.Observable.from([{'first': value.first, 'last': value.last, 'index': index}]))
      .subscribe((List x) => print(x));
  
  Rx.Observable.fromEvent(querySelector('#sample_text_id'), 'click')
    .debounce(const Duration(seconds: 1))
    .subscribe((x) => print(x.target));
  
}
