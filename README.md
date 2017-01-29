# rxdart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)
[![Coverage Status](https://coveralls.io/repos/frankpepermans/rxdart/badge.svg?branch=master&service=github)](https://coveralls.io/github/frankpepermans/rxdart?branch=master)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/rxdart/Lobby.svg)](https://gitter.im/rxdart/Lobby)

**Update**
This library no longer depends on RxJs and JS interop,
instead it now aims to provide a native Dart implementation of Rx,
allowing usage of this library in server side (or Flutter) projects as well.

**Currently supported**
```dart
 /// Use the observable method to wrap a Dart stream and add Rx operators to it
 Observable oStream = observable(myStream);
 
 /// Below operators are now available, next to the original Stream ones (map, where, ...)
 oStream
    .bufferWithCount
    .debounce
    .defaultIfEmpty
    .flatMapLatest
    .flatMap
    .groupBy
    .interval
    .max
    .min
    .ofType
    .pluck
    .repeat
    .retry
    .sample
    .scan
    .startWith
    .startWithMany
    .takeUntil
    .timeInterval
    .tap
    .throttle
    .windowWithCount
    .withLatestFrom

 /// the following are contructors
 new Observable
    .amb
    .combineLatest (deprecated - see below)
    .concat
    .concatEager
    .defer
    .just
    .merge
    .tween
    .zip (deprecated - see below)
    
 /// To better support strong mode, combineLatest and zip
 /// have now been pulled apart into fixed-length constructors.
 /// These methods are available as static methods, since class
 /// factory methods don't support generic method types.
 Observable
    .combineLatest2
    .combineLatest3
    .combineLatest4
    .combineLatest5
    .combineLatest6
    .combineLatest7
    .combineLatest8
    .combineLatest9
 
 Observable
    .zip2
    .zip3
    .zip4
    .zip5
    .zip6
    .zip7
    .zip8
    .zip9
    
 /// BehaviourSubject and ReplaySubject are available
 /// The default StreamController functions as a PublishSubject
 
 /// On listen, receive the last added event
 StreamController controllerA = new BehaviourSubject();
 /// On listen, receive all past events
 StreamController controllerB = new ReplaySubject();
```

**Example:**
```dart
void main() {
  var codes = <int>[
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
  var result = querySelector('#result');
  var controller = new StreamController<KeyboardEvent>();
  var stream = observable(controller.stream);

  document.addEventListener('keyup', (event) => controller.add(event));

  stream
    .map((event) => event.keyCode )           // get the key code
    .bufferWithCount(10, 1)                   // get the last 10 keys
    .where((list) => _areTwoListsEqual(list, codes))
    .listen((_) => result.innerHtml = 'KONAMI!');
}

bool _areTwoListsEqual(List<int> a, List<int> b) {
  for (int i=0; i<10; i++) if (a[i] != b[i]) return false;
  
  return true;
}
```
