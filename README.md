# rxdart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)

This library uses the new Dart-Js interop available as of SDK 1.13.0

The RxJs library is wrapped and exposed via the Observable Dart class:

**Example:**

```dart
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
    .map((KeyboardEvent e) => e.keyCode )           // get the key code
    .bufferWithCount(10, 1)                         // get the last 10 keys
    .filter((List<int> x) => _equal(x, codes))      // where we match
    .subscribe((_) => result.innerHtml = 'KONAMI!');
```