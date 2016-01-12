# rxdart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)
[![Coverage Status](https://coveralls.io/repos/frankpepermans/rxdart/badge.svg?branch=master&service=github)](https://coveralls.io/github/frankpepermans/rxdart?branch=master)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)

**Update**
This library no longer depends on RxJs and JS interop,
while that dependency made things easy, it also meant that rxdart would be a browser lib only.

Some notes:
- Observable is the main class, it extends Stream obviously
- Promote a stream to observable by wrapping it => rx.observable(myStream)
- That doesn't mean wrapping everywhere, ```dartnew rx.Observable.merge(<Stream>[a, b, c, ...]);``` is fine
- Subject is not ported, we already have StreamController for that

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