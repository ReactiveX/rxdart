# rxdart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)
[![Coverage Status](https://coveralls.io/repos/frankpepermans/rxdart/badge.svg?branch=master&service=github)](https://coveralls.io/github/frankpepermans/rxdart?branch=master)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)

This library uses the new Dart-Js interop available as of SDK 1.13.0

The RxJs library is wrapped and exposed via the Observable Dart class:

**Example:**

```dart
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
```