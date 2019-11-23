# RxDart

[![Build Status](https://travis-ci.org/ReactiveX/rxdart.svg?branch=master)](https://travis-ci.org/ReactiveX/rxdart)
[![codecov](https://codecov.io/gh/ReactiveX/rxdart/branch/master/graph/badge.svg)](https://codecov.io/gh/ReactiveX/rxdart)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/ReactiveX/rxdart.svg)](https://gitter.im/ReactiveX/rxdart)

## About

RxDart is a library for working with Streams of data.

Dart comes with a very decent [Streams](https://api.dart.dev/stable/dart-async/Stream-class.html) API out-of-the-box; rather than attempting to provide an alternative to this API, RxDart adds functionality from the reactive extensions specification on top of it. 

If you are familiar with Observables from other languages, please see [the Rx Observables vs Dart Streams comparison chart](#rx-observables-vs-dart-streams) for notable distinctions between the two.

## How To Use RxDart

### For Example: Reading the Konami Code 

```dart
import 'package:rxdart/rxdart.dart';

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
    KeyCode.A,
  ];
  final result = querySelector('#result');

  document.onKeyUp
    .map((event) => event.keyCode)
    .bufferCount(10, 1) // An extension method provided by rxdart
    .where((lastTenKeyCodes) => const IterableEquality<int>().equals(lastTenKeyCodes, konamiKeyCodes))
    .listen((_) => result.innerHtml = 'KONAMI!');
}
```

## API Overview

RxDart adds functionality to Dart Streams in two ways:

  * [Stream Classes](#stream-classes) - create Streams with specific capabilities, such as combining or merging many Streams together.
  * [Extension Methods](#extension-methods) - transform a source Stream into a new Stream with different capabilities, such as throttling events. 

### Stream Classes

The Stream class provides different ways to create a Stream: `Stream.fromIterable` or `Stream.periodic`, for example. RxDart provides additional Stream classes for a variety of tasks, such as combining or merging Streams together!

You can construct the Streams provided by RxDart in two ways. The following examples are equivalent in terms of functionality:
 
  - Instantiating the Stream class directly. 
    - Example: `final myStream = MergeStream([myFirstStream, mySecondStream]);`
  - Using the `Observable` class' static factories, which are useful for discovering which types of Streams are provided by RxDart. Under the hood, these factories simply call the the corresponding Stream constructor. 
    - Example: `final myStream = Observable.merge([myFirstStream, mySecondStream]);`

#### List of Classes / Static Factories

- [ConcatStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ConcatStream-class.html) / [Observable.concat](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.concat.html)
- [ConcatEagerStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ConcatEagerStream-class.html) / [Observable.concatEager](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.concatEager.html)
- [DeferStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/DeferStream-class.html) / [Observable.defer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.defer.html)
- [MergeStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/MergeStream-class.html) / [Observable.merge](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.merge.html)
- [NeverStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/NeverStream-class.html) / [Observable.never](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.never.html)
- [RaceStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RaceStream-class.html) / [Observable.race](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.race.html)
- [RepeatStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RepeatStream-class.html) / [Observable.repeat](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.repeat.html)
- [RetryStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RetryStream-class.html) / [Observable.retry](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.retry.html)
- [RetryWhenStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RetryWhenStream-class.html) / [Observable.retryWhen](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.retryWhen.html)
- [SequenceEqualStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/SequenceEqualStream-class.html) / [Observable.sequenceEqual](https://pub.dev/documentation/rxdart/latest/rx/Observable/sequenceEqual.html)
- [SwitchLatestStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/SwitchLatestStream-class.html) / [Observable.switchLatest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.switchLatest.html)
- [TimerStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/TimerStream-class.html) / [Observable.timer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/Observable.timer.html)
- [CombineLatestStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/CombineLatestStream-class.html) (combine2, combine3... combine9) / [Observable.combineLatest2](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/combineLatest2.html)...[Observable.combineLatest9](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/combineLatest9.html) 
- [ForkJoinStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ForkJoinStream-class.html) (join2, join3... join9) / [Observable.forkJoin2](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/forkJoin2.html)...[Observable.forkJoin9](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/forkJoin9.html)
- [RangeStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/RangeStream-class.html) / [Observable.range](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/range.html)
- [ZipStream](https://www.dartdocs.org/documentation/rxdart/latest/rx/ZipStream-class.html) (zip2, zip3, zip4, ..., zip9) / [Observable.zip](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/zip2.html)...[Observable.zip9](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/zip9.html)

### Extension Methods

The extension methods provided by RxDart can be used on any `Stream`. They convert a source Stream into a new Stream with additional capabilities, such as buffering or throttling events.

#### Example

```dart
final myStream = Stream.fromIterable([1, 2, 3]).debounceTime(Duration(seconds: 1));
``` 

#### List of Extension Methods

- [buffer](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/buffer.html)
- [bufferCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/bufferCount.html)
- [bufferTest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/bufferTest.html)
- [bufferTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/bufferTime.html)
- [concatWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/concatWith.html)
- [debounce](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/debounce.html)
- [debounceTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/debounceTime.html)
- [delay](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/delay.html)
- [dematerialize](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/dematerialize.html)
- [distinctUnique](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/distinctUnique.html)
- [doOnCancel](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnCancel.html)
- [doOnData](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnData.html)
- [doOnDone](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnDone.html)
- [doOnEach](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnEach.html)
- [doOnError](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnError.html)
- [doOnListen](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnListen.html)
- [doOnPause](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnPause.html)
- [doOnResume](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/doOnResume.html)
- [exhaustMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/exhaustMap.html)
- [flatMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/flatMap.html)
- [flatMapIterable](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/flatMapIterable.html)
- [groupBy](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/groupBy.html)
- [interval](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/interval.html)
- [mapTo](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/mapTo.html)
- [materialize](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/materialize.html)
- [mergeWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/mergeWith.html)
- [max](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/max.html)
- [min](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/min.html)
- [onErrorResume](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorResume.html)
- [onErrorResumeNext](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorResumeNext.html)
- [onErrorReturn](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorReturn.html)
- [onErrorReturnWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/onErrorReturnWith.html)
- [sample](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/sample.html)
- [sampleTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/sampleTime.html)
- [scan](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/scan.html)
- [skipUntil](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/skipUntil.html)
- [startWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/startWith.html)
- [startWithMany](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/startWithMany.html) 
- [switchMap](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/switchMap.html)
- [takeUntil](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/takeUntil.html)
- [timeInterval](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/timeInterval.html)
- [timestamp](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/timestamp.html)
- [throttle](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/throttle.html)
- [throttleTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/throttleTime.html)
- [whereType](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/whereType.html)
- [window](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/window.html)
- [windowCount](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/windowCount.html)
- [windowTest](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/windowTest.html)
- [windowTime](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/windowTime.html)
- [withLatestFrom](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/withLatestFrom.html)
- [zipWith](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable/zipWith.html)

## Rx Observables vs Dart Streams

In many situations, Streams and Observables work the same way. However, if you're used to standard Rx Observables, some features of the Stream api may surprise you. We've included a table below to help folks understand the differences. 

Additional information about the following situations can be found by reading the [Observable class documentation](https://www.dartdocs.org/documentation/rxdart/latest/rx/Observable-class.html).

| Situation | Rx Observables  | Dart Streams |
| ------------- |------------- | ------------- |
| An error is raised | Observable Terminates with Error  | Error is emitted and Stream continues |
| Cold Observables  | Multiple subscribers can listen to the same cold Observable, each subscription will receive a unique Stream of data | Single subscriber only | 
| Hot Observables  | Yes | Yes, known as Broadcast Streams | 
| Is {Publish, Behavior, Replay}Subject hot? | Yes | Yes |
| Single/Maybe/Complete ? | Yes | No, uses Dart `Future` |
| Support back pressure| Yes | Yes |
| Can emit null? | Yes, except RxJava | Yes |
| Sync by default | Yes | No |
| Can pause/resume a subscription*? | No | Yes |

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

- [Documentation on the Dart Stream class](https://api.dart.dev/stable/dart-async/Stream-class.html)
- [Tutorial on working with Streams in Dart](https://www.dartlang.org/tutorials/language/streams)
- [ReactiveX (Rx)](http://reactivex.io/)

## Changelog

Refer to the [Changelog](https://github.com/frankpepermans/rxdart/blob/master/CHANGELOG.md) to get all release notes.
