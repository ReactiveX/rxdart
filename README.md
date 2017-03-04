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

### Objects

- [Observable](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable-class.html)
- [BehaviourSubject](https://www.dartdocs.org/documentation/rxdart/latest/rx_subjects/BehaviourSubject-class.html)
- [ReplaySubject](https://www.dartdocs.org/documentation/rxdart/latest/rx_subjects/ReplaySubject-class.html)

### Observable

RxDart's Observables extend the Stream class.
This has two major implications:  
- All [methods defined on the Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html#instance-methods) exist on RxDart's Observables as well.
- All Observables can be passed to any API that expects a Dart Stream as an input.
- Additional important distinctions are documented as part of the [Observable class](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable-class.html)

##### Notes

  * The Observable class is a simple wrapper for `Stream` and `StreamTransformer` classes. All underlying implementations can be used free of the Observable wrapper, and are exposed in their own libraries. They are linked to below.
  * The following sections link to DartDoc. While DartDoc is a bit scary looking at first, the documentation is up-to-date, readable, and contains examples. Furthermore, this documentation lives within the code, which means it can be easily read from within your favorite editor. 

### Instantiation

Generally speaking, creating a new Observable is either done by wrapping a Dart Stream using the top-level constructor `new Observable()`, or by calling a factory method on the Observable class.
But to better support Dart's strong mode, `combineLatest` and `zip` have been pulled apart into fixed-length constructors. 
These methods are supplied as static methods, since Dart's factory methods don't support generic types.

##### Usage
```dart
var myObservable = new Observable(myStream);
```

#### Available Factory Methods
- [amb](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.amb.html) / [AmbStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/AmbStream-class.html)
- [concat](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.concat.html) / [ConcatStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/ConcatStream-class.html)
- [concatEager](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.concat.html) / [ConcatEagerStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/ConcatEagerStream-class.html)
- [defer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.defer.html) / [DeferStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/DeferStream-class.html)
- [error](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.error.html) / [ErrorStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/ErrorStream-class.html)
- [just](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.just.html)
- [merge](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.merge.html) / [MergeStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/MergeStream-class.html)
- [never](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.never.html) / [NeverStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/NeverStream-class.html)
- [periodic](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.periodic.html)
- [retry](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.retry.html) / [RetryStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/RetryStream-class.html)
- [timer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.timer.html) / [TimerStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/TimerStream-class.html)

###### Usage
```dart
var myObservable = new Observable.merge([myFirstStream, mySecondStream]);
```

##### Available Static Methods
- [combineLatest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/combineLatest2.html) / [CombineLatestStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/CombineLatestStream-class.html) (combineLatest2, combineLatest... combineLatest9) 
- [range](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/range.html) / [RangeStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/RangeStream-class.html)
- [tween](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/tween.html) / [TweenStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/TweenStream-class.html)
- [zip](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/zip2.html) / [ZipStream](https://www.dartdocs.org/documentation/rxdart/latest/rx_streams/ZipStream-class.html) (zip2, zip3, zip4, ..., zip9)

###### Usage
```dart
var myObservable = Observable.combineLatest3(
    myFirstStream, 
    mySecondStream, 
    myThirdStream, 
    (firstData, secondData, thirdData) => print("$firstData $secondData $thirdData"));
```

### Transformations
    
##### Available Methods
- [bufferWithCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/bufferWithCount.html) / [BufferWithCountStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/BufferWithCountStreamTransformer-class.html)
- [call](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/call.html) / [CallStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/CallStreamTransformer-class.html)
- [concatMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/concatMap.html) / [ConcatMapStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/ConcatMapStreamTransformer-class.html)
- [concatWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/concatWith.html)
- [debounce](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/debounce.html) / [DebounceStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/DebounceStreamTransformer-class.html)
- [dematerialize](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/dematerialize.html) / [DematerializeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/DematerializeStreamTransformer-class.html)
- [flatMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/flatMap.html) / [FlatMapStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/FlatMapStreamTransformer-class.html)
- [flatMapLatest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/flatMapLatest.html) / [FlatMapLatestStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/FlatMapLatestStreamTransformer-class.html)
- [groupBy](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/groupBy.html) / [GroupByStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/GroupByStreamTransformer-class.html)
- [interval](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/interval.html) / [IntervalStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/IntervalStreamTransformer-class.html)
- [materialize](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/materialize.html) / [MaterializeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/MaterializeStreamTransformer-class.html)
- [mergeWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/mergeWith.html)
- [max](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/max.html) / [MaxStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/MaxStreamTransformer-class.html)
- [min](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/min.html) / [MinStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/MinStreamTransformer-class.html)
- [repeat](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/repeat.html) / [RepeatStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/RepeatStreamTransformer-class.html)
- [sample](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/sample.html) / [SampleStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/SampleStreamTransformer-class.html)
- [scan](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/scan.html) / [ScanStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/ScanStreamTransformer-class.html)
- [skipUntil](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/skipUntil.html) / [SkipUntilStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/SkipUntilStreamTransformer-class.html)
- [startWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/startWith.html) / [StartWithStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/StartWithStreamTransformer-class.html)
- [startWithMany](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/startWithMany.html) / [StartWithManyStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/StartWithManyStreamTransformer-class.html) 
- [takeUntil](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/takeUntil.html) / [TakeUntilStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/TakeUntilStreamTransformer-class.html)
- [timeInterval](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/timeInterval.html) / [TimeIntervalStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/TimeIntervalStreamTransformer-class.html)
- [timestamp](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/timestamp.html) / [TimestampStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/TimestampStreamTransformer-class.html)
- [throttle](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/throttle.html) / [ThrottleStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/ThrottleStreamTransformer-class.html)
- [windowWithCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/windowWithCount.html) / [WindowWithCountStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/WindowWithCountStreamTransformer-class.html)
- [withLatestFrom](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/withLatestFrom.html) / [WithLatestFromStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/WithLatestFromStreamTransformer-class.html)
- [zipWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/zipWith.html)

A full list of all methods and properties including those provided by the Dart Stream API (such as `first`, `asyncMap`, etc), can be seen by examining the [DartDocs](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable-class.html#instance-methods)

###### Usage
```Dart
var myObservable = new Observable(myStream)
    .bufferWithCount(5)
    .distinct();
```

## Examples

Web and command-line examples can be found in the `example` folder.

### Web Examples
 
In order to run the web examples, please follow these steps:

  1. Clone this repo and enter the directory
  2. Run `pub get`
  3. Run `pub serve example/web`
  4. Navigate to [http://localhost:8080](http://localhost:8080) in your browser

### Command Line Examples

In order to run the command line example, please follow these steps:

  1. Clone this repo and enter the directory
  2. Run `pub get`
  3. Run `dart example/bin/fibonacci.dart 10`
  
### Flutter Example
  
#### Install Flutter

In order to run the flutter example, you must have Flutter installed. For installation instructions, view the online
[documentation](http://flutter.io/).

#### Run the app

  1. Open up an Android Emulator, the iOS Simulator, or connect an appropriate mobile device for debugging.
  2. Open up a terminal
  3. `cd` into the `example/flutter/github_search` directory
  4. Run `flutter doctor` to ensure you have all Flutter dependencies working.
  5. Run `flutter packages get`
  6. Run `flutter run`

## Notable References
- [Documentation on the Dart Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html)
- [Tutorial on working with Streams in Dart](https://www.dartlang.org/tutorials/language/streams)
- [ReactiveX (Rx)](http://reactivex.io/)

## Changelog

Refer to the [Changelog](https://github.com/frankpepermans/rxdart/blob/master/CHANGELOG.md) to get all release notes.
