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

On top of this, RxDart provides its own API:

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
