# RxDart

[![Build Status](https://travis-ci.org/frankpepermans/rxdart.svg)](https://travis-ci.org/frankpepermans/rxdart)
[![Coverage Status](https://coveralls.io/repos/frankpepermans/rxdart/badge.svg?branch=master&service=github)](https://coveralls.io/github/frankpepermans/rxdart?branch=master)
[![Pub](https://img.shields.io/pub/v/rxdart.svg)](https://pub.dartlang.org/packages/rxdart)
[![Gitter](https://img.shields.io/gitter/room/rxdart/Lobby.svg)](https://gitter.im/rxdart/Lobby)

## About
RxDart aims to provide an implementation of [ReactiveX](http://reactivex.io/) for the Dart language.  
Dart comes with a very decent [Streams](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html) API out-of-the-box.  
This library is built on top of it.

## How To Use RxDart
Use the method `observable()` to wrap a native Dart Stream.
```dart
var myObservable = observable(myStream);
```

## Example

```dart
import 'package:rxdart/rxdart.dart' as rx;

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

## API Overview

RxDart's Observables extend the Stream class, meaning all methods defined [here](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html#instance-methods) exist on Observables as well.
But on top of these, RxDart provides its own API:

### Factory Constructors

##### Available Methods
- [amb](#amb)
- [concat](#concat)
- [defer](#defer)
- [just](#just)
- [merge](#merge)
- [periodic](#periodic)
- [tween](#tween)

##### Usage
```dart
var myObservable = new Observable.amb([myFirstStream, mySecondStream])
```

### Static Instantiation Methods

To better support strong mode, combineLatest and zip have been pulled apart into fixed-length constructors.  
These methods are available as static methods, since class factory methods don't support generic method types.

##### Available Methods
- [combineTwoLatest](#combineLatest)  
[combineThreeLatest](#combineLatest)  
[combineFourLatest](#combineLatest)  
[combineFiveLatest](#combineLatest)  
[combineSixLatest](#combineLatest)  
[combineSevenLatest](#combineLatest)  
[combineEightLatest](#combineLatest)  
[combineNineLatest](#combineLatest)
- [zipTwo](#zip)  
[zipThree](#zip)   
[zipFour](#zip)   
[zipFive](#zip)   
[zipSix](#zip)   
[zipSeven](#zip)   
[zipEight](#zip)   
[zipNine](#zip) 

##### Usage
```dart
var myObservable = Observable.combineTwoLatest(
    myFirstStream, 
    mySecondStream, 
    (firstData, secondData) => print(firstData + ' ' + secondData));
```

### Operators
    
##### Available Methods
- [bufferWithCount](#bufferWithCount)
- [debounce](#debounce)
- [flatMapLatest](#flatMapLatest)
- [flatMap](#flatMap)
- [groupBy](#groupBy)
- [interval](#interval)
- [max](#max)
- [min](#min)
- [pluck](#pluck)
- [repeat](#repeat)
- [retry](#retry)
- [sample](#sample)
- [scan](#scan)
- [startWith](#startWith)
- [startWithMany](#startWithMany)
- [takeUntil](#takeUntil)
- [timeInterval](#timeInterval)
- [tap](#tap)
- [throttle](#throttle)
- [windowWithCount](#windowWithCount)
- [withLatestFrom](#withLatestFrom)

##### Usage
```Dart
var myObservable = observable(myStream)
    .bufferWithCount(5)
    .distinct()
```

### Objects

- [Observable](#Observable)
- [BehaviourSubject](#BehaviourSubject)
- [ReplaySubject](#ReplaySubject)

## API In Detail

### Factory Constructors

#### <a id="amb"></a> amb

Given two or more source Streams, emits all of the items from only the first of these Streams to emit an item or notification.

##### Arguments
- `Iterable<Stream> streams`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: AmbObservable
##### [RxMarbles Diagram](http://rxmarbles.com/#amb)

–––

#### <a id="concat"></a> concat

Concatenates all of the specified observable sequences, as long as the previous observable sequence terminated successfully..

##### Arguments
- `Iterable<Stream> streams`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: ConcatObservable
##### [RxMarbles Diagram](http://rxmarbles.com/#concat)

–––

#### <a id="defer"></a> defer

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

–––

#### <a id="eventTransformed"></a> eventTransformed

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

–––

#### <a id="fromFuture"></a> fromFuture

Creates an Observable from a `Future`.
When the `Future` completes, the stream will fire one event, either data or error, and then close with a done-event.

##### Arguments
- `Future future`

##### Returns: Observable

–––

#### <a id="fromIterable"></a> fromIterable

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

–––

#### <a id="just"></a> just

Creates an Observable that contains a single value.  
The value is emitted when the stream receives a listener.

##### Arguments
- `T data`

##### Returns: Observable

–––

#### <a id="fromStream"></a> fromStream

Creates an Observable that gets its data from [stream].

If stream throws an error, the Observable ends immediately with
that error. When stream is closed, the Observable will also be closed.

##### Arguments
- `Stream stream`

##### Returns: Observable

–––

#### <a id="merge"></a> merge

Creates an Observable where each item is the interleaved output emitted by the feeder streams.

##### Arguments
- `Iterable<Stream> streams`
- `bool asBroadcastStream` (optional, default: false)

##### Returns: MergeObservable
##### [RxMarbles Diagram](http://rxmarbles.com/#merge)

–––

#### <a id="periodic"></a> periodic

Creates an Observable that repeatedly emits events at [period] intervals.

The event values are computed by invoking [computation]. The argument to this callback is an integer that starts with 0 and is incremented for every event.

If [computation] is omitted the event values will all be `null`.

##### Arguments
- `Duration period`
- T computation

##### Returns: Observable

–––

#### <a id="tween"></a> tween

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

### Static Instantiation Methods

#### <a id="combineLatest"></a> combineTwoLatest, combineThreeLatest, ..., combineNineLatest

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

–––

#### <a id="zip"></a> zipTwo, zipThree, ..., zipNine

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

### Operators

#### <a id="asBroadcastStream"></a> asBroadcastStream

Returns a multi-subscription stream that produces the same events as this.

The returned stream will subscribe to this stream when its first
subscriber is added, and will stay subscribed until this stream ends, or a
callback cancels the subscription.

If onListen is provided, it is called with a subscription-like object that
represents the underlying subscription to this stream. It is possible to
pause, resume or cancel the subscription during the call to onListen. It
is not possible to change the event handlers, including using
StreamSubscription.asFuture.

If onCancel is provided, it is called in a similar way to onListen when
the returned stream stops having listener. If it later gets a new
listener, the onListen function is called again.

Use the callbacks, for example, for pausing the underlying subscription
while having no subscribers to prevent losing events, or canceling the
subscription when there are no listeners.

##### Arguments
- `void onListen(StreamSubscription subscription)` (named)
- `void onCancel(StreamSubscription subscription)` (named)

##### Returns: Observable

–––

#### <a id="asyncExpand"></a> asyncExpand

Creates an Observable with the events of a stream per original event.

This acts like expand, except that convert returns a Stream instead of an
Iterable. The events of the returned stream becomes the events of the
returned stream, in the order they are produced.

If convert returns null, no value is put on the output stream, just as if
it returned an empty stream.

The returned stream is a broadcast stream if this stream is.

##### Arguments
- `Stream convert(T value)`

##### Returns: Observable

–––

#### <a id="asyncMap"></a> asyncMap

Creates an Observable with each data event of this stream asynchronously mapped to a new event.

This acts like map, except that convert may return a Future, and in that
case, the stream waits for that future to complete before continuing with
its result.

The returned stream is a broadcast stream if this stream is.

##### Arguments
- `Stream convert(T value)`

##### Returns: Observable

–––

#### <a id="bufferWithCount"></a> bufferWithCount

Creates an Observable where each item is a list containing the items
from the source sequence, in batches of count.

If skip is provided, each group will start where the previous group ended minus count.

##### Arguments
- `int count`
- `int skip` (optional)

##### Returns: Observable

–––

#### <a id="debounce"></a> debounce

Creates an Observable that will only emit items from the source sequence
if a particular time span has passed without the source sequence emitting
another item.

The Debounce operator filters out items emitted by the source Observable
that are rapidly followed by another emitted item.

##### Arguments
- `Duration duration`

##### Returns: Observable
##### [RxMarbles Diagram](http://rxmarbles.com/#debounce)

–––

#### <a id="distinct"></a> distinct

Creates an Observable where data events are skipped if they are equal to
the previous data event.

The returned stream provides the same events as this stream, except that
it never provides two consecutive data events that are equal.

Equality is determined by the provided equals method. If that is omitted,
the '==' operator on the last provided data element is used.

The returned stream is a broadcast stream if this stream is. If a
broadcast stream is listened to more than once, each subscription will
individually perform the equals test.

##### Arguments
- `bool equals(T previous, T next)` (optional)

##### Returns: Observable
##### [RxMarbles Diagram](http://rxmarbles.com/#distinct)

–––

#### <a id="expand"></a> expand

Creates an Observable from this stream that converts each element into
zero or more events.

Each incoming event is converted to an Iterable of new events, and each of
these new events are then sent by the returned Observable in order.

The returned Observable is a broadcast stream if this stream is. If a
broadcast stream is listened to more than once, each subscription will
individually call convert and expand the events.

##### Arguments
- `Iterable convert(T value)`

##### Returns: Observable

–––

#### <a id="flatMap"></a> flatMap

Creates an Observable by applying the predicate to each item emitted by
the original Observable, where that function is itself an Observable that
emits items, and then merges the results of that function applied to every
item emitted by the original Observable, emitting these merged results.

##### Arguments
- `Stream predicate(T value)`

##### Returns: Observable

–––

#### <a id="flatMapLatest"></a> flatMapLatest

Creates an Observable by transforming the items emitted by the source into
Observables, and mirroring those items emitted by the most-recently
transformed Observable.

The flatMapLatest operator is similar to the flatMap and concatMap
methods, however, rather than emitting all of the items emitted by all of
the Observables that the operator generates by transforming items from the
source Observable, flatMapLatest instead emits items from each such
transformed Observable only until the next such Observable is emitted,
then it ignores the previous one and begins emitting items emitted by the
new one.

##### Arguments
- `Stream predicate(T value)`

##### Returns: Observable

–––

#### <a id="groupBy"></a> groupBy

##### Arguments
- `S keySelector(T value)`
- `int compareKeys(S keyA, S keyB)` (named)

##### Returns: Observable

–––

#### <a id="handleError"></a> handleError

Creates a wrapper Stream that intercepts some errors from this stream.

If this stream sends an error that matches test, then it is intercepted by
the handle function.

The onError callback must be of type void onError(error) or void
onError(error, StackTrace stackTrace). Depending on the function type the
stream either invokes onError with or without a stack trace. The stack
trace argument might be null if the stream itself received an error
without stack trace.

An asynchronous error e is matched by a test function if test(e) returns
true. If test is omitted, every error is considered matching.

If the error is intercepted, the handle function can decide what to do
with it. It can throw if it wants to raise a new (or the same) error, or
simply return to make the stream forget the error.

If you need to transform an error into a data event, use the more generic
Stream.transform to handle the event by writing a data event to the output
sink.

The returned stream is a broadcast stream if this stream is. If a
broadcast stream is listened to more than once, each subscription will
individually perform the test and handle the error.

##### Arguments
- `Function onError`
- `bool test(dynamic error)` (named)

##### Returns: Observable

–––

#### <a id="interval"></a> interval

Creates an observable that produces a value after each duration.

##### Arguments
- `Duration duration`

##### Returns: Observable

–––

#### <a id="map"></a> map

Maps values from a source sequence through a function and emits the
returned values.

The returned sequence completes when the source sequence completes.
The returned sequence throws an error if the source sequence throws an
error.

##### Arguments
- `convert(T event)`

##### Returns: Observable

–––

#### <a id="max"></a> max

Creates an Observable that returns the maximum value in the source
sequence according to the specified compare function.

##### Arguments
- `int compare(T a, T b)` (optional)

##### Returns: Observable

–––

#### <a id="min"></a> min

Creates an Observable that returns the minimum value in the source
sequence according to the specified compare function.

##### Arguments
- `int compare(T a, T b)` (optional)

##### Returns: Observable

–––

#### <a id="pluck"></a> pluck

Creates an Observable containing the value of a specified nested property
from all elements in the Observable sequence. If a property can't be
resolved, it will return undefined for that value.

##### Arguments
- `List sequence`
- `bool throwOnNull` (named, default: false)

##### Returns: Observable

–––

#### <a id="repeat"></a> repeat

Creates an Observable that repeats the source's elements the specified
number of times.

##### Arguments
- `int repeatCount`

##### Returns: Observable

–––

#### <a id="retry"></a> retry

Creates an Observable that will repeat the source sequence the specified
number of times until it successfully terminates. If the retry count is
not specified, it retries indefinitely.

##### Arguments
- `int count` (optional)

##### Returns: Observable

–––

#### <a id="sample"></a> sample

Creates an Observable that will emit the latest value from the source
sequence whenever the sampleStream itself emits a value.

##### Arguments
- `Stream sampleStream`

##### Returns: Observable

–––

#### <a id="withLatestFrom"></a> withLatestFrom

Creates an Observable that emits when the source stream emits,
combining the latest values from the two streams using
the provided function.

If the latestFromStream has not emitted any values, this stream will not
emit either.

##### Arguments
- `Stream latestFromStream`
- `fn(T t, S s)`

##### Returns: Observable
##### [RxMarbles Diagram](http://rxmarbles.com/#withLatestFrom)

–––

#### <a id="scan"></a> scan

Applies an accumulator function over an observable sequence and returns
each intermediate result. The optional seed value is used as the initial
accumulator value.

##### Arguments
- `predicate(S accumulated, T value, int index)`
- `S seed` (optional)

##### Returns: Observable

–––

#### <a id="skip"></a> skip

Skips the first count data events from this stream.
 
The returned stream is a broadcast stream if this stream is. For a
broadcast stream, the events are only counted from the time the returned
stream is listened to.

##### Arguments
- `int count`

##### Returns: Observable

–––

#### <a id="skipWhile"></a> skipWhile

Skip data events from this stream while they are matched by test.

Error and done events are provided by the returned stream unmodified.

Starting with the first data event where test returns false for the event
data, the returned stream will have the same events as this stream.

The returned stream is a broadcast stream if this stream is. For a
broadcast stream, the events are only tested from the time the returned
stream is listened to.

##### Arguments
- `bool test(T element)`

##### Returns: Observable

–––

#### <a id="startWith"></a> startWith

Prepends a value to the source Observable.

##### Arguments
- `T startValue`

##### Returns: Observable

–––

#### <a id="startWithMany"></a> startWithMany

Prepends a value to the source Observable.

##### Arguments
- `List startValues`

##### Returns: Observable

–––

#### <a id="take"></a> take

Provides at most the first `n` values of this stream.
Forwards the first n data events of this stream, and all error events, to
the returned stream, and ends with a done event.

If this stream produces fewer than count values before it's done, so will
the returned stream.

Stops listening to the stream after the first n elements have been
received.

Internally the method cancels its subscription after these elements. This
means that single-subscription (non-broadcast) streams are closed and
cannot be reused after a call to this method.

The returned stream is a broadcast stream if this stream is. For a
broadcast stream, the events are only counted from the time the returned
stream is listened to.

##### Arguments
- `int count`

##### Returns: Observable

–––

#### <a id="takeUntil"></a> takeUntil

Returns the values from the source observable sequence until the other
observable sequence produces a value.

##### Arguments
- `Stream otherStream`

##### Returns: Observable

–––

#### <a id="takeWhile"></a> takeWhile

Forwards data events while test is successful.

The returned stream provides the same events as this stream as long as
test returns true for the event data. The stream is done when either this
stream is done, or when this stream first provides a value that test
doesn't accept.

Stops listening to the stream after the accepted elements.

Internally the method cancels its subscription after these elements. This
means that single-subscription (non-broadcast) streams are closed and
cannot be reused after a call to this method.

The returned stream is a broadcast stream if this stream is. For a
broadcast stream, the events are only tested from the time the returned
stream is listened to.

##### Arguments
- `bool test(T element)`

##### Returns: Observable

–––

#### <a id="tap"></a> tap

Invokes an action for each element in the observable sequence and invokes
an action upon graceful or exceptional termination of the observable sequence.

This method can be used for debugging, logging, etc. of query behavior by
intercepting the message stream to run arbitrary actions for messages on
the pipeline.

##### Arguments
- `bool test(void action(T value))`

##### Returns: Observable

–––

#### <a id="throttle"></a> throttle

Returns an Observable that emits only the first item emitted by the source
Observable during sequential time windows of a specified duration.

##### Arguments
- `Duration duration`

##### Returns: Observable

–––

#### <a id="timeInterval"></a> timeInterval

Records the time interval between consecutive values in an observable sequence.

##### Returns: Observable

–––

#### <a id="timeout"></a> timeout

The Timeout operator allows you to abort an Observable with an onError
termination if that Observable fails to emit any items during a specified
duration.  You may optionally provide a callback function to execute on
timeout.

##### Arguments
- `Duration timeLimit`
- `void onTimeout(EventSink<T> sink)` (named)

##### Returns: Observable

–––

#### <a id="where"></a> where

Filters the elements of an observable sequence based on the test.

##### Arguments
- `bool test(T event)`

##### Returns: Observable

–––

#### <a id="windowWithCount"></a> windowWithCount

Projects each element of an observable sequence into zero or more windows
which are produced based on element count information.

##### Arguments
- `int count`
- `int skip` (optional)

##### Returns: Observable

### Objects

#### <a id="observable"></a> Observable

This is the core object

–––

#### <a id="BehaviourSubject"></a> BehaviourSubject

Will only send the last added event, on listening to it

–––

#### <a id="ReplaySubject"></a> ReplaySubject

Will send all past events, on listening to it

## Notable References
- [Documentation on the Dart Stream class](https://api.dartlang.org/stable/1.21.1/dart-async/Stream-class.html)
- [Tutorial on working with Streams in Dart](https://www.dartlang.org/tutorials/language/streams)
- [ReactiveX (Rx)](http://reactivex.io/)
