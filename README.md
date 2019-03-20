# RxDart

[![Build Status](https://travis-ci.org/ReactiveX/rxdart.svg?branch=master)](https://travis-ci.org/ReactiveX/rxdart)
[![codecov](https://codecov.io/gh/ReactiveX/rxdart/branch/master/graph/badge.svg)](https://codecov.io/gh/ReactiveX/rxdart)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/ReactiveX/rxdart.svg)](https://gitter.im/ReactiveX/rxdart)

## About
RxDart is a reactive functional programming library for Google Dart, based on [ReactiveX](http://reactivex.io/).  
Google Dart comes with a very decent [Streams](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html) API out-of-the-box; rather than attempting to provide an alternative to this API, RxDart adds functionality on top of it.

## Version
Dart 1.0 is supported until release 0.15.x,
version 0.16.x is no longer backwards compatible and requires the Dart SDK 2.0

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
    .bufferCount(10, 1)
    .where((lastTenKeyCodes) => const IterableEquality<int>().equals(lastTenKeyCodes, konamiKeyCodes))
    .listen((_) => result.innerHtml = 'KONAMI!');
}
```

## API Overview

### Objects

- [Observable](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable-class.html)
- [PublishSubject](https://www.dartdocs.org/documentation/rxdart/latest/rx/PublishSubject-class.html)
- [BehaviorSubject](https://www.dartdocs.org/documentation/rxdart/latest/rx/BehaviorSubject-class.html)
- [ReplaySubject](https://www.dartdocs.org/documentation/rxdart/latest/rx/ReplaySubject-class.html)

### Observable

RxDart's Observables extends the Stream class. This has two major implications:  
- All [methods defined on the Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html#instance-methods) exist on RxDart's Observables as well.
- All Observables can be passed to any API that expects a Dart Stream as an input.
- Additional important distinctions are documented as part of the [Observable class](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable-class.html)

Finally, the Observable class & operators are simple wrappers around `Stream` and `StreamTransformer` classes. All underlying implementations can be used free of the Observable class, and are exposed in their own libraries. They are linked to below.

### Instantiation

Generally speaking, creating a new Observable is either done by wrapping a Dart Stream using the top-level constructor `new Observable()`, or by calling a factory method on the Observable class.
But to better support Dart's strong mode, `combineLatest` and `zip` have been pulled apart into fixed-length constructors. 
These methods are supplied as static methods, since Dart's factory methods don't support generic types.

###### Usage
```dart
var myObservable = new Observable(myStream);
```

#### Available Factory Methods
- [concat](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.concat.html) / [ConcatStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ConcatStream-class.html)
- [concatEager](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.concat.html) / [ConcatEagerStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ConcatEagerStream-class.html)
- [defer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.defer.html) / [DeferStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/DeferStream-class.html)
- [error](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.error.html) / [ErrorStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ErrorStream-class.html)
- [just](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.just.html)
- [merge](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.merge.html) / [MergeStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/MergeStream-class.html)
- [never](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.never.html) / [NeverStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/NeverStream-class.html)
- [periodic](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.periodic.html)
- [race](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.race.html) / [RaceStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RaceStream-class.html)
- [repeat](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.repeat.html) / [RepeatStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RepeatStream-class.html)
- [retry](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.retry.html) / [RetryStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RetryStream-class.html)
- [retryWhen](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.retryWhen.html) / [RetryWhenStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RetryWhenStream-class.html)
- [sequenceEqual](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.sequenceEqual.html) / [SequenceEqualStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/SequenceEqualStream-class.html)
- [switchLatest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.switchLatest.html) / [SwitchLatestStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/SwitchLatestStream-class.html)
- [timer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.timer.html) / [TimerStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/TimerStream-class.html)

###### Usage
```dart
var myObservable = new Observable.merge([myFirstStream, mySecondStream]);
```

##### Available Static Methods
- [combineLatest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/combineLatest2.html) / [CombineLatestStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/CombineLatestStream-class.html) (combineLatest2, combineLatest... combineLatest9) 
- [forkJoin](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/forkJoin2.html) / [ForkJoinStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ForkJoinStream-class.html) (forkJoin2, forkJoin... forkJoin9) 
- [range](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/range.html) / [RangeStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RangeStream-class.html)
- [tween](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/tween.html) / [TweenStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/TweenStream-class.html)
- [zip](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/zip2.html) / [ZipStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ZipStream-class.html) (zip2, zip3, zip4, ..., zip9)

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
- [buffer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/buffer.html) / [BufferStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/BufferStreamTransformer-class.html)
- [bufferCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/bufferCount.html) / [BufferStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/BufferStreamTransformer-class.html) / [onCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/onCount.html)
- [bufferTest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/bufferTest.html) / [BufferStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/BufferStreamTransformer-class.html) / [onTest](https://www.dartdocs.org/documentation/rxdart/latest/rx/onTest.html)
- [bufferTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/bufferTime.html) / [BufferStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/BufferStreamTransformer-class.html) / [onTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/onTime.html)
- [concatMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/concatMap.html) (alias for `asyncExpand`)
- [concatWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/concatWith.html)
- [debounce](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/debounce.html) / [DebounceStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DebounceStreamTransformer-class.html)
- [debounceTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/debounceTime.html) / [DebounceStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DebounceStreamTransformer-class.html)
- [delay](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/delay.html) / [DelayStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DelayStreamTransformer-class.html)
- [dematerialize](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/dematerialize.html) / [DematerializeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DematerializeStreamTransformer-class.html)
- [distinctUnique](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/distinctUnique.html) / [DistinctUniqueStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DistinctUniqueStreamTransformer-class.html)
- [doOnCancel](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnCancel.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [doOnData](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnData.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [doOnDone](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnDone.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [doOnEach](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnEach.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [doOnError](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnError.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [doOnListen](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnListen.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [doOnPause](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnPause.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [doOnResume](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnResume.html) / [DoStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/DoStreamTransformer-class.html)
- [exhaustMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/exhaustMap.html) / [ExhaustMapStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/ExhaustMapStreamTransformer-class.html)
- [flatMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/flatMap.html) / [FlatMapStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/FlatMapStreamTransformer-class.html)
- [flatMapIterable](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/flatMapIterable.html)
- [groupBy](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/groupBy.html) / [GroupByStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/GroupByStreamTransformer-class.html)
- [interval](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/interval.html) / [IntervalStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/IntervalStreamTransformer-class.html)
- [mapTo](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/mapTo.html) / [MapToStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/MapToStreamTransformer-class.html)
- [materialize](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/materialize.html) / [MaterializeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/MaterializeStreamTransformer-class.html)
- [mergeWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/mergeWith.html)
- [max](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/max.html) / [StreamMaxFuture](https://www.dartdocs.org/documentation/rxdart/latest/rx/StreamMaxFuture-class.html)
- [min](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/min.html) / [StreamMinFuture](https://www.dartdocs.org/documentation/rxdart/latest/rx/StreamMinFuture-class.html)
- [onErrorResume](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorResume.html) / [OnErrorResumeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/OnErrorResumeStreamTransformer-class.html)
- [onErrorResumeNext](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorResumeNext.html) / [OnErrorResumeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/OnErrorResumeStreamTransformer-class.html)
- [onErrorReturn](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorReturn.html) / [OnErrorResumeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/OnErrorResumeStreamTransformer-class.html)
- [onErrorReturnWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorReturnWith.html) / [OnErrorResumeStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/OnErrorResumeStreamTransformer-class.html)
- [sample](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/sample.html) / [SampleStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/SampleStreamTransformer-class.html)
- [sampleTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/sampleTime.html) / [SampleStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/SampleStreamTransformer-class.html)
- [scan](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/scan.html) / [ScanStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/ScanStreamTransformer-class.html)
- [skipUntil](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/skipUntil.html) / [SkipUntilStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/SkipUntilStreamTransformer-class.html)
- [startWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/startWith.html) / [StartWithStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/StartWithStreamTransformer-class.html)
- [startWithMany](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/startWithMany.html) / [StartWithManyStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/StartWithManyStreamTransformer-class.html) 
- [switchMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/switchMap.html) / [SwitchMapStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx_transformers/SwitchMapStreamTransformer-class.html)
- [takeUntil](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/takeUntil.html) / [TakeUntilStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/TakeUntilStreamTransformer-class.html)
- [timeInterval](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/timeInterval.html) / [TimeIntervalStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/TimeIntervalStreamTransformer-class.html)
- [timestamp](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/timestamp.html) / [TimestampStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/TimestampStreamTransformer-class.html)
- [throttle](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/throttle.html) / [ThrottleStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/ThrottleStreamTransformer-class.html)
- [throttleTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/throttleTime.html) / [ThrottleStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/ThrottleStreamTransformer-class.html)
- [window](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/window.html) / [WindowStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/WindowStreamTransformer-class.html)
- [windowCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/windowCount.html) / [WindowStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/BufferStreamTransformer-class.html) / [onCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/onCount.html)
- [windowTest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/windowTest.html) / [WindowStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/BufferStreamTransformer-class.html) / [onTest](https://www.dartdocs.org/documentation/rxdart/latest/rx/onTest.html)
- [windowTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/windowTime.html) / [WindowStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/BufferStreamTransformer-class.html) / [onTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/onTime.html)
- [withLatestFrom](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/withLatestFrom.html) / [WithLatestFromStreamTransformer](https://www.dartdocs.org/documentation/rxdart/latest/rx/WithLatestFromStreamTransformer-class.html)
- [zipWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/zipWith.html)

A full list of all methods and properties including those provided by the Dart Stream API (such as `first`, `asyncMap`, etc), can be seen by examining the [DartDocs](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable-class.html#instance-methods)

###### Usage
```Dart
var myObservable = new Observable(myStream)
    .bufferCount(5)
    .distinct();
```

## Examples

Web and command-line examples can be found in the `example` folder.

### Web Examples
 
In order to run the web examples, please follow these steps:

  1. Clone this repo and enter the directory
  2. Run `pub get`
  3. Run `pub run build_runner serve example`
  4. Navigate to [http://localhost:8080/web/](http://localhost:8080/web/) in your browser

### Command Line Examples

In order to run the command line example, please follow these steps:

  1. Clone this repo and enter the directory
  2. Run `pub get`
  3. Run `dart example/example.dart 10`
  
### Flutter Example
  
#### Install Flutter

In order to run the flutter example, you must have Flutter installed. For installation instructions, view the online
[documentation](https://flutter.io/).

#### Run the app

  1. Open up an Android Emulator, the iOS Simulator, or connect an appropriate mobile device for debugging.
  2. Open up a terminal
  3. `cd` into the `example/flutter/github_search` directory
  4. Run `flutter doctor` to ensure you have all Flutter dependencies working.
  5. Run `flutter packages get`
  6. Run `flutter run`

## Notable References
- [Documentation on the Dart Stream class](https://api.dartlang.org/stable/2.0.0/dart-async/Stream-class.html)
- [Tutorial on working with Streams in Dart](https://www.dartlang.org/tutorials/language/streams)
- [ReactiveX (Rx)](http://reactivex.io/)

## Changelog

Refer to the [Changelog](https://github.com/frankpepermans/rxdart/blob/master/CHANGELOG.md) to get all release notes.
