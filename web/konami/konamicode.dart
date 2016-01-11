import 'dart:async';
import 'dart:html';

import 'package:rxdart/rx.dart' as rx;

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

  StreamController<KeyboardEvent> controller = new StreamController<KeyboardEvent>();
  rx.Observable<KeyboardEvent> stream = rx.observable(controller.stream);

  document.addEventListener('keyup', (KeyboardEvent event) => controller.add(event));

  stream
    .map((KeyboardEvent e) => e.keyCode )     // get the key code
    .bufferWithCount(10, 1)                   // get the last 10 keys
    .where((List<int> x) => _equal(x, codes)) // where we match
    .listen((_) => result.innerHtml = 'KONAMI!');
}

bool _equal(List<int> a, List<int> b) {
  for (int i=0; i<10; i++) if (a[i] != b[i]) return false; return true;
}
