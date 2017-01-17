# RxDart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)
[![Coverage Status](https://coveralls.io/repos/frankpepermans/rxdart/badge.svg?branch=master&service=github)](https://coveralls.io/github/frankpepermans/rxdart?branch=master)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/rxdart/Lobby.svg)](https://gitter.im/rxdart/Lobby)

## About
RxDart aims to provide an implementation of [ReactiveX](http://reactivex.io/) for the Dart language.  
Dart comes with a very decent [Streams](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html) API out-of-the-box.  
This library is built on top of it as an enhancement.

## How To Use RxDart
Use the method `observable()` to wrap a native Dart Stream.
```dart
Observable oStream = observable(myStream);
```

## API Overview

RxDart's Observables extend the Stream class, meaning all methods defined [here](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html#instance-methods) can be used on Observables as well.

On top of this, RxDart provides its own API:

### Factory Constructors
- amb
- combineTwoLatest  
combineThreeLatest  
combineFourLatest  
combineFiveLatest  
combineSixLatest  
combineSevenLatest  
combineEightLatest  
combineNineLatest
- concat
- defer
- just
- merge
- tween
- zipTwo  
zipThree  
zipFour  
zipFive  
zipSix  
zipSeven  
zipEight  
zipNine

### Methods and Operators
    
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

### Objects

- Observable
- BehaviourSubject
- ReplaySubject

## API In Detail

### Factory Constructors

#### amb

Given two or more source Streams, emits all of the items from only the first of these Streams to emit an item or notification.

##### Arguments
- `Iterable<Stream> streams`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: AmbObservable
##### [RxMarbles Diagram](http://rxmarbles.com/#amb)

#### combineTwoLatest, combineThreeLatest, ..., combineNineLatest

Creates an Observable where each item is the result of passing the latest values from each feeder stream into the predicate function.

##### Arguments
- `Stream streamOne`
- `Stream streamTwo`
- ...
- `Stream streamNine`
- `T predicate`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: CombineLatestObservable
##### [RxMarbles Diagram](http://rxmarbles.com/#combineLatest)

#### concat

Concatenates all of the specified observable sequences, as long as the previous observable sequence terminated successfully..

##### Arguments
- `Iterable<Stream> streams`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: ConcatObservable
##### [RxMarbles Diagram](http://rxmarbles.com/#concat)

#### defer

The defer factory waits until an observer subscribes to it, and then it generates an Observable with the given function.

It does this afresh for each subscriber, so although each subscriber may
think it is subscribing to the same Observable, in fact each subscriber
gets its own individual sequence.

In some circumstances, waiting until the last minute (that is, until
subscription time) to generate the Observable can ensure that this
Observable contains the freshest data.

##### Arguments
- `Stream create`

##### Returns: DeferObservable

#### eventTransformed

Creates an Observable where all events of an existing stream are piped through a sink-transformation.

The given [mapSink] closure is invoked when the returned stream is
listened to. All events from the [source] are added into the event sink
that is returned from the invocation. The transformation puts all
transformed events into the sink the [mapSink] closure received during
its invocation. Conceptually the [mapSink] creates a transformation pipe
with the input sink being the returned [EventSink] and the output sink
being the sink it received.

##### Arguments
- `Stream source`
- `EventSink mapSink`

##### Returns: Observable

#### fromFuture

Creates an Observable from a `Future`.
When the `Future` completes, the stream will fire one event, either data or error, and then close with a done-event.

##### Arguments
- `Future future`

##### Returns: Observable

#### fromIterable

Creates an Observable that gets its data from [data].

The iterable is iterated when the stream receives a listener, and stops
iterating if the listener cancels the subscription.

If iterating [data] throws an error, the stream ends immediately with
that error. No done event will be sent (iteration is not complete), but no
further data events will be generated either, since iteration cannot
continue.

##### Arguments
- `Iterable data`

##### Returns: Observable

#### just

Creates an Observable that contains a single value.  
The value is emitted when the stream receives a listener.

##### Arguments
- `T data`

##### Returns: Observable

#### fromStream

Creates an Observable that gets its data from [stream].

If stream throws an error, the Observable ends immediately with
that error. When stream is closed, the Observable will also be closed.

##### Arguments
- `Stream stream`

##### Returns: Observable

#### merge

Creates an Observable where each item is the interleaved output emitted by the feeder streams.

##### Arguments
- `Iterable<Stream> streams`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: MergeObservable
##### [RxMarbles Diagram](http://rxmarbles.com/#merge)

#### periodic

Creates an Observable that repeatedly emits events at [period] intervals.

The event values are computed by invoking [computation]. The argument to this callback is an integer that starts with 0 and is incremented for every event.

If [computation] is omitted the event values will all be `null`.

##### Arguments
- `Duration period`
- T computation

##### Returns: Observable

#### tween

Creates an Observable that emits values starting from startValue and incrementing
according to the ease type over the duration.

##### Arguments
- `double startValue`
- `double changeInTime`
- `Duration duration`
- `int intervalMS` (named, default: 20)
- `Ease ease` (named, default: Ease.LINEAR)
- `bool asBroadcastStream` (optional, default: false)

##### Returns: TweenObservable

#### zipTwo, zipThree, ..., zipNine

Creates an Observable that applies a function of your choosing to the
combination of items emitted, in sequence, by two (or more) other
Observables, with the results of this function becoming the items emitted
by the returned Observable. It applies this function in strict sequence,
so the first item emitted by the new Observable will be the result of the
function applied to the first item emitted by Observable #1 and the first
item emitted by Observable #2; the second item emitted by the new
zip-Observable will be the result of the function applied to the second
tem emitted by Observable #1 and the second item emitted by Observable #2; and so forth. 
It will only emit as many items as the number of items
emitted by the source Observable that emits the fewest items.


##### Arguments
- `Stream streamOne`
- `Stream streamTwo`
- ...
- `Stream streamNine`
- `T predicate`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: ZipObservable

## Notable References
- [Documentation on the Dart Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html)
- [Tutorial on working with Streams in Dart](https://www.dartlang.org/tutorials/language/streams)
- [ReactiveX (Rx)](http://reactivex.io/)
