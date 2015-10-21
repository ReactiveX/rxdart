import 'dart:html';

import 'package:rxdart/rxdart.dart' as Rx;

void main() {
  List<int> codes = <int>[
      38, // up
      38, // up
      40, // down
      40, // down
      37, // left
      39, // right
      37, // left
      39, // right
      66, // b
      65  // a
  ];
  Element result = querySelector('#result');

  new Rx.Observable<KeyboardEvent>.fromEvent(document.body, 'keyup')
      .map((e) => e.keyCode )           // get the key code
      .bufferWithCount(10, 1)           // get the last 10 keys
      .filter((x) => _equal(x, codes))  // where we match
      .subscribe((x) => result.innerHtml = 'KONAMI!');
}

bool _equal(List<int> a, List<int> b) {
  for (int i=0; i<10; i++) if (a[i] != b[i]) return false; return true;
}
