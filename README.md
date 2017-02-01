# RxDart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)
[![Coverage Status](https://coveralls.io/repos/frankpepermans/rxdart/badge.svg?branch=master&service=github)](https://coveralls.io/github/frankpepermans/rxdart?branch=master)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/rxdart/Lobby.svg)](https://gitter.im/rxdart/Lobby)

## About
RxDart is a reactive functional programming library for Google Dart, based on [ReactiveX](http://reactivex.io/).  
Google Dart comes with a very decent [Streams](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html) API out-of-the-box; rather than attempting to provide an alternative to this API, RxDart adds functionality on top of it.

## How To Use RxDart
Use the method `observable()` to wrap a native Dart Stream.
```dart
var myObservable = observable(myStream);
```

### Example

##### Reading the Konami Code 

```dart
import 'package:rxdart/rxdart.dart';

void main() {

  // KONAMI CODE: UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A
  var codes = <int>[38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
  var result = querySelector('#result');
  var controller = new StreamController<KeyboardEvent>();
  var stream = observable(controller.stream);

  document.addEventListener('keyup', (event) => controller.add(event));

  stream
    .map((event) => event.keyCode ) // Get the key code
    .bufferWithCount(10, 1) // Get the last 10 keys
    .where((list) => _areTwoListsEqual(list, codes)) // Check for matching values
    .listen((_) => result.innerHtml = 'KONAMI!');
}

bool _areTwoListsEqual(List<int> a, List<int> b) {
  for (int i=0; i<10; i++) if (a[i] != b[i]) return false;
  
  return true;
}
```

## API Overview

RxDart's Observables extend the Stream class, meaning all methods defined [here](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html#instance-methods) exist on RxDart's Observables as well.
But on top of these, RxDart provides its own API:

### Instantiation

Generally speaking, creating a new Observable is done by calling a factory method on the Observable class.
But to better support Dart's strong mode, `combineLatest` and `zip` have been pulled apart into fixed-length constructors. 
These methods are supplied as static methods, since Dart's factory methods don't support generic types.

##### Available Factory Methods
- amb
- concat
- defer
- just
- merge
- periodic
- tween

###### Usage
```dart
var myObservable = new Observable.merge([myFirstStream, mySecondStream])
```

##### Available Static Methods
- combineLatest  
combineLatest2    
combineLatest3  
combineLatest4  
combineLatest5  
combineLatest6  
combineLatest7  
combineLatest8  
combineLatest9  
- zip  
zip2   
zip3   
zip4   
zip5   
zip6   
zip7   
zip8   
zip9   

##### Usage
```dart
var myObservable = Observable.combineLatest(
    myFirstStream, 
    mySecondStream, 
    (firstData, secondData) => print(firstData + ' ' + secondData));
```

### Transformations
    
##### Available Methods
- bufferWithCount  
- debounce  
- flatMapLatest  
- flatMap  
- groupBy  
- interval  
- max  
- min  
- pluck  
- repeat  
- retry  
- sample  
- scan  
- startWith  
- startWithMany  
- takeUntil  
- timeInterval  
- tap  
- throttle  
- windowWithCount
- withLatestFrom  

##### Usage
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
