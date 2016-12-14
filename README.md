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
- That doesn't mean wrapping everywhere, ```new rx.Observable.merge(<Stream>[a, b, c, ...]);``` is fine
- Subject is not ported, we already have StreamController for that

**Currently supported**

```dart
 // first wrap any stream
 Observable oStream = observable(myStream);
 
 // of course all exiting Stream opeartors (map, where, ...) are inherited, so they are not listed here
 
 oStream
    .bufferWithCount
    .debounce
    .flatMapLatest
    .flatMap
    .interval
    .max
    .min
    .pluck
    .repeat
    .retry
    .sample
    .scan
    .startWith
    .takeUntil
    .timeInterval
    .tap
    .throttle
    .windowWithCount
    
 // the following are contructors
 
 new Observable
    .combineLatest
    /*
     same as combineLatest,
     except instead of passing a predicate,
     you pass a Map<String, Stream>,
     the result will also be a Map, with the same keys as the above map,
     but the values will be the latest Stream values instead
     */
    .combineLatestMap
    .merge
    /*
     tween a value from a start value to an end value,
     over a given period of time,
     using one of 4 easing methods (linear, ease_in, ease_out, ease_in_out),
     and sample on a given interval (e.g. every 20 milliseconds)
     */
    .tween
    .zip
```

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