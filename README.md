# RxDart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)
[![Coverage Status](https://coveralls.io/repos/frankpepermans/rxdart/badge.svg?branch=master&service=github)](https://coveralls.io/github/frankpepermans/rxdart?branch=master)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/rxdart/Lobby.svg)](https://gitter.im/rxdart/Lobby)

## About
RxDart aims to provide an implementation of [ReactiveX](http://reactivex.io/) for the Dart language.  
Dart comes with a very decent [Stream](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html) API out-of-the-box.  
This library is built on top of it as an enhancement.

## How To Use RxDart
Use the method `observable()` to wrap a native Dart Stream.
```dart
Observable oStream = observable(myStream);
```

## Supported Methods

RxDart's Observables extend the Stream class, meaning all methods defined [here](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html#instance-methods) can be used on Observables as well.

On top of this, RxDart provides a list of its own API:

### Factory Constructors
- amb()
- combineLatest() (deprecated - see below)
- concat()
- defer()
- just()
- merge()
- tween()
- zip() (deprecated - see below)

### Methods and Operators
    
- bufferWithCount()
- combineTwoLatest()
- combineThreeLatest()
- combineFourLatest()
- combineFiveLatest()
- combineSixLatest()
- combineSevenLatest()
- combineEightLatest()
- combineNineLatest()
- debounce()
- flatMapLatest()
- flatMap()
- groupBy()
- interval()
- max()
- min()
- pluck()
- repeat()
- retry()
- sample()
- scan()
- startWith()
- startWithMany()
- takeUntil()
- timeInterval()
- tap()
- throttle()
- windowWithCount()
- withLatestFrom()
- zipTwo()
- zipThree()
- zipFour()
- zipFive()
- zipSix()
- zipSeven()
- zipEight()
- zipNine()

### Objects

- Observable
- BehaviourSubject
- ReplaySubject

## Notable References
- [Documentation on the Dart Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html)
- [Tutorial on working with Streams in Dart](https://www.dartlang.org/tutorials/language/streams)
- [ReactiveX (Rx)](http://reactivex.io/)

**Currently supported**
```dart
 /// Use the observable method to wrap a Dart stream and add Rx operators to it
 Observable oStream = observable(myStream);
 

    
 /// To better support strong mode, combineLatest and zip
 /// have now been pulled apart into fixed-length constructors.
 /// These methods are available as static methods, since class
 /// factory methods don't support generic method types.
    
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
  var stream = rx.observable(controller.stream);

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
