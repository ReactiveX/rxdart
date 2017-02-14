# RxDart

[![Build Status](https://api.travis-ci.org/ReactiveX/rxdart.svg)](https://travis-ci.org/ReactiveX/rxdart)
[![codecov](https://codecov.io/gh/ReactiveX/rxdart/branch/master/graph/badge.svg)](https://codecov.io/gh/ReactiveX/rxdart)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/ReactiveX/rxdart.svg)](https://gitter.im/ReactiveX/rxdart)

## About
RxDart is a reactive functional programming library for Google Dart, based on [ReactiveX](http://reactivex.io/).  
Google Dart comes with a very decent [Streams](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html) API out-of-the-box; rather than attempting to provide an alternative to this API, RxDart adds functionality on top of it.

## How To Use RxDart

### For Example: Reading the Konami Code 

```dart
void main() {
  const konamiKeyCodes = const <int>[
    KeyCode.UP,
    KeyCode.UP,
    KeyCode.DOWN,
    KeyCode.DOWN,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.B,
    KeyCode.A];

  final result = querySelector('#result');
  final keyUp = new Observable<KeyboardEvent>(document.onKeyUp);

  keyUp
    .map((event) => event.keyCode)
    .bufferWithCount(10, 1)
    .where((lastTenKeyCodes) => const IterableEquality<int>().equals(lastTenKeyCodes, konamiKeyCodes))
    .listen((_) => result.innerHtml = 'KONAMI!');
}
```

## API Overview

RxDart's Observables extend the Stream class.
This has two major implications:  
- All [methods defined on the Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html#instance-methods) exist on RxDart's Observables as well.
- All Observables can be passed to any API that expects a Dart Stream as an input.

### Instantiation

Generally speaking, creating a new Observable is either done by wrapping a Dart Stream using the top-level method `observable()`, or by calling a factory method on the Observable class.  
But to better support Dart's strong mode, `combineLatest` and `zip` have been pulled apart into fixed-length constructors. 
These methods are supplied as static methods, since Dart's factory methods don't support generic types.

##### Available Top-level Method
- observable

###### Usage
```dart
var myObservable = observable(myStream);
```

##### Available Factory Methods
- amb
- concat
- defer
- error
- just
- merge
- never
- periodic
- range (static)
- timer
- tween (static)

###### Usage
```dart
var myObservable = new Observable.merge([myFirstStream, mySecondStream]);
```

##### Available Static Methods
- combineLatest (combineLatest2, combineLatest3, combineLatest4, ..., combineLatest9)
- zip (zip2, zip3, zip4, ..., zip9)

###### Usage
```dart
var myObservable = Observable.combineLatest3(
    myFirstStream, 
    mySecondStream, 
    myThirdStream, 
    (firstData, secondData, thirdData) => print(firstData + ' ' + secondData + ' ' + thirdData));
```

### Transformations
    
##### Available Methods
- bufferWithCount
- call
- concatMap
- debounce
- dematerialize
- flatMapLatest
- flatMap
- groupBy
- interval  
- materialize
- max
- min
- pluck  
- repeat  
- retry  
- sample  
- scan  
- skipUntil
- startWith  
- startWithMany  
- takeUntil  
- timeInterval  
- timestamp
- tap
- throttle  
- windowWithCount
- withLatestFrom  

###### Usage
```Dart
var myObservable = observable(myStream)
    .bufferWithCount(5)
    .distinct()
```

### Objects

- Observable
- BehaviourSubject
- ReplaySubject

## Notable References
- [Documentation on the Dart Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html)
- [Tutorial on working with Streams in Dart](https://www.dartlang.org/tutorials/language/streams)
- [ReactiveX (Rx)](http://reactivex.io/)

## Changelog

Refer to the [Changelog](https://github.com/frankpepermans/rxdart/blob/master/CHANGELOG.md) to get all release notes.
